function coordinatePx = coordinatetovoxel(coordinate, ...
    imageDimensionPx, voxelSize)
%coordinatetovoxel  Convert 3D coordinates to positions in a 3D image.
%   From 3D coordinates in space in a distance unit (m, cm ...), compute
%   and return corresponding coordinates in an image of this space, in
%   voxels (3D pixels). The origin of the real spatial coordinates is the
%   center of the imaged space while the origin of output coordinates is
%   the first voxel in the three dimensions (corner of the image).
%
% 	Inputs
%   ------
%       coordinate - mx3 double. 3D spatial coordinates in a distance unit 
%   (m, cm ...), centered around 0.
%       imageDimensionPx - 1x3 int. Dimensions in voxels (3D pixels) of
%   corresponding image in each direction.
%       voxelSize - 1x3 double. Sample size in each dimension in a distance
%   unit (m, cm ...). Also called sampling distance: size of an imaged
%   object that will be represented by one voxel in the image.
%
%   Outputs
%   -------
%       coordinatePx - m'x3 double. 3D coordinates, in voxels. Only
%   objects visible in the image are kept, thus m' can be smaller than
%   m.
%
%   Examples
%   --------
%       coordinatePx = coordinatetovoxel(rand(10,3), [256, 256, 50], ...
%                                        [0.1, 0.1, 0.3]);
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

% Scale coordinates in pixels (centered around 0)
coordinatePx = coordinate ./ voxelSize;
% Shift to center in the image
coordinatePx = ceil(coordinatePx + imageDimensionPx / 2);
% Keep only objects visible in image (shifted coordinate positive and
% inferior to image size)
isInImage = all( (coordinatePx > 0) & ...
                 (coordinatePx <= imageDimensionPx), 2);
coordinatePx = coordinatePx(isInImage, :);