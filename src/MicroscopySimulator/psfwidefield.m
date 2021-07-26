function [psf, lateralResolutionUm] = psfwidefield(...
    wavelengthUm, refractiveIndex, numericalAperture, axialRangeUm, ...
    lightSheetWidthUm, imageDimensionPx, psfDimensionPx, psfSampleSizeUm)
%psfwidefield  Simulate widefield microscope Point Spread Function (PSF).
%   Simulate and return theoritical PSF for a widefield microscope. This
%   can be using Light Sheet Microscopy, or not.
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
%
%   Output
%   -------
%       psf - nxnxz double. Simulated 2D microscopy image, of
%   size imageDimensionPx.
%       lateralResolutionUm - Double. Microscope lateral resolution (µm):
%   minimal distance between two biomarkers so that they are
%   distinguishable with the microscope.
%
%   Example
%   -------
%       psf = psfwidefield(0.5, 1.33, 1.25, 5, 2.9, [256, 256, 50], ...
%                          [278, 278, 44], [0.09, 0.09, 0.23]);
%
%   See also psfcore, psfconfocal, psf2beamsim, simulation3beamsim.
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
lateralResolutionUm = 0.61 * wavelengthUm / numericalAperture;
% Microscope axial resolution. This value will be ignored by psfcore if
% light sheet microscopy is used (lightSheetWidthUm > 0). In this case,
% axial resolution is indeed determined by lightSheetWidthUm.
defaultAxialResolutionUm = 0.75 * (refractiveIndex * wavelengthUm) / ...
                           numericalAperture^2;
%% PSF computation
psf = psfcore(wavelengthUm, refractiveIndex, numericalAperture, ...
              axialRangeUm, lightSheetWidthUm, imageDimensionPx, ...
              psfDimensionPx, psfSampleSizeUm, lateralResolutionUm, ...
              defaultAxialResolutionUm);
