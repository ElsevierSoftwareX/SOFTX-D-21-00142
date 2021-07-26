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