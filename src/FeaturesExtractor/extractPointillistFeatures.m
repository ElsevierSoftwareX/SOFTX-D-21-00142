function featureStruct = extractPointillistFeatures(...
    detectedCoordinatesPx, pixelSizeUm, radiusStepKRipleyUm, ...
    maxRadiusKRipleyUm, minClusterSizeVoronoi, maxClusterSizeVoronoi)
%extractPointillistFeatures  Extract pointillist features UNLOC output.
%   Apply several pointillist features extraction methods to given UNLOC
%   detection output. Extracted features are Ripley's K-function features
%   and Voronoi segmentation features.
%
% 	Inputs
%   ------
%       detectedCoordinatesPx - nx2 double. 2D coordinates (pixels) of
%   the n markers detected by UNLOC detection algorithm.
%       pixelSizeUm - Double. Pixel size (µm) used by UNLOC detection.
%       radiusStepKRipleyUm - Double. Radius step size (µm) for Ripley
%   K-function discretized estimation.
%       maxRadiusKRipleyUm - Double. Maximum radius (µm) for Ripley
%   K-function estimation.
%       minClusterSizeVoronoi, maxClusterSizeVoronoi - Doubles. Minimum
%   and maximum number of markers in a cluster for Voronoi features
%   extraction.
%
%   Output
%   ------
%       featureStruct - struct with fields "Ripley" and "Voronoi", each
%   containing a vector of double: respectively Ripley and Voronoi
%   features. The number of elements in each vector is given by:
%   Ripley	: 6
%   Voronoi : Depends on the number of identified clusters
%
%   Example
%   -------
%       featureStruct = extractPointillistFeatures(200 * rand(10,2), ...
%   0.02, 13, 5, 50)
%
%   See also extract2dfeatures, extract3dfeatures.

detectedCoordinatesUm = detectedCoordinatesPx * pixelSizeUm;
%% Ripley K-function features
radiusUm = double(0:radiusStepKRipleyUm:maxRadiusKRipleyUm);
% Region of interest is whole image, can be slow if there is a large
% number of points.
regionOfInterest = [0, max(detectedCoordinatesUm(:,1)), 0, ...
                    max(detectedCoordinatesUm(:,2))]; %
kFunction = kfunction(detectedCoordinatesUm, radiusUm, ...
                            regionOfInterest);
% Normalized as proposed by Besag (1977)
kFunction = (sqrt(kFunction' ./ pi)) - radiusUm;
% Extract six Ripley features:
%   Maximum K-function value (reached at radius = rmax)
%   Maximum of gradient for radius in [0, rmax]
%   Minimum of gradient for radius in [rmax, maxRadiusKRipleyUm]
%   rmax
%   Pearson correlation between K-function and radius values
%   Spearman correlation between K-function and radius values
[kFunctionMax, maximumIndex] = max(kFunction);
kFunctionGradient = gradient(kFunction, 1);
featureStruct.Ripley = [kFunctionMax, ...
                        max(kFunctionGradient(1:maximumIndex)), ...
                        min(kFunctionGradient(maximumIndex:end)), ...
                        radiusUm(maximumIndex), ...
                        corr(radiusUm', kFunction'), ...
                        corr(radiusUm', kFunction', ...
                             'type', 'Spearman')];
%% Voronoi tessellation features
% Mask of ones representing the region of interest (whole image)
maskSizePx = ceil(max(detectedCoordinatesPx(:)));
regionOfInterestMask = ones(maskSizePx);
% Third party code sharpvisu uses data with columns 4 and 5 being
% coordinates
offset = zeros(size(detectedCoordinatesPx, 1), 3);
detectedCoordinatesPx = [offset, detectedCoordinatesPx];
detectedCoordinatesNm = [offset, detectedCoordinatesUm * 1000];
% Monte carlo simulation for threshold computation
[~, thresholdNm2] = VoronoiMonteCarlo(detectedCoordinatesNm, ...
                                      regionOfInterestMask, 100, 99);
thresholdPx2 = thresholdNm2(1) / (1000 * pixelSizeUm) ^ 2;
% VoronoiSegmentation
segmentedImageSizePx = ceil(max(detectedCoordinatesPx(:))) + 1;
[~, clustersFeature] = VoronoiSegmentation(...
    detectedCoordinatesPx, thresholdPx2, 1, ...
    [minClusterSizeVoronoi, maxClusterSizeVoronoi], ...
    segmentedImageSizePx);
% Extract seven Voronoi segmentation features:
%   Number of localized markers
%   Number of clustering markers
%   Number of clusters
%   Number of markers in each cluster
%   Area of each cluster areas (um^2)
%   Equivalent diameter of each cluster (um)
%   Average cluster area (um^2)
nMarkerInClusters = double(cell2mat(clustersFeature(:,2))); 
clustersAreaUm2 = double(cell2mat(clustersFeature(:,3))) * ...
                  (pixelSizeUm^2);
clustersDiameterUm = double(cell2mat(clustersFeature(:,4))) * ...
                     pixelSizeUm;
featureStruct.Voronoi = [size(detectedCoordinatesPx,1), ...
                         sum(nMarkerInClusters), ...
                         size(nMarkerInClusters, 1), ...
                         nMarkerInClusters', ...
                         clustersAreaUm2', ...
                         clustersDiameterUm', ...
                         mean(clustersAreaUm2)];