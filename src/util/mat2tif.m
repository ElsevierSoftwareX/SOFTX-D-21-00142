function mat2tif(filename, matrix, flip)
%mat2tif  Save a matrix as a .tif file with given filename.
%   Save a 2D or 3D matrix in .tif image format. There is no output but
%   the .tif output file at given path is created or overwritten.
%   
% 	Inputs
%   ------
%       filename - String. Path where ,tif image stack should be saved.
%       matrix - nxm or nxmxp double or uint or logical. Matrix to save as
%   .tif image.
%
%   Example
%   -------
%       mat2tif('Path/to/image.tif', rand(10,10,5))
if isfile(filename)
    % Overwrite destination file.
    delete(filename);
end
% Normalize matrix (except if it is logical, which already does not allow
% values greater than 1).
if ~isa(matrix, 'logical')
    matrix = matrix / max(matrix(:));
end
matrix = uint16( double(intmax('uint16')) * matrix );
for zSliceNo = 1:size(matrix, 3)
    imwrite(squeeze(matrix(:, :, zSliceNo)), filename, 'WriteMode', ...
            'append'); 
end 