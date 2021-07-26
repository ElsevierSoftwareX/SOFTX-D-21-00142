function mat2tif(filename, matrix, psfHalfWidthPx)
%mat2tif  Save a matrix as a .tif file with given filename.
%   Save a 2D or 3D matrix in .tif image format. There is no output but
%   the .tif output file at given path is created or overwritten.
%   
% 	Inputs
%   ------
%       filename - String. Path where .tif image stack should be saved.
%       matrix - nxm or nxmxp double or uint or logical. Matrix to save as
%   .tif image.
%       psfHalfWidthPx - Double (optional). Used PSF lateral half-width
%   (pixels). If provided, it is included in image's imageDescription tag,
%   so that it can be run by unlocdetect.sh to run UNLOC detection.
%
%   Example
%   -------
%       mat2tif('Path/to/image.tif', rand(10,10,5))
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

if ~isa(matrix, 'logical')
    % Normalize matrix (except if it is logical, which already does not
    % allow values greater than 1).
    matrix = matrix / max(matrix(:));
end
matrix = uint16( double(intmax('uint16')) * matrix );
if nargin > 2
    % For UNLOC, PSF lateral size must be between 0.8 and 2
    psfHalfWidthPx = max(0.8, psfHalfWidthPx);
    psfHalfWidthPx = min(2, psfHalfWidthPx);
    imwrite(squeeze(matrix(:, :, 1)), filename, 'Description', ...
            "PSF size: " + string(psfHalfWidthPx));
else
    imwrite(squeeze(matrix(:, :, 1)), filename);
end
for zSliceNo = 2:size(matrix, 3)
    imwrite(squeeze(matrix(:, :, zSliceNo)), filename, 'WriteMode', ...
            'append'); 
end 