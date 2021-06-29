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
binaryImage = zeros(imageDimensionPx, 'logical');
activeVoxels = sub2ind(imageDimensionPx, coordinatePx(:, 1), ...
                       coordinatePx(:, 2), coordinatePx(:, 3));
binaryImage(activeVoxels) = 1;