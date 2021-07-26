function psf = psfcore(wavelengthUm, refractiveIndex, ...
                       numericalAperture,axialRangeUm, ...
                       lightSheetWidthUm, imageDimensionPx, ...
                       psfDimensionPx, psfSampleSizeUm, ...
                       lateralResolutionUm, defaultAxialResolutionUm)
%psfcore  Core of PSF simulation for all microscope types.
%   
% 	Inputs
%   ------
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
%       psfDimensionPx - 1x3 Int. Dimensions of the PSF in voxels 
%   in each direction, computed so that all information from micrscope
%   is captured (no under-sampling).
%       psfSampleSizeUm - 1x3 double. Sample size in each dimension 
%   (µm), to use for PSF generation. It is the size of an imaged object 
%   corresponding to one voxel in the PSF.
%       lateralResolutionUm - Double. Microscope lateral resolution (µm):
%   minimal distance between two biomarkers so that they are
%   distinguishable with the microscope.
%       defaultAxialResolutionUm - Double. Default microscope axial
%   resolution. This value will be ignored if light sheet microscopy is
%   used (lightSheetWidthUm > 0). In this case, axial resolution is
%   determined using lightSheetWidthUm.

%   Output
%   ------
%       psf - nxnxz double. Simulated 3D PSF, of size psfDimensionPx.
%
%   Example
%   -------
%       psf = psfcore(0.5, 1.33, 1.25, 5, 2.9, [256, 256, 50], ...
%                     [278, 278, 44], [0.09, 0.09, 0.23], 0.24, 0.32);
%
%   See also microscopysimulatorstandalone.
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
if lightSheetWidthUm
    disp('Using light-sheet microscopy');
    % Approximate axial resolution with standard deviation of light sheet.
    axialResolution = lightSheetWidthUm / 2.355;
else 
    disp('Not using light-sheet microscopy');
    axialResolution = defaultAxialResolutionUm;
end
% Factor by which pupil plane is oversampled
oversampling = lateralResolutionUm ./ psfSampleSizeUm(1:2);
% Define the pupil function as a circle of radius 1.
x = linspace(-oversampling(1), oversampling(1), psfDimensionPx(1));
y = linspace(-oversampling(2), oversampling(2), psfDimensionPx(2));
[x, y] = meshgrid(x, y);
radius = sqrt(x.^2 + y.^2); 
iInPupil = (radius < 1);
%% PSF Generation
psf = zeros(psfDimensionPx);
c = zeros(psfDimensionPx(1:2));
axialStepNo = 1;
disp('Creating 3D PSF');
for z = linspace(-axialRangeUm, axialRangeUm, psfDimensionPx(3))
    c(iInPupil) = exp( 1i * ( z * refractiveIndex / wavelengthUm * ...
                              2 * pi * sqrt(1 - radius(iInPupil).^2 * ...
                                            numericalAperture^2 / ...
                                            refractiveIndex^2) ) );
    psf(:, :, axialStepNo) = abs(fftshift(ifft2(c))).^2 * ...
                             exp(-z^2 / 2 / axialResolution^2);
    axialStepNo = axialStepNo + 1; 
end
% Normalise so that power in resampled psf will be unity in focal plane.
psf = psf * psfDimensionPx(1) * psfDimensionPx(2) / sum(iInPupil(:)) * ...
      imageDimensionPx(3) / psfDimensionPx(3);
