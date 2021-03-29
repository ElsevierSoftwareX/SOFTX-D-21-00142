function featureStruct = extract2dfeatures(image, ...
    neighboorhoodSizeGlcm, nNeighborLbp, radiusLbp, ...
    nLayerScattering, nScaleScattering, nOrientationScattering) 
%extract2dfeatures  Extract 2D textural features from 2 or 3D image.
%   Apply several 2D textural features extraction methods to given image.
%   If the image is 3D, features extraction is performed on its sum z
%   projection. Extracted 2D features are Haralick features, Local Binary
%   Patterns (LBP), scattering transform and autocorrelation features.
%
% 	Inputs
%   ------
%       image - nxm or nxmxp double. Input 2 or 3D gray levels image.
%       neighboorhoodSizeGlcm - Int. Distance (pixels) between paired 
%   pixels for 2D Gray Level Co-occurence Matrix (GLCM) calculation, used
%   in Haralick features extraction.
%       nNeighborLbp - Int. Number of neighbors used to compute the LBP
%   for each pixel. The set of neighbors is selected from a circularly
%   symmetric pattern around each pixel. Higher values encode greater 
%   detail around each pixel. Typical values range from 4 to 24.
%       radiusLbp - Int. Radius (pixels) of circular pattern used to
%   select neighbors for each pixel in LBP calculation. Higher values 
%   capture detail over a larger spatial scale. Typical values range from 1
%   to 5.
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
%       featureStruct - struct with fields "Haralick", "LBP", "Scattering"
%   and "Autocorrelation", each containing a vector of double: respectively
%   Haralick features, LBP, Scattering transform features, and 
%   autocorrelation-derived features. The number of elements in each
%   vector is given by:
%   Haralick             : 14
%   LBP                  : 3 + ( nNeighborLbp * (nNeighborLbp - 1) )
%   Scattering transform : Depends on the parameters
%   Autocorrelation      : 5
%
%   Example
%   -------
%       featureStruct = extract2dfeatures(rand(256, 256, 34), 8, 8, 1, ...
%                                         2, 4, 8);
%
%   See also extract3dfeatures, GLCMFeatures, extractLBPFeatures, scat.

%% Image preparation
% Check if image is 2D, if not use its sum z projection
if size(image, 3) > 1 
   disp("Input image is 3D, extraction is performed on its sum " + ...
        "z-projection."); 
   image2D = sum(image, 3); 
else 
    image2D = image;
end
% Normalized image, will be use for scattering transform.
normalizedImage = image2D / max(image2D(:));
% Convert image to uint8 for better LBP performance, will aslo be used for
% Haralick features extraction.
rescaledImage = uint8(255 * normalizedImage); 
%% Extract Haralick features.
% Array of offsets specifying distance between pixel-of-interest and its
% neighbor (number of pixels in row and column). Here we consider four
% directions: 0°, 45°, 90° and 135°.
offset = [0 1 ; -1 1; -1 0; -1 -1] * neighboorhoodSizeGlcm;
% Gray-Level Co-occurence Matrix.
glcm = graycomatrix(rescaledImage, 'Offset', offset);
% Haralick features in the from of a struct with 1x4 double fields:
%   contrast                         : Contrast.
%   correlation                      : Correlation.
%   differenceEntropy                : Difference entropy.
%   differenceVariance               : Difference variance.
%   dissimilarity                    : Dissimilarity.
%   energy                           : Energy.
%   entropy                          : Entropy.
%   informationMeasureOfCorrelation1 : Information measure of correlation1.
%   informationMeasureOfCorrelation2 : Information measure of correlation2.
%   inverseDifference                : Homogeneity in matlab.
%   sumAverage                       : Sum average.
%   sumEntropy                       : Sum entropy.
%   sumOfSquaresVariance             : Sum of sqaures: Variance.
%   sumVariance                      : Sum variance.
haralickFeatureStruct = GLCMFeatures(glcm);
% Keep the mean of each feature (mean over offset directions).
featureStruct.Haralick = structfun(@mean, haralickFeatureStruct)';
%% Extract LBP features.
featureStruct.LBP= extractLBPFeatures(rescaledImage, ...
                                      'NumNeighbors', nNeighborLbp, ...
                                      'Radius', radiusLbp); 
%% Extract scattering transform features.
% Scattering network and filterbank parameters.
scatteringNetworkOption.M = nLayerScattering; % Number of layers.
filterBankOption.J = nScaleScattering;  % Number of scales.
filterBankOption.L = nOrientationScattering;  %Number of orientations.
linearFilterBank = wavelet_factory_2d(size(normalizedImage), ...
                                      filterBankOption, ...
                                      scatteringNetworkOption);
scatteringTransform = format_scat(scat(normalizedImage, linearFilterBank));
% Final features vector is the sum over the whole image of values for each
% path index.
featureStruct.Scattering = sum(scatteringTransform, [2, 3])';
%% Extract autocorrelation features
% Computed features are:
%   Autocorrelation peak value
%   Peak's Full Width at Half Maximum (FWHM)
%   Variance of autocorrelation profile after peak removal.
%   Maximum gradient of autocorrelation profile after peak removal.
%   Minimum gradient of autocorrelation profile after peak removal.
featureStruct.Autocorrelation = autocorrelationfeatures(...
    double(rescaledImage));