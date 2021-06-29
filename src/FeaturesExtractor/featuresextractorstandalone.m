function featuresextractorstandalone(image3DTif, ...
    neighboorhoodSizeGlcm2D, nNeighborLbp2D, radiusLbp2D, ...
    nLayerScattering2D, nScaleScattering2D, nOrientationScattering2D, ...
    neighboorhoodSizeGlcm3D, nXyNeighborLbptop, nXzNeighborLbptop, ...
    nYzNeighborLbptop, xRadiusLbptop, yRadiusLbptop, zRadiusLbptop, ...
    nLayerScattering3D, nScaleScattering3D, nOrientationScattering3D, ...
    extractedFeatureJson)
%featuresextractorestandalone  Extract 2 and 3D textural image features.
%   Apply several textural features extraction methods to given .tif 3D
%   image stack file.
%   Extracted 2D features are Haralick features, Local Binary Patterns
%   (LBP), scattering transform and autocorrelation features. All 2D 
%   features are extracted from 3D image's z sum projection.
%   Extracted 3D features are Haralick features, LBP on Three Orthogonal
%   Planes (LBP-TOP) and scattering transform in x, y and z sum
%   projections.
%   Nothing is returned but extractedFeatureJson is created or overwritten.
%   It is a .json file that will contain a json object with two keys "2D"
%   and "3D". Each key corresponds to a json object with keys "Haralick",
%   "LBP" and "Scattering" referring to a vector of values: respectively
%   Haralick features, LBP and Scattering transform features.
%   Additionnally, 2D features object contains a key "Autocorrelation" for
%   autocorrelation features.
%
% 	Inputs
%   ------
%       image3DTif - String. Path to a .tif file containing input 3D gray
%   levels image stack.
%       neighboorhoodSizeGlcm2D - Int. Distance (pixels) between paired 
%   pixels for 2D Gray Level Co-occurence Matrix (GLCM) calculation, used
%   in Haralick features extraction.
%       nNeighborLbp2D - Int. Number of neighbors used to compute the LBP
%   for each pixel. The set of neighbors is selected from a circularly
%   symmetric pattern around each pixel. Higher values encode greater 
%   detail around each pixel. Typical values range from 4 to 24.
%       radiusLbp2D - Int. Radius (pixels) of circular pattern used to
%   select neighbors for each pixel in LBP calculation. Higher values 
%   capture detail over a larger spatial scale. Typical values range from 1
%   to 5.
%       nLayerScattering2D - Int. Maximal order of the scattering
%   transform, i.e. depth of associated scattering network. When set to 1,
%   the scattering transform is merely the modulus of a wavelet transform.
%   In most cases, higher values marginally improve classification results,
%   yet at a great computational cost.
%       nScaleScattering2D - Int. Number of wavelet scales in the filter 
%   bank for scattering trasform computation. Higher values increase the
%   range of translation invariance.
%       nOrientationScattering2D - Int. Number of wavelet orientations for 
%   scattering transform computation. Higher values increase the angular
%   selectivity of filters.
%       neighboorhoodSizeGlcm3D - Int. Distance (pixels) between paired 
%   pixels for 3D GLCM calculation, used in 3D Haralick features
%   extraction.
%       nXyNeighborLbptop, nXzNeighborLbptop, nYzNeighborLbptop - Int. 
%   Number of pixel neighbors respectively in XY, XZ and YZ plane of the 
%   image for LBP-TOP computation. The set of neighbors is selected from a
%   circularly symmetric pattern around each pixel. Higher values encode
%   greater detail around each pixel. Accepted values are 4, 8, 16 and 24,
%   with 8 being recommended.
%       xRadiusLbptop, yRadiusLbptop, zRadiusLbptop - Int. Radius (pixels)
%   of circular pattern used in LBP-TOP computation to select neighbors for
%   each pixel, respectively along first, second and third dimension of the
%   image. Accepted values are 1, 2, 3 and 4, and recommended values are 1
%   and 3. Note that redius * 2 + 1 should be smaller than image size in
%   corresponding dimension. For example, for an image stack of seven
%   images (i.e. size in Z is 7), zRadiusLbptop == 3 means only the pixels
%   in frame 4 can be considered as central pixel and have LBP-TOP features
%   computed.
%       nLayerScattering3D, nScaleScattering3D, nOrientationScattering3D -
%   Int. Same as nLayerScattering2D, nScaleScattering2D and
%   nOrientationScattering2D for 3D scattering transform (i.e. scattering
%   transform of x, y and z sum projections).
%       extractedFeatureJson - String. Path to output .json file that will
%   contain extracted features.
%
%   Notes
%   -----
%       All parameters support strings containing their value, in addition
%   to their aforementionned type.
%
%   Example
%   -------
%       featuresextractorestandalone('Path/to/image3D.tif', 8, 8, 1, ...
%   2, 4, 8, 8, 8, 8, 8, 1, 1, 3, 2, 4, 8, 'Path/to/features.json')
%
%   See also featuresextractor.

%% Handle arguments
% Ensure correct input types (check provided values are integers).
[neighboorhoodSizeGlcm2D, nNeighborLbp2D, radiusLbp2D, ...
 nLayerScattering2D, nScaleScattering2D, nOrientationScattering2D, ...
 neighboorhoodSizeGlcm3D, nXyNeighborLbptop, nXzNeighborLbptop, ...
 nYzNeighborLbptop, xRadiusLbptop, yRadiusLbptop, zRadiusLbptop, ...
 nLayerScattering3D, nScaleScattering3D, nOrientationScattering3D] = ...
    valuesfromstrings({}, {neighboorhoodSizeGlcm2D, nNeighborLbp2D, ...
                           radiusLbp2D, nLayerScattering2D, ...
                           nScaleScattering2D, ...
                           nOrientationScattering2D, ...
                           neighboorhoodSizeGlcm3D, nXyNeighborLbptop, ...
                           nXzNeighborLbptop, nYzNeighborLbptop, ...
                           xRadiusLbptop, yRadiusLbptop, zRadiusLbptop, ...
                           nLayerScattering3D, nScaleScattering3D, ...
                           nOrientationScattering3D}, {}, {});
% Read image file
% Number of images ("Z slices") in image stack
imageInformation = imfinfo(image3DTif);
nImageInStack = numel(imageInformation);
imageStack = zeros([imageInformation(1).Height, ...
                    imageInformation(1).Width,  nImageInStack]);
for imageInStackNo = 1:nImageInStack
    imageStack(:, :, imageInStackNo) = imread(image3DTif, imageInStackNo);
end
%% Extract features
disp("Extracting 2D features.")
feature2D = extract2dfeatures(imageStack, neighboorhoodSizeGlcm2D, ...
                               nNeighborLbp2D, radiusLbp2D, ...
                               nLayerScattering2D, nScaleScattering2D, ...
                               nOrientationScattering2D);
disp("Extracting 3D features.")
feature3D = extract3dfeatures(imageStack, neighboorhoodSizeGlcm3D, ...
                              nXyNeighborLbptop, nXzNeighborLbptop, ...
                              nYzNeighborLbptop, xRadiusLbptop, ...
                              yRadiusLbptop, zRadiusLbptop, ...
                              nLayerScattering3D, nScaleScattering3D, ...
                              nOrientationScattering3D);
%% Write output file
% Format output as json.
jsonContent = sprintf('{\n\t"2D": %s,\n\t"3D": %s\n}', ...
                      jsonencode(feature2D), jsonencode(feature3D));
% For ease of reading, add some newlines and tabulation.
jsonContent = replace(jsonContent, ['{"', "]}", ",", ":["], ...
                      [sprintf('{\n\t\t"'), sprintf(']\n\t}'), ", ", ...
                       ": ["]);
jsonContent = replace(jsonContent, ', "', sprintf(',\n\t\t"'));
% Write in file.
fileIdentifier = fopen(extractedFeatureJson, 'w');
fprintf(fileIdentifier,  '%s', jsonContent);
fclose(fileIdentifier);