function sofistandalone(markerUmCsv, wavelengthUm, numericalAperture, ...
                        pixelSizeUm, magnification, cameraSizePx,  ...
                        axialRangeUm, axialStepUm, bleachingTimeS, ...
                        markerIntensityPhoton, ...
                        backgroundIntensityPhoton, markerRadiusNm, ...
                        markerOnLifetimeMs, markerOffLifetimeMs, ...
                        gaussianNoiseStd, darkCurrent, quantumGain, ...
                        frameRateHz, aquisitionDurationS, microscope, ...
                        groundTruthTif, finalImageTif , randomSeed, ...
                        iCell, nCell)
%sofistandalone  Simulate super-resolution microscopy image acquisition.
%   Simulate the microscopy image acquisition process for a cell given in
%   the form of a biomarkers point cloud. Supported microscopy techniques
%   are Stochastic Optical Reconstruction Microscopy (STORM) and
%   balanced Super-resolution Optical Fluctuation Imaging (bSOFI).
%   Nothing is returned but a ground truth binary image of biomarkers
%   positions and a final simulated microscopy image are saved as .tif 3D
%   image stacks.
%
% 	Inputs
%   ------
%       markerUmCsv - String. Path to a three columns .csv file containing
%   biomarkers 3D coordinates in µm, centered around 0.
%       wavelengthUm - Double. Emission wavelength (µm).
%       numericalAperture - Double. Numerical aperture of the optical
%   system.
%       pixelSizeUm - Double. Camera pixel size (µm).
%       magnification - Double. Objective magnification.
%       cameraSizePx - Int. The camera is considered to be a square of
%   cameraSizePx x cameraSizePx pixels.
%       axialRangeUm - Double. Imaged sample extends from -axialRangeUm to
%   +axialRangeUm in axial dimension (µm).
%       axialStepUm - Double. Step size in axial direction (µm). Final
%   image is a stack of 2D images from "slices" in the sample, distant from
%   one another by axialStepUm µm.
%       bleachingTimeS - Double. Average bleaching time of the biomarkers
%   (s). 0 deactivates photobleaching simulation.
%       markerIntensityPhoton - Double. Expected number of photons emitted
%   by a single biomarker in a frame.
%       backgroundIntensityPhoton - Double. Intensity of fluorescence not
%   emitted from the biomarker (photons). In a cell sample, this background
%   could arise from auto-fluorescence, i.e. fluorescence emission from
%   small biological molecules such as NADH.
%       markerRadiusNm - Double. Radius of a biomarker (nm).
%       markerOnLifetimeMs - Double. Average time (ms) during which a
%   biomarker is active, i.e. emitting photons.
%       markerOffLifetimeMs - Double. Average time (ms) during which a
%   biomarker is inactive, i.e. dark.
%       gaussianNoiseStd - Double. Standard deviation of additive Gaussian
%   noise.
%       darkCurrent - Double. Noise arising from the stochastic thermal
%   generation of electrons within the CCD structure (electrons/pixel/s).
%       quantumGain - Double. Mean number of electrons generated in the
%   CCD structure for one incoming photon (electrons/photon).
%       frameRateHz - Double. Camera frame rate, or number of frames 
%   acquired by the camera per second (frames/s).
%       aquisitionDurationS - Double. Time over which the camera records 
%   the fluorescence signal (s).
%       microscope - String or char array. "bSOFI" or "STORM", 
%   depending on the microscopy technique to use.
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
%       Either all or none of randomSeed, iCell and nCell must be provided.
%       If provided, iCell must be between 1 and nCell, included.
%
%   Notes
%   -----
%       All parameters support strings containing their value, in addition
%   to their aforementionned type.
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
%      sofistandalone('Path/in/markers.csv', 0.5, 1.25, 6.5, 60, 256, ...
%                     5, 0.3, 0.5, 100, 0, 8, 20, 40, 0.5, 0, 4.2, 100, ...
%                      3, 'SOFI', 'Path/out/gt.tif', 'Path/out/img.tif')
%
%   See also microscopysimulatorstandalone, microscopysimulator.

%% License information.
% This work is based on SOFIsim. You can find original work's references
% and license information below, and its unmodified original implementation
% in ThirdParty/sofitool.
% As SOFIsim is originally distributed as a graphical interface tool
% integrating its own biomarkers point cloud generation, present wrapper
% script sofistandalone.m has been written in order to incorporate it to
% MicroVIP's pipeline. This script consists in modified parts of original
% implementation and calls to unmodified functions, surrounded by personnal
% code. Its writing process is described here:
%   * Reconstruction of SOFIsim graphical interface tool's pipeline, and
% reformulation into a command line MATLAB script sofistandalone.m;
%   * Removal of integrated biomarkers point cloud generation;
%   * Addition of 3D imaging capabilities by using original 2D algorithm
% and applying it independently on each axial "slice" of imaged sample.
% Only normalization and contrast adjustment are performed at the end on
% final 3D resulting image;
%   * Slight changes in input parameters (units notably) to make it
% compatible with microscopysimulatorstandalone.m;
%   * Selection of output variables of interest.
%
% Original work's references and license information can be found below:
% 
% Girsault A, Lukes T, Sharipov A, Geissbuehler S, Leutenegger M,
% Vandenberg W, et al. (2016) SOFI Simulation Tool: A Software Package for
% Simulating and Testing Super-Resolution Optical Fluctuation Imaging.
% PLoS ONE 11(9): e0161602. https://doi.org/10.1371/journal.pone.0161602
% 
% Available at
% https://www.epfl.ch/labs/lben/lob/page-155720-en-html/sofitool/.
% Retrieved March 18, 2020.
% 
% Copyright © 2015 Arik Girsault
% École Polytechnique Fédérale de Lausanne,
% Laboratoire d'Optique Biomédicale, BM 5.142, Station 17, 1015 Lausanne,
% Switzerland.
% arik.girsault@epfl.ch, tomas.lukes@epfl.ch
% http://lob.epfl.ch/
% 
% SOFIsim is free software: you can redistribute it and/or modify it under
% the terms of the GNU General Public License as published by the Free
% Software Foundation, either version 3 of the License, or (at your option)
% any later version.
% SOFIsim is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
% FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
% more details.
% You can find a copy of the GNU General Public License at
% http://www.gnu.org/licenses/.

%% Handle arguments
% Ensure correct input types
[wavelengthUm, numericalAperture, pixelSizeUm, magnification, ...
 axialRangeUm, axialStepUm, bleachingTimeS, markerIntensityPhoton, ...
 backgroundIntensityPhoton, markerRadiusNm, markerOnLifetimeMs, ...
 markerOffLifetimeMs, gaussianNoiseStd, darkCurrent, quantumGain, ...
 frameRateHz, aquisitionDurationS, cameraSizePx] = valuesfromstrings(...
    {wavelengthUm, numericalAperture, pixelSizeUm, magnification, ...
     axialRangeUm, axialStepUm, bleachingTimeS, markerIntensityPhoton, ...
     backgroundIntensityPhoton, markerRadiusNm, markerOnLifetimeMs, ...
     markerOffLifetimeMs, gaussianNoiseStd, darkCurrent, quantumGain, ...
     frameRateHz, aquisitionDurationS}, {cameraSizePx}, {}, {});
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
% Organize parameters in structs, some of them saved in appdata (needed
% for using SOFIsim functions as is).
cameraParameter = struct('pixel_size', pixelSizeUm * 1e-6, ...
                         'acq_speed', frameRateHz, ...
                         'readout_noise', gaussianNoiseStd, ...
                         'dark_current', darkCurrent, ...
                         'quantum_gain', quantumGain);
cameraParameter.thermal_noise = cameraParameter.dark_current / ...
                                cameraParameter.acq_speed;
% Convert time units in number of frames
markerOnLifetimeFrame = markerOnLifetimeMs * 1e-3 * ...
                        cameraParameter.acq_speed;
markerOffLifetimeFrame = markerOffLifetimeMs * 1e-3 * ...
                         cameraParameter.acq_speed;
aquisitionDurationFrame = aquisitionDurationS * cameraParameter.acq_speed;
if bleachingTimeS
    bleachingTimeFrame = bleachingTimeS * cameraParameter.acq_speed;
else
    % bleachingTimeS = 0 deactivates bleaching simulation.
    % This corresponds to an infinite bleaching time.
    bleachingTimeFrame = Inf;
end
markerRadiusM = markerRadiusNm * 1e-9;
markerParameter = struct('radius', markerRadiusM, ...
                         'Ion', markerIntensityPhoton, ...
                         'Ton', markerOnLifetimeFrame, ...
                         'Toff', markerOffLifetimeFrame,  ...
                         'Tbl', bleachingTimeFrame, ...
                         'background', backgroundIntensityPhoton, ...
                         'duration', aquisitionDurationS);
setappdata(0, 'Fluo', markerParameter);
opticalParameter = struct('NA', numericalAperture, ...
                          'wavelength', wavelengthUm * 1e-6, ...
                          'magnification', magnification, ...
                          'frames', aquisitionDurationFrame);
gridParameter = struct('blckSize', 3, 'sx', cameraSizePx, ...
                       'sy', cameraSizePx);
% Steps in axial direction.
allAxialSlice = -axialRangeUm : axialStepUm : axialRangeUm;
nAxialSlice = length(allAxialSlice);
% Widefield microscopy image dimensions (image that would be obtained if
% SOFI or STORM super-resolution technique was not applied).
imageDimensionPx = [gridParameter.sx, gridParameter.sy, nAxialSlice];
% Widefield microscopy image sample size (size of an imaged object that is
% represented by one voxel in widefield image).
sampleSizeUm = [pixelSizeUm/magnification, pixelSizeUm/magnification, ...
                axialStepUm];
% Marker coordinates converted to positions in widefield microscopy image.
markerCoordinatePx = coordinatetovoxel(csvread(markerUmCsv), ...
                                       imageDimensionPx, sampleSizeUm);
%% Compute optical system's PSF. 
[opticalParameter.psf, opticalParameter.psf_digital, ...
    opticalParameter.fwhm, opticalParameter.fwhm_digital] = ...
        gaussianPSF(opticalParameter.NA, ...
                    opticalParameter.magnification, ...
                    opticalParameter.wavelength, ...
                    markerParameter.radius, cameraParameter.pixel_size);
setappdata(0, 'Optics', opticalParameter)
%% Run simulation, one axial step at a time
if contains(microscope, "sofi", 'IgnoreCase', true)
    disp('Running bSOFI simulation')
    isSofi = true;
else
    if contains(microscope, "storm", 'IgnoreCase', true)
        disp('Running STORM simulation')
        isSofi = false;
    else
        error("Unknown microscope type: %s\nMicroscope must " + ...
              "be 'bSOFI' or 'STORM'", microscope)
    end
end
for axialSliceNo = 1:nAxialSlice
    disp("Axial slice " + axialSliceNo + " / " + nAxialSlice);
    %% Record biomarkers signal for predefined duration
    markerInSlice = (markerCoordinatePx(:, 3) == axialSliceNo);
    markerParameter.emitters = markerCoordinatePx(markerInSlice, :);
    % Image sequence of blinking biomarkers.
    markerTimeTrace = simStacks(opticalParameter.frames, ...
        opticalParameter, cameraParameter, markerParameter, ...
        gridParameter, false, false);
    % Use only the discretized image sequence, as recorded by the camera.
    cameraRecording = double(markerTimeTrace.discrete);
    % Normalization
    cameraRecording = cameraRecording - min(cameraRecording(:));
    maxRecordedIntensity = max(cameraRecording(:));
    % If signal is too faint, it is considered only noise: we do not
    % run super-resolution algorithm on it since it does not contain
    % any biomarker.
    %if maxRecordedIntensity > 30
    cameraRecording = cameraRecording / maxRecordedIntensity;
    setappdata(0, 'digital_timeTraces', cameraRecording);
    %% Run super-resolution algorithm
    if isSofi
        %% SOFI calculation
        sofiResult = SOFIcalculations(0, false);
        superResolvedSlice = sofiResult.balanced;
    else
        %% STORM calculations
        superResolvedSlice = STORMcalculations(0, false);
        if all(isnan(superResolvedSlice))
            % Empty matrix if storm failed
            warning("STORM calculation failed, probably too many " + ...
                    "biomarkes to perform localization.")
            superResolvedSlice = zeros(size(superResolvedSlice));
        end
    end
    if axialSliceNo == 1
        % Initialize complete image (done here because we make it of
        % the size of superResolvedSlice in lateral dimensions.
        superResolved3DImage = zeros([size(superResolvedSlice), ...
                                      nAxialSlice]);
    end
    superResolved3DImage(:, :, axialSliceNo) = superResolvedSlice;
end
clear sofiResult superResolvedSlice
%% Normalization and contrast adjustment.
if isSofi
    superResolved3DImage(superResolved3DImage < 0) = 0;
    bsofiMinMax = [ min(superResolved3DImage(:)); ...
                    max(superResolved3DImage(:)) ];
    for axialSliceNo = 1:nAxialSlice
        superResolved3DImage(:, :, axialSliceNo) = imadjust(...
            superResolved3DImage(:, :, axialSliceNo), bsofiMinMax);
    end
else
    superResolved3DImage = superResolved3DImage / ...
                           max(superResolved3DImage(:));
end
%% Ground truth binary image.
% Factor by which super-resolved image is larger than original camera
% image.
enlargementFactor = size(superResolved3DImage) ./ double(imageDimensionPx);
enlargedCoordinatePx = floor(enlargementFactor .* markerCoordinatePx);
groundTruthBinaryImage = binaryimagefromcoordinates(...
    enlargedCoordinatePx,  size(superResolved3DImage));
%% Save images as .tif image stacks.
mat2tif(groundTruthTif, groundTruthBinaryImage)
mat2tif(finalImageTif, superResolved3DImage)