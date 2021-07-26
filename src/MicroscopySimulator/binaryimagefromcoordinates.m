function binaryImage = binaryimagefromcoordinates(coordinatePx, ...
                                                  imageDimensionPx)
%binaryimagefromcoordinates  Generate a 3D binary image from coordinates.
%   From a list of 3D coordinates in voxels (3D pixels), compute and 
%   return a binary 3D image with corresponding voxels set to 1, and the
%   rest set to 0.
%
% 	Inputs
%   ------
%       coordinatePx - mx3 double. 3D coordinates of "on" voxels.
%       imageDimensionPx - 1x3 int. Dimensions of the 3D image (voxels).
%
%   Outputs
%   -------
%       binaryImage - logical matrix. Generated 3D binary image, of size
%   imageDimensionPx.
%
%   Examples
%   --------
%       binaryImage = binaryimagefromcoordinates(randi(10, [5, 3]), ...
%                                                [10, 10, 10]);
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
binaryImage = zeros(imageDimensionPx, 'logical');
activeVoxels = sub2ind(imageDimensionPx, coordinatePx(:, 1), ...
                       coordinatePx(:, 2), coordinatePx(:, 3));
binaryImage(activeVoxels) = 1;