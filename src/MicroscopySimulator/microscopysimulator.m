function [microscopyImage, groundTruthBinaryImage, psfHalfWidthPx] = ...
    microscopysimulator(markerCoordinateUm, wavelengthUm, ...
                        refractiveIndex, numericalAperture, ...
                        pixelSizeUm, magnification, cameraSizePx, ...
                        axialRangeUm, axialStepSizeUm, ...
                        bleachingTimeFrame, markerIntensityPhoton, ...
                        gaussianNoiseMean, gaussianNoiseStd, ...
                        cellSpeedUmPerS, shutterSpeedHz, frameRateHz, ...
                        lightSheetWidthUm, wienerParameter, microscope)
    %microscopysimulator  Simulate microscopy image acquisition of a cell.
    %   Simulate the microscopy image acquisition process for a cell given
    %   in the form of a biomarkers point cloud. Supported microscopy
    %   techniques are widefield, confocal, 2 beam Structured Illumination
    %   Microscopy (SIM), and 3 beam SIM. Each technique can optionally be
    %   performed as light sheet micrsocopy. A microfluidic system can also
    %   be simulated by providing a cell speed value.
    %
    % 	Inputs
    %   ------
    %       markerCoordinateUm - nx3 double. Biomarkers 3D coordinates in
    %   µm, centered around 0.
    %       wavelengthUm - Double. Emission wavelength (µm).
    %       refractiveIndex - Double. Refractive index of sample medium.
    %   Common examples are 1.33 for water, 1.51 for oil and 1 for dry
    %   sample.
    %       numericalAperture - Double. Numerical aperture of the optical
    %   system.
    %       pixelSizeUm - Double. Camera pixel size (µm).
    %       magnification - Double. Objective magnification.
    %       cameraSizePx - Int. Camera width and length in number of pixels
    %   (lateral size of final image, or half of it in 3-beam SIM case).
    %       axialRangeUm - Double. Imaged area extends from -axialRangeUm
    %   to +axialRangeUm in axial dimension (µm).
    %       axialStepSizeUm - Double. Step size in axial direction (µm).
    %   Final image is a stack of 2D images from "slices" in imaged object,
    %   distant from one another by axialStepUm µm. If cellSpeedUmPerS is
    %   not 0, axialStepUm is ignored as steps in axial direction are then
    %   determined by cellSpeedUmPerS / frameRateHz.
    %       bleachingTimeFrame - Double. Average bleaching time of
    %   biomarkers (in frames). 0 deactivates photobleaching simulation.
    %       markerIntensityPhoton - Double. Expected number of photons 
    %   emitted by a single biomarker. This is a parameter of Poisson noise
    %   simulation.
    %       gaussianNoiseStd - Double. Standard deviation of additive
    %   Gaussian noise.
    %       gaussianNoiseMean - Double. Mean of additive Gaussian noise. By
    %   default Gaussian noise intensity should be adjusted by changing
    %   gaussianNoiseStd and letting gaussianNoiseMean be 0.
    %       cellSpeedUmPerS - Double. Cell speed inside microfluidic system
    %   (µm/s), used for motion blur simulation. 0 deactivates motion blur
    %   (corresponding to a standard system without microfluidics). Note
    %   that confocal microscope does not support microfluidic system, so
    %   cellSpeedUmPerS must be 0 if microscope == "confocal".
    %       shutterSpeedHz - Double. Camera shutter speed (s¯¹), inverse of
    %   exposure time.
    %       frameRateHz - Double. Camera frame rate (s¯¹), usually half of
    %   shutter speed value. Used to determine axialStepUm in a
    %   microfluidic system. If microfluidics are not used
    %   (cellSpeedUmPerS == 0), this value is ignored.
    %       lightSheetWidthUm - Double. Full Width at Half Maximum (FWHM)
    %    of Gaussian Point Spread Function (PSF) in axial direction, ie
    %   width of a light sheet (µm). 0 deactivates light-sheet microscopy.
    %       wienerParameter - Double. Wiener filter parameter for 3-beam
    %   SIM reconstruction (ignored for other microscopes).
    %       microscope - String or char array. "widefield", "confocal", 
    %   "2-beam SIM" or "3-beam SIM", depending on the microscope type to
    %   use.
    %
    %   Outputs
    %   -------
    %       microscopyImage - mxmxz double. Simulated microscopy 3D image.
    %   m is imageSizePx and z is determined from axialRangeUm and either 
    %   axialStepUm for non-microfluidic systems or 
    %   cellSpeedUmPerS / frameRateH for microfluidic systems.
    %       groundTruthBinaryImage - mxmxz logical. Ground truth binary 3D
    %   image, with 1 at biomarkers positions and 0 everywhere else. Its
    %   dimensions are the same as microscopyImage's.
    %       psfHalfWidthPx - Double. Used PSF lateral half-width (pixels).
    %
    %   Prerequisite
    %   ------------
    %       Confocal microscope does not support microfluidic system, so
    %   cellSpeedUmPerS must be 0 if microscope == "confocal"
    %
    %   Notes
    %   -----
    %       axialStepSizeUm is mandatory, but its value will be ignored if
    %   cellSpeedUmPerS > 0. Similarly, frameRateHz is mandatory but
    %    ignored if cellSpeedUmPerS == 0.
    %
    %   Example
    %   -------
    %       [image, groundTruth, psfHalfWidth] = ...
    %           microscopysimulator(rand(10, 3), 0.5, 1.33, 1.25, 6.5, ...
    %                               60, 256, 5, 0.3, 50, 100, 0, 0.5, ...
    %                               20, 200, 100, 2.9, 0.1, "widefield");
    %
    %   See also microscopysimulatorstandalone.
    %
    %   MicroVIP, Microscopy image simulation and analysis tool
    %   Copyright (C) 2021  Ali Ahmad, Guillaume Vanel,
    %   CREATIS, Universite Lyon 1, Insa de Lyon, Lyon, France.
    %
    %   This file is part of MicroVIP.
    %   MicroVIP is free software: you can redistribute it and/or modify
    %   it under the terms of the GNU General Public License as published
    %   by the Free Software Foundation, either version 3 of the License,
    %   or any later version.
    %
    %   This program is distributed in the hope that it will be useful,
    %   but WITHOUT ANY WARRANTY; without even the implied warranty of
    %   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    %   GNU General Public License for more details.
    %
    %   You should have received a copy of the GNU General Public License
    %   along with this program.  If not, see
    %   <https://www.gnu.org/licenses/>.

    %% Handle arguments
    % Determine axial step from cell speed in microfluidics case.
    if cellSpeedUmPerS
        disp("Using microfluidics, provided axial step value is " + ...
             "ignored and determined from cell speed and frame rate.")
        axialStepSizeUm = cellSpeedUmPerS/frameRateHz;
    end
    microscope = char(lower(microscope));
    %% Compute optical parameters
    % For microscopy system.
    [halfApertureAngleRad, sampleSizeUm, nAxialStep,  nyquistRate] = ...
        opticalparameters(wavelengthUm, refractiveIndex, ...
                          numericalAperture, pixelSizeUm, ...
                          magnification, axialRangeUm, axialStepSizeUm);
    % Final microscopy image dimensions, except for 3 beam SIM where there
    % is an image per illumination pattern (and seven patterns), so third
    % dimension is seven times larger.
    imageDimensionPx = double([cameraSizePx,  cameraSizePx, nAxialStep]);
    % For PSF.
    [psfDimensionPx, psfSampleSizeUm] = psfparameters(wavelengthUm, ...
        refractiveIndex, imageDimensionPx, axialRangeUm, ...
        lightSheetWidthUm, halfApertureAngleRad, sampleSizeUm, ...
        nyquistRate);
    %% Simulate microscopy image
    % 3 beam SIM is treated slightly differently.
    is3BeamSim = (microscope(1) == '3');
    if is3BeamSim
        % 3 beam SIM
        disp('Simulating 3 beam Structured Illumination Microscopy');
        [microscopyImage, lateralResolutionUm] = simulation3beamsim(...
            markerCoordinateUm, wavelengthUm, refractiveIndex, ...
            numericalAperture, axialRangeUm, lightSheetWidthUm, ...
            imageDimensionPx, sampleSizeUm, psfDimensionPx, ...
            psfSampleSizeUm);
    else
        %% Generate microscope Point Spread Function (PSF).
        switch(microscope(1))
            case{'w'}
                % Widefield
                disp('Simulating widefield microscopy');
                [psf, lateralResolutionUm] = psfwidefield(...
                    wavelengthUm, refractiveIndex, numericalAperture, ...
                    axialRangeUm, lightSheetWidthUm, imageDimensionPx, ...
                    psfDimensionPx, psfSampleSizeUm);
            case{'c'}
                % Confocal
                if cellSpeedUmPerS
                    error("Confocal microscopy does not support " + ...
                          "microfluidic system, please set cell " + ...
                          "speed to 0 or use another microscope type.")
                end
                disp('Simulating confocal microscopy');
                [psf, lateralResolutionUm] = psfconfocal(...
                    wavelengthUm, refractiveIndex, numericalAperture, ...
                    axialRangeUm, lightSheetWidthUm, imageDimensionPx, ...
                    psfDimensionPx, psfSampleSizeUm);
            case{'2'}
                % 2 beam SIM
                disp("Simulating 2 beam Structured Illumination " + ...
                     "Microscopy");
                [psf, lateralResolutionUm] = psf2beamsim(...
                    wavelengthUm, refractiveIndex, numericalAperture, ...
                    axialRangeUm, lightSheetWidthUm, imageDimensionPx, ...
                    psfDimensionPx, psfSampleSizeUm);
            otherwise
                error("Unknown microscope type: %s\nMicroscope must " + ...
                      "be 'widefield', 'confocal', '2-beam SIM' or " + ...
                      "'3-beam SIM'", microscope)
        end 
        %% Generate image of biomarkers point cloud in Fourier domain.
        disp('Creating image of 3D point cloud');
        % Create the three axes, from -pi/psfSampleSizeUm to 
        % pi/psfSampleSizeUm with psfDimensionPx steps in each direction.
        axisHandle = @(nStep, factor) linspace(-pi, pi, nStep) / factor;
        axis = arrayfun(axisHandle, psfDimensionPx, psfSampleSizeUm, ...
                        'UniformOutput', false);
        % Image of point cloud in Fourier domain.
        allMarkerFourier = complex( single( zeros( psfDimensionPx ) ) );
        for markerNo = 1:size(markerCoordinateUm, 1)
             %% Compute image of one marker in Fourier domain.
             iMarkerX = markerCoordinateUm(markerNo, 1);
             iMarkerY = markerCoordinateUm(markerNo, 2);
             iMarkerZ = markerCoordinateUm(markerNo, 3);
             % Compute image of current marker in Fourier domain.
             iMarkerLateral = exp(1i * single(iMarkerX*axis{1})) .'* ...
                              exp(1i * single(iMarkerY*axis{2}));
             iMarkerAxial = reshape(exp(1i * single(iMarkerZ*axis{3})), ...
                                    [1, 1, psfDimensionPx(3)]);
             % Create 3D image by copying iMarkerLateralFourier as many
             % times as their is elements in iMarkerAxialFourier and
             % multiplying each copy by corresponding element.
             iMarkerFourier = bsxfun(@times, iMarkerLateral, iMarkerAxial);
             %% Add current marker's image to whole point cloud image.
             allMarkerFourier = allMarkerFourier + iMarkerFourier;      
        end
        %% Generate microscopy image 
        disp('Creating 3D microscopy image');
        ootf = fftshift(fftn(psf)) .* allMarkerFourier;
        % Take absolute value as the result will be complex because the 
        % Fourier plane cannot be shifted back to zero when oversampling.
        % It is not a problem as signal should be positive.
        microscopyImage = abs( ifftn(ootf, imageDimensionPx) );  
    end
    psfHalfWidthPx = lateralResolutionUm / sampleSizeUm(1) / 2;
    %% Add noises and other effects
    if bleachingTimeFrame
        %% Photobleaching
        disp('Adding photobleaching');
        allAxialSlice = 1:imageDimensionPx(3);
        photobleachingFactor = exp( -(allAxialSlice - 1) / ...
                                    bleachingTimeFrame );
        if is3BeamSim
            % Repeat each factor 7 times (one for each illumination
            % pattern).
            photobleachingFactor = repmat(photobleachingFactor, 7, 1);
        end
        photobleachingFactor = reshape(photobleachingFactor, 1, 1, []);
        % Multiply each axial slice by its factor
        microscopyImage = bsxfun(@times, microscopyImage, ...
                                 photobleachingFactor);
    end
    if cellSpeedUmPerS
        %% Motion blur effect
        % Always before Poisson and Gaussian noise addition.
        exposureTimeS = 1 / shutterSpeedHz;
        % Cells move in axial direction, motion blur in other directions is
        % negligible.
        motionBlurSizeUm = cellSpeedUmPerS * exposureTimeS;
        motionBlurSizePx = ceil(motionBlurSizeUm / psfSampleSizeUm(3)); 
        motionBlurFilter = fspecial('motion', motionBlurSizePx, 0);
        % Apply convolution to each YZ plane of microscopy image.
        disp('Adding motion blur')
        parfor yzPlaneNo = 1:imageDimensionPx(1)
            microscopyImage(yzPlaneNo, :, :) = conv2( ...
                squeeze( microscopyImage(yzPlaneNo,:,:) ), ...
                motionBlurFilter, 'same' );
        end 
    end
    if markerIntensityPhoton
        %% Poisson noise
        % Always before Gaussian noise addition.
        disp('Adding Poisson noise');
        microscopyImage = poissrnd(microscopyImage*markerIntensityPhoton);
    end
    if gaussianNoiseMean || gaussianNoiseStd
        %% Gaussian noise (thermal and readout noise) 
         disp('Adding Gaussian noise');
         gaussianNoise = normrnd(gaussianNoiseMean, gaussianNoiseStd, ...
                                 imageDimensionPx(1:2));
         % Absolute value of Gaussian noise, to avoid negative intensities
         % in image.
         microscopyImage = microscopyImage + abs(gaussianNoise);
    end
    if is3BeamSim
        %% Final image reconstruction from the 7 phase shifts
        simReconstructiomProcessor = hexSimProcessor();
        simReconstructiomProcessor.NA = numericalAperture;
        simReconstructiomProcessor.magnification = magnification;
        simReconstructiomProcessor.w = wienerParameter; % Wiener parameter
        simReconstructiomProcessor.N = imageDimensionPx(1);
        simReconstructiomProcessor.n = refractiveIndex;
        simReconstructiomProcessor.pixelsize = pixelSizeUm;
        simReconstructiomProcessor.lambda = wavelengthUm;
        % Factor by which the illumination grid frequency exceeds the
        % incoherent cutoff
        simReconstructiomProcessor.eta = 0.8;
        disp("Calibration");
        simReconstructiomProcessor.calibrate(...
            microscopyImage(:, :, end/2+1:end/2+7) + ...
            microscopyImage(:, :, end/2-13:end/2-7) + ...
            microscopyImage(:, :, end/2+15:end/2+21));
        simReconstructiomProcessor.reset()
        disp("3-beam SIM compact reconstruction");
        microscopyImage = ...
            simReconstructiomProcessor.batchreconstructcompact(...
                microscopyImage);
        % Adjust image size: reconstruction yields an image twice larger in
        % lateral dimension
        imageDimensionPx = size(microscopyImage);
        sampleSizeUm = sampleSizeUm .* [.5, .5, 1];
        psfHalfWidthPx = 2* psfHalfWidthPx;
    end 
    %% Generate ground truth binary image
    markerCoordinatePx = coordinatetovoxel(markerCoordinateUm, ...
                                           imageDimensionPx, sampleSizeUm);
    groundTruthBinaryImage = binaryimagefromcoordinates(...
        markerCoordinatePx, imageDimensionPx);
    % Flip first two dimensions to match axes directions with microscopy
    % those in microscopy image.
    groundTruthBinaryImage = flip(flip(groundTruthBinaryImage, 1), 2);
end

function [halfApertureAngleRad, sampleSizeUm, nAxialStep, ...
          nyquistRate] = opticalparameters(wavelengthUm, ...
            refractiveIndex, numericalAperture, pixelSizeUm, ...
            magnification, axialRangeUm, axialStepSizeUm)
    %opticalparameters  Compute microscopy system optical parameters.
    %   Compute and return micrscopy system's half-aperture angle as well
    %   as sampling parameters: sample sizes (lateral and axial), number of
    %   axial samples and lateral Nyquist rate.
    %
    % 	Inputs
    %   ------
    %       wavelengthUm - Double. Emission wavelength (µm).
    %       refractiveIndex - Double. Refractive index of sample medium.
    %   Common examples are 1.33 for water, 1.51 for oil and 1 for dry
    %   sample.
    %       numericalAperture - Double. Numerical aperture of the optical
    %   system.
    %       pixelSizeUm - Double. Camera pixel size (µm).
    %       magnification - Double. Objective magnification.
    %       axialRangeUm - Double. Imaged area extends from -axialRangeUm
    %   to +axialRangeUm in axial dimension (µm).
    %       axialStepSizeUm - Double. Step size in axial direction (µm).
    %   Final image is a stack of 2D images from "slices" in the sample,
    %   distant from one another by axialStepUm µm.
    %
    %   Outputs
    %   -------
    %       halfApertureAngleRad - Double. Microscope's half aperture
    %   angle. This corresponds to the maximum angle from which light is
    %   received.
    %       sampleSizeUm - 1x3 double. Sample size in each dimension (µm),
    %   also called sampling distance: size of an imaged object that will
    %   be represented by one voxel (3D pixel) in final microscopy image.
    %       nAxialStep - Int. Numbers of axial "slices" in final microscopy
    %   image.
    %       correctedAxialStepSizeUm - Double. Corrected value for
    %   axialStepSizeUm, to account for the rounding operation used to make
    %   nAxialStep an integer.
    %       nyquistRate - Double. Lateral Nyquist rate (sample per µm).
    %   Corresponds to half of minimal sampling rate to use in order to
    %   obtain an image free of distorsion.
    %
    %   Example
    %   -------
    %       [halfApertureAngleRad, sampleSizeUm, nAxialStep, ...
    %        nyquistRate] = opticalparameters(0.5, 1.33, 1.25, 6.5, 60, ...
    %                                         5, 0.3)
    %   See also psfparameters
    sampleSizeUm = zeros(1, 3);
    % Lateral sample size (µm).
    sampleSizeUm(1:2) = pixelSizeUm / magnification;
    % Maximum angle from which the microscope lens can receive light.
    halfApertureAngleRad = asin(numericalAperture / refractiveIndex);
    % Number of axial samples (µm).
    nAxialStep = 2 * ceil(axialRangeUm / axialStepSizeUm);
    % Correct axial step size to account for previous rounding operation
    sampleSizeUm(3) = 2 * axialRangeUm / (nAxialStep - 1);
    % Lateral Nyquist rate (sample per µm).
    nyquistRate = 2 * numericalAperture / wavelengthUm;
end

function [psfDimensionPx, psfSampleSizeUm] = psfparameters(...
    wavelengthUm, refractiveIndex, imageDimensionPx, axialRangeUm, ...
        lightSheetWidthUm, halfApertureAngleRad, sampleSizeUm, ...
        nyquistRate)
    %psfparameters  Compute sampling parameters for PSF.
    %   Compute and return PSF sampling parameters. They are taken
    %   following Nyquist criterion, in order to avoid under-sampling, thus
    %   capturing all information coming from the microscope. For more
    %   information about Nyquist criterion, see https://svi.nl/NyquistRate
    %
    % 	Inputs
    %   ------
    %       wavelengthUm - Double. Emission wavelength (µm).
    %       refractiveIndex - Double. Refractive index of sample medium.
    %   Common examples are 1.33 for water, 1.51 for oil and 1 for dry
    %   sample.
    %       imageDimensionPx - 1x3 int. Dimensions in voxels (3D pixels) of
    %   final microscopy image in each direction.
    %       axialRangeUm - Double. Imaged area extends from -axialRangeUm
    %   to +axialRangeUm in axial dimension (µm).
    %       lightSheetWidthUm - Double. Full Width at Half Maximum (FWHM)
    %    of Gaussian Point Spread Function (PSF) in axial direction, ie
    %   width of a light sheet (µm). 0 deactivates light-sheet microscopy.
    %       halfApertureAngleRad - Double. Microscope's half aperture
    %   angle. This corresponds to the maximum angle from which light is
    %   received.
    %       sampleSizeUm - 1x3 double. Sample size in each dimension (µm),
    %   also called sampling distance: size of an imaged object that will
    %   be represented by one voxel in final microscopy image.
    %       nyquistRate - Double. Lateral Nyquist rate (sample per µm).
    %   Corresponds to half of minimal sampling rate to use in order to
    %   obtain an image free of distorsion.
    %
    %   Outputs
    %   -------
    %       psfDimensionPx - 1x3 Int. Dimensions of the PSF in voxels 
    %   in each direction, computed so that all information from micrscope
    %   is captured (no under-sampling).
    %       psfSampleSizeUm - 1x3 double. Sample size in each dimension 
    %   (µm), to use for PSF generation. It is the size of an imaged object 
    %   corresponding to one voxel in the PSF.
    %
    %   Example
    %   -------
    %       [psfDimensionPx, psfSampleSizeUm] = psfparameters(...
    %           0.5, 1.33, [256, 256, 50], 5, 2.9, 1.2, ...
    %           [0.1, 0.1, 0.3], 5)
    %
    %   See also opticalparameters
    psfDimensionPx = zeros(1, 3);
    psfSampleSizeUm = zeros(1, 3);
    % Lateral sample size according to Nyquist criterion
    lateralImagedAreaSizeUm = imageDimensionPx(1:2) .* sampleSizeUm(1:2);
    psfDimensionPx(1:2) = 2 * ceil(lateralImagedAreaSizeUm * nyquistRate);
    psfSampleSizeUm(1:2) = lateralImagedAreaSizeUm ./ ...
                           (psfDimensionPx(1:2) - 1);
    % Axial sample size according to Nyquist criterion.
    psfSampleSizeUm(3) = wavelengthUm / (2 * refractiveIndex) / ...
                         (1 - cos(halfApertureAngleRad));
    % Reduce by 20% to account for Gaussian light sheet.
    if lightSheetWidthUm
        psfSampleSizeUm(3) = 0.8 * psfSampleSizeUm(3);
    end
    % Number of axial slices in PSF
    psfDimensionPx(3) = 2 * ceil(axialRangeUm / psfSampleSizeUm(3));
    % Correct axial step size to account for previous rounding operation
    psfSampleSizeUm(3) = 2 * axialRangeUm / (psfDimensionPx(3) - 1);
end