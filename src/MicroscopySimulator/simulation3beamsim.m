function [microscopyImage, lateralResolutionUm] = simulation3beamsim(...
    markerCoordinateUm, wavelengthUm, refractiveIndex, ...
    numericalAperture, axialRangeUm,  lightSheetWidthUm, ...
    imageDimensionPx, sampleSizeUm, psfDimensionPx, psfSampleSizeUm)
%simulation3beamsim  Simulate 3 beam image acquisition.
%   Simulate and return a 3D microscopy image obtained from given cell
%   with a 3 beam Structured Illumination Microscopy (SIM) system. This can
%   be using Light Sheet Microscopy, or not.
%
% 	Inputs
%   ------
%       markerCoordinateUm - nx3 double. Biomarkers 3D coordinates in
%   µm, centered around 0.
%       wavelengthUm - Double. Emission wavelength (µm).
%       refractiveIndex - Double. Refractive index of sample medium. Common
%   examples are 1.33 for water, 1.51 for oil and 1 for dry sample.
%       numericalAperture - Double. Numerical aperture of the optical
%   system.
%       axialRangeUm - Double. Imaged area extends from -axialRangeUm to
%   +axialRangeUm in axial dimension (µm).
%       lightSheetWidthUm - Double. Full Width at Half Maximum (FWHM) of
%   Gaussian Point Spread Function (PSF) in axial direction, ie width of a
%   light sheet (µm). 0 deactivates light-sheet microscopy.
%       imageDimensionPx - 1x3 Int. Dimensions in voxels (3D pixels) of
%   final microscopy image in each direction.
%       sampleSizeUm - 1x3 double. Sample size in each dimension (µm),
%   also called sampling distance: size of an imaged object that will
%   be represented by one voxel in final microscopy image.
%       psfDimensionPx - 1x3 Int. Dimensions of the PSF in voxels 
%   in each direction, computed so that all information from micrscope
%   is captured (no under-sampling).
%       psfSampleSizeUm - 1x3 double. Sample size in each dimension 
%   (µm), to use for PSF generation. It is the size of an imaged object 
%   corresponding to one voxel in the PSF.
%
%   Output
%   -------
%       microscopyImage - nxnxz double. Simulated 2D microscopy image, of
%   size imageDimensionPx.
%       lateralResolutionUm - Double. Microscope lateral resolution (µm):
%   minimal distance between two biomarkers so that they are
%   distinguishable with the microscope.
%
%   Example
%   -------
%       microscopyImage = simulation3beamsim(rand(10, 3), 0.5, 1.33, ...
%       	1.25, 5, 2.9, [256, 256, 50], [0.1, 0.1, 0.2], ...
%           [278, 278, 44], [0.09, 0.09, 0.23]);
%
%   See also microscopysimulator, psfcore, psfwidefield, psfconfocal,
%   psf2beamsim.
%
%   MicroVIP, Microscopy image simulation and analysis tool
%   Copyright (C) 2021  Ali Ahmad, Guillaume Vanel,
%   CREATIS, Universite Lyon 1, Insa de Lyon, Lyon, France.
%
%   This file is part of MicroVIP.
%   MicroVIP is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   any later version.
%
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this program.  If not, see <https://www.gnu.org/licenses/>.

%% Optical parameters
lateralResolutionUm = 0.5 * wavelengthUm / numericalAperture;
% Microscope axial resolution. This value will be ignored by psfcore if
% light sheet microscopy is used (lightSheetWidthUm > 0). In this case,
% axial resolution is indeed determined by lightSheetWidthUm.
defaultAxialResolutionUm = (refractiveIndex * wavelengthUm) / ...
                           numericalAperture^2;
%% PSF computation
psf = psfcore(wavelengthUm, refractiveIndex, numericalAperture, ...
              axialRangeUm, lightSheetWidthUm, imageDimensionPx, ...
              psfDimensionPx, psfSampleSizeUm, lateralResolutionUm, ...
              defaultAxialResolutionUm);
%% Microscopy image simulation.
disp('Creating 3D microscopy image');
axis = arrayfun(@(nStep, factor) linspace(-pi, pi, nStep) / factor, ...
                psfDimensionPx, psfSampleSizeUm, 'UniformOutput', false);
eta = 1;
microscopyImage = zeros([imageDimensionPx(1:2), 7 * imageDimensionPx(3)]);
% Image of point cloud in Fourier domain for each illumination pattern.
for illuminationPatternNo = 1:7
    %% Generate image of biomarkers point cloud in Fourier domain.
    allMarkerFourier = complex( single( zeros(psfDimensionPx) ) );
    for markerNo = 1:size(markerCoordinateUm, 1)
        %% Compute image of one marker in Fourier domain.
        iMarkerX = markerCoordinateUm(markerNo, 1);
        iMarkerY = markerCoordinateUm(markerNo, 2);
        iMarkerZ = markerCoordinateUm(markerNo, 3) + ...
                   sampleSizeUm(3) / 7 * (illuminationPatternNo - 1);
        % Compute illumination pattern.
        phase = eta * 4 * pi * numericalAperture / wavelengthUm;
        phaseShift1 = -illuminationPatternNo * 2 * pi / 7;
        phaseShift2 = illuminationPatternNo * 4 * pi / 7;
        illumination = ( cos( phase * iMarkerY + phaseShift1 - ...
                              phaseShift2 ) + ...
                         cos( (iMarkerY - sqrt(3) * iMarkerX) / 2 * ...
                              phase + phaseShift1 ) + ...
                         cos( (-iMarkerY - sqrt(3) * iMarkerX) / 2 * ...
                              phase + phaseShift2 ) + 3/2 ) * 2/9 ;
        % Compute image of current marker in Fourier domain.
        iMarkerLateral = exp( 1i * single(iMarkerX * axis{1}) ) .'* ...
                         exp( 1i * single(iMarkerY * axis{2}) );
        iMarkerAxial = exp( 1i * single(iMarkerZ * axis{3}) ) * ...
                       illumination;
        % Reshape so taht iMarkerAxial is in axial dimension
        iMarkerAxial = reshape(iMarkerAxial, [1, 1, psfDimensionPx(3)]);
        % Create 3D image by copying iMarkerLateralFourier as many
        % times as their is elements in iMarkerAxialFourier and
        % multiplying each copy by corresponding element.
        iMarkerFourier = bsxfun(@times, iMarkerLateral, iMarkerAxial);
        %% Add current marker's image to whole point cloud image.
        allMarkerFourier = allMarkerFourier + iMarkerFourier;      
    end
    %% Compute microscopy image for current illumination pattern
    ootf = fftshift(fftn(psf)) .* allMarkerFourier;
    microscopyImage(:, :, illuminationPatternNo:7:end) = ...
        abs( ifftn(ootf, imageDimensionPx)); 
end