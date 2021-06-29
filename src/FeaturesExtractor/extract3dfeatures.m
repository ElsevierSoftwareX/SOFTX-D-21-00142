function featureStruct = extract3dfeatures(imageStack, ...
    neighboorhoodSizeGlcm, nXyNeighborLbptop, nXzNeighborLbptop, ...
    nYzNeighborLbptop, xRadiusLbptop, yRadiusLbptop, zRadiusLbptop, ...
    nLayerScattering, nScaleScattering, nOrientationScattering)
%extract3dfeatures  Extract 3D textural features from 3D image stack.
%   Apply several 3D textural features extraction methods to given image.
%   Extracted features are 3D Haralick features, Local Binary
%   Patterns on Three Orthogonal Planes (LBP-TOP) and scattering transform
%   of the three orthogonal sum-projections.
%
% 	Inputs
%   ------
%       imageStack - nxmxp double. Input 3D gray levels image stack.
%       neighboorhoodSizeGlcm - Int. Distance (pixels) between paired 
%   pixels for 3D GLCM calculation, used in Haralick features extraction.
%       nXyNeighborLbptop, nXzNeighborLbptop, nYzNeighborLbptop - Int. 
%   Number of pixel neighbors respectively in XY, XZ and YZ plane of the 
%   image for LBP-TOP computation. The set of neighbors is selected from a
%   circularly symmetric pattern around each pixel. Higher values encode
%   greater detail around each pixel. Accepted values are 4, 8, 16 and 24,
%   with 8 being recommended.
%       xRadiusLbptop, yRadiusLbptop, zRadiusLbptop - Int. Radius (pixels)
%   of circular pattern used in LBP-TOP computation to select neighbors for
%   each pixel, respectively along first, second, and third dimension of
%   image. Accepted values are 1, 2, 3 and 4, and recommended values are 1
%   and 3. Note that redius * 2 + 1 should be smaller than image size in
%   corresponding dimension. For example, for an image stack of seven
%   images (i.e. size in Z is 7), zRadiusLbptop == 3 means only the pixels
%   in frame 4 can be considered as central pixel and have LBP-TOP features
%   computed.
%       nLayerScattering - Int. Maximal order of the scattering
%   transform, i.e. depth of associated scattering network. When set to 1,
%   the scattering transform is merely the modulus of a wavelet transform.
%   In most cases, higher values marginally improve classification results,
%   yet at a great computational cost.
%       nScaleScattering - Int. Number of wavelet scales in the filter 
%   bank for scattering trasform computation. Higher values increase the
%   range of translation invariance.
%       nOrientationScattering - Int. Number of wavelet orientations for 
%   scattering transform computation. Higher values increase the angular
%   selectivity of filters.
%
%   Output
%   ------
%       featureStruct - struct with fields "Haralick", "LBP" and
%   "Scattering", each containing a vector of double: respectively
%   Haralick features, LBP-TOP and Scattering transform features.
%   The number of elements in each vector is given by:
%   Haralick             : 156
%   LBP-TOP              : 3 * (2 ^ nYzNeighborLbptop)
%   Scattering transform : Depends on the parameters
%
%   Example
%   -------
%       featureStruct = extract3dfeatures((rand(256, 256, 34), 8, 8, 8, ...
%                                         8, 1, 1, 3, 2, 4, 8);
%
%   See also extract2dfeatures, cooc3d, LBPTOP, scat.

%% Handle parameters
% Convert to double to avoid errors while handling ints in third party
% functions.
doubleValues = arrayfun(@double, [neighboorhoodSizeGlcm, ...
                                  nXyNeighborLbptop, nXzNeighborLbptop, ...
                                  nYzNeighborLbptop, xRadiusLbptop, ...
                                  yRadiusLbptop, zRadiusLbptop, ...
                                  nLayerScattering, nScaleScattering, ...
                                  nOrientationScattering], ...
                        'UniformOutput', false);
[neighboorhoodSizeGlcm, nXyNeighborLbptop, nXzNeighborLbptop, ...\
 nYzNeighborLbptop, xRadiusLbptop, yRadiusLbptop, zRadiusLbptop, ...
 nLayerScattering, nScaleScattering, nOrientationScattering] = ...
    doubleValues{:};
%% Image preparation.
% Ensure image is 3D.
if size(imageStack, 3) == 1 
   error('Input image should be 3D, but third dimansion is singleton'); 
end
% Normalized image, will be use for scattering transform.
normalizedImage = imageStack / max(imageStack(:));
% Rescale image, so that values are integers from 0 to 255.
rescaledImage = double( uint8(255 * normalizedImage) ); 
%% Extract Haralick features.
featureStruct.Haralick = cooc3d(rescaledImage, 'distance', ...
                                neighboorhoodSizeGlcm, 'numgray', 8);
%% Extract LBP-TOP features.
nNeighborsLbptop = [nXyNeighborLbptop, nXzNeighborLbptop, ...
                    nYzNeighborLbptop];
% 3 x (2 ^ nYzNeighborLbptop) LBP-TOP matrix.
lbptopMatrix = LBPTOP(rescaledImage, xRadiusLbptop, yRadiusLbptop, ...
                      zRadiusLbptop, nNeighborsLbptop, zRadiusLbptop, ...
                      max(xRadiusLbptop, yRadiusLbptop), 1, 0, 0);
% Reshape in 1D features vector.
featureStruct.LBP = reshape(lbptopMatrix', 1, []);
%% Extract scattering transform features.
% Scattering network and filterbank parameters.
scatteringNetworkOption.M = nLayerScattering; % Number of layers.
filterBankOption.J = nScaleScattering;  % Number of scales.
filterBankOption.L = nOrientationScattering;  %Number of orientations.
% Extract scattering features for three orthogonal sum projections.
scatteringFeatures = cell(1, 3);
for axisNo = 1:3
    sumProjection = squeeze( sum(normalizedImage, axisNo) );
    linearFilterBank = wavelet_factory_2d(size(sumProjection), ...
                                          filterBankOption, ...
                                          scatteringNetworkOption);
    scatteringTransform = format_scat( scat(sumProjection, ...
                                            linearFilterBank) );
    % Features vector is the sum over the whole image of values for each
    % path index.
    scatteringFeatures{axisNo} = sum(scatteringTransform, [2, 3])';
end
% Concatenate features of each projection.
featureStruct.Scattering = cell2mat(scatteringFeatures);