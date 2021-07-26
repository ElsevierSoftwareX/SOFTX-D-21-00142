function coordinateUm = scalecell(coordinateArbitrary, cellSizeUm, ...
                                  radiusArbitrary, prune)
%scalecell   Scale and rotate a point cloud into a ground truth cell in µm.
%   From a raw 3D point cloud in arbitrary unit, prunt it, scale it and 
%   rotate it to form a point cloud of biomarkers in a cell, with 
%   dimensions in µm.
%
% 	Inputs
%   ------
%       coordinateArbitrary - nx3 double. Raw marker coordinates in
%   arbitrary unit.
%       cellSizeUm - Scalar or 1x3 double vector. Size (in µm) of output
%   cell. If a 1x3 double is provided, each value is the size along one
%   axis before random rotation.
%       radiusArbitrary - Scalar. Radius in arbitrary units that will be
%   interpolated to cellSizeUm. The lower the value, the bigger the 
%   magnification is.
%       prune - Logical, optional, defaults to true. If true, markers
%   further away from the origin than radius value will be removed from
%   final cell. Else, the interpolation still considers them as outside
%   the cell, but they will be present in output coordinates matrix.
%
%   Output
%   ------
%       coordinateUm - mx3 double, where m is the number of rows in
%   coordinateArbitrary if prune is false, or less if prune is true. Values
%   are biomarkers coordinates in µm after potential pruning, scaling and
%   rotation.
%
%   Examples
%   --------
%       markersUm = scalecell(rand(10,3), 10, 1, false);
%       markersUm = scalecell(rand(10,3), [5, 6, 7], 0.8, true);
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

if nargin < 4
    prune=true;
end
% Refine point cloud as sphere of given radius
if prune
    distanceFromOrigin = sqrt(sum(coordinateArbitrary.^2, 2));
    coordinateArbitrary = coordinateArbitrary( ...
                            distanceFromOrigin < radiusArbitrary, :); 
end
% Scale through max interpolation
if prune
    maxArbitrary = max(abs(coordinateArbitrary));
else
    maxArbitrary = [radiusArbitrary, radiusArbitrary, radiusArbitrary];
end
coordinateUm = coordinateArbitrary ./ maxArbitrary .* cellSizeUm;
% Random rotation around each axis
coordinateUm = AxelRot(coordinateUm', randi([0 360]), [1 0 0], []); 
coordinateUm = AxelRot(coordinateUm, randi([0 360]), [0 1 0], []); 
coordinateUm = AxelRot(coordinateUm, randi([0 360]), [0 0 1], [])';
