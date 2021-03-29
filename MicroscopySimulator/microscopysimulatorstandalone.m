function microscopysimulatorstandalone(markerUmCsv, wavelengthUm, ...
    refractiveIndex, numericalAperture, pixelSizeUm, magnification, ...
    cameraSizePx, axialRangeUm, axialStepUm, bleachingTimeS, ...
    markerIntensityPhoton, gaussianNoiseMean, gaussianNoiseStd, ...
    cellSpeedUmPerS, shutterSpeedHz, frameRateHz, lightSheetWidthUm, ...
    microscope, groundTruthTif, finalImageTif, randomSeed, ...
    iCell, nCell)
%microscopysimulatorstandalone  Simulate microscopy image acquisition.
%   Simulate the microscopy image acquisition process for a cell given in
%   the form of a biomarkers point cloud. Supported microscopy techniques
%   are widefield, confocal, 2 beam Structured Illumination Microscopy
%   (SIM), and 3 beam SIM. Each technique can optionally be performed as
%   light sheet micrsocopy. A microfluidic system can also be simulated by
%   providing a cell speed value.
%   Nothing is returned but a ground truth binary image of biomarkers
%   positions and a final simulated microscopy image are saved as .tif 3D
%   image stacks.
%
% 	Inputs
%   ------
%       markerUmCsv - String. Path to a three columns .csv file containing
%   biomarkers 3D coordinates in µm, centered around 0.
%       wavelengthUm - Double. Emission wavelength (µm).
%       refractiveIndex - Double. Refractive index of sample medium. Common
%   examples are 1.33 for water, 1.51 for oil and 1 for dry sample.
%       numericalAperture - Double. Numerical aperture of the optical
%   system.
%       pixelSizeUm - Double. Camera pixel size (µm).
%       magnification - Double. Objective magnification.
%       cameraSizePx - Int. Camera width and length in number pf pixels
%   (lateral size of final image).
%       axialRangeUm - Double. Imaged sample extends from -axialRangeUm to
%   +axialRangeUm in axial dimension (µm).
%       axialStepUm - Double. Step size in axial direction (µm). Final
%   image is a stack of 2D images from "slices" in the sample, distant from
%   one another by axialStepUm µm. If cellSpeedUmPerS is not 0, axialStepUm
%   is ignored as steps in axial direction are then defined by cell speed
%   and camera frame frate.
%       bleachingTimeS - Double. Average bleaching time of the biomarkers
%   (s). 0 deactivates photobleaching simulation.
%       markerIntensityPhoton - Scalar. Expected number of photons emitted
%   by a single biomarker. This is a parameter of Poisson noise simulation.
%       gaussianNoiseStd - Double. Standard deviation of additive Gaussian
%   noise.
%       gaussianNoiseMean - Double. Mean of additive Gaussian noise. By
%   default Gaussian noise intensity should be adjusted by changing
%   gaussianNoiseStd and letting gaussianNoiseMean be 0.
%       cellSpeedUmPerS - Double. Cell speed inside microfluidic system
%   (µm/s), used for motion blur simulation. 0 deactivates motion blur
%   (corresponding to a standard system without microfluidics). Note that
%   confocal microscope does not support microfluidic system, so
%   cellSpeedUmPerS must be 0 if microscope == 2.
%       shutterSpeedHz - Double. Camera shutter speed (s¯¹), inverse of
%   exposure time.
%       frameRateHz - Double. Camera frame rate (s¯¹), usually half of
%   shutter speed value.
%       lightSheetWidthUm - Double. Full Width at Half Maximum (FWHM) of
%   Gaussian Point Spread Function (PSF) in axial direction, ie width of a
%   light sheet (µm). 0 deactivates light-sheet microscopy.
%       microscope - String or char array. "widefield", "confocal", 
%   "2-beam SIM" or "3-beam SIM", depending on the microscope type to
%   use.
%       groundTruthTif - String. Path to output .tif image file in which to
%   save binary ground truth 3D image of biomarkers point cloud.
%       finalImageTif - String. Path to output .tif image file in which to
%   save simulated 3D microscopy image.
%       randomSeed - Int, optional. Used as seed for random number
%   generator. If omitted, rng('shuffle') will be used.
%       iCell - Int, optional. Index of current cell. Used for
%   parallelization.
%       nCell - Int, optional. Number of cells in population. Used for 
%   parallelization.
%
%   Prerequisite
%   ------------
%       Confocal microscope does not support microfluidic system, so
%   cellSpeedUmPerS must be 0 if microscope == 2.
%       Either all or none of randomSeed, iCell and nCell must be provided.
%       If provided, iCell must be between 1 and nCell, included.
%
%   Notes
%   -----
%       All parameters support strings containing their value, in addition
%   to their aforementionned type.
%       axialStepUm is mandatory, but its value will be ignored if
%   cellSpeedUmPerS > 0.
%       randomSeed, iCell and nCell exist for parallelization. They should
%   be omitted otherwise. To paralellize generation of a cell population,
%   call cellgeneratorstandalone in each parallel thread/job with the same
%   parameters set. Provide a randomSeed value (same for every thread/job)
%   and the number nCell of cells in the population. Pass a unique iCell
%   value from 1 to nCell to each job/thread. This procedure ensures each
%   thread/job uses a statistically independant random number generator.
%
%   Example
%   -------
%       microscopysimulatorstandalone('Path/to/markers.csv', 0.5, ...
%   1.33, 1.25, 6.5, 60, 256, 5, 0.3, 0.5, 100, 0, 0.5, 20, 200, 100, ...
%   2.9, 1, 'Path/to/out/gt.tif', 'Path/to/out/img.tif')
%
%   See also microscopysimulator, sofistandalone.

%% Handle arguments
% Ensure correct input types
[wavelengthUm, refractiveIndex, numericalAperture, pixelSizeUm, ...
 magnification, axialRangeUm, axialStepUm, bleachingTimeS, ...
 markerIntensityPhoton, gaussianNoiseMean, gaussianNoiseStd, ...
 cellSpeedUmPerS, shutterSpeedHz, frameRateHz, lightSheetWidthUm, ...
 cameraSizePx] = valuesfromstrings({wavelengthUm, refractiveIndex, ...
                                   numericalAperture, pixelSizeUm, ...
                                   magnification, axialRangeUm, ...
                                   axialStepUm, bleachingTimeS, ...
                                   markerIntensityPhoton, ...
                                   gaussianNoiseMean, gaussianNoiseStd, ...
                                   cellSpeedUmPerS, shutterSpeedHz, ...
                                   frameRateHz, lightSheetWidthUm}, ...
                                  {cameraSizePx}, {}, {});
% Initialize random number generator.
nParallelArguments = exist('randomSeed', 'var') + ...
                     exist('iCell', 'var') + exist('nCell', 'var');
switch nParallelArguments
    case 0
        rng('shuffle')
    case 3
        globalrandomgenerator(randomSeed, iCell, nCell)
    otherwise
        error("Either all or none of randomSeed, iCell and nCell " + ...
              "must be provided, but only %i of them were.", ...
              nParallelArguments)
end
% Convert bleaching time in frames rather than seconds.
bleachingTimeFrame = bleachingTimeS * frameRateHz;
markerCoordinateUm = csvread(markerUmCsv);
%% Run simulation
[microscopyImage, groundTruthBinaryImage] = microscopysimulator(...
    markerCoordinateUm, wavelengthUm, refractiveIndex, ...
    numericalAperture, pixelSizeUm, magnification, cameraSizePx, ...
    axialRangeUm, axialStepUm, bleachingTimeFrame, ...
    markerIntensityPhoton, gaussianNoiseMean, gaussianNoiseStd, ...
    cellSpeedUmPerS, shutterSpeedHz, frameRateHz, lightSheetWidthUm, ...
    microscope);
%% Save output image stacks
disp('Saving ground truth image stack.')
mat2tif(groundTruthTif, groundTruthBinaryImage)
disp('Saving simulated microscope image stack.')
mat2tif(finalImageTif, microscopyImage)