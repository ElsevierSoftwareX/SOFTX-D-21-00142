function featuresextractorstandalone(image3DTif, ...
    neighboorhoodSizeGlcm2D, nNeighborLbp2D, radiusLbp2D, ...
    nLayerScattering2D, nScaleScattering2D, nOrientationScattering2D, ...
    neighboorhoodSizeGlcm3D, nXyNeighborLbptop, nXzNeighborLbptop, ...
    nYzNeighborLbptop, xRadiusLbptop, yRadiusLbptop, zRadiusLbptop, ...
    nLayerScattering3D, nScaleScattering3D, nOrientationScattering3D, ...
    extractedFeatureJson, unlocDetectionCsv, radiusStepRipleyUm, ...
    maxRadiusRipleyUm)
%featuresextractorestandalone  Extract image features.
%   Apply several textural, and optionnally pointillist, features
%   extraction methods to given .tif 3D image stack file.
%   Extracted 2D textural features are Haralick features, Local Binary
%   Patterns (LBP), scattering transform and autocorrelation features. All
%   2D features are extracted from 3D image's z sum projection.
%   Extracted 3D textural features are Haralick features, LBP on Three
%   Orthogonal Planes (LBP-TOP) and scattering transform in x, y and z sum
%   projections.
%   Optionnally, extracted pointillist features are Ripley k-function
%   features.
%   Nothing is returned but extractedFeatureJson is created or overwritten.
%   It is a .json file that will contain a json object with two keys "2D"
%   and "3D". Each key corresponds to a json object with keys "Haralick",
%   "LBP" and "Scattering" referring to a vector of values: respectively
%   Haralick features, LBP and Scattering transform features.
%   Additionnally, 2D features object contains a key "Autocorrelation" for
%   autocorrelation features.
%   If pointillist freatures are extracted, a key "Pointillist" will exist,
%   Corresponding to an object with key "Ripley" for
%   Ripley k-function features.
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
%   Optional Inputs
%   ---------------
%   Following inputs are optional, but all or none should be provided. They
%   are used for pointillist features extraction (Ripley and Vornoi), and
%   are extracted from the output .csv file from UNLOC detection algorithm.
%       unlocDetectionCsv - String. Path to UNLOC detection output .csv
%   file.
%       radiusStepKRipleyUm - Double. Radius step size (µm) for Ripley
%   K-function discretized estimation.
%       maxRadiusKRipleyUm - Double. Maximum radius (µm) for Ripley
%   K-function estimation.
%
%   Notes
%   -----
%       All parameters support strings containing their value, in addition
%   to their aforementionned type.
%       All or none of optional inputs should be provided, depending on
%   if pointillist features extraction should, or not, be performed.
%
%   Example
%   -------
%       featuresextractorestandalone('Path/to/image3D.tif', 8, 8, 1, ...
%   2, 4, 8, 8, 8, 8, 8, 1, 1, 3, 2, 4, 8, 'Path/to/features.json')
%       featuresextractorestandalone('Path/to/image3D.tif', 8, 8, 1, ...
%   2, 4, 8, 8, 8, 8, 8, 1, 1, 3, 2, 4, 8, 'Path/to/features.json', ...
%   'Path/to/UnlocOut.csv', 0.02, 13)
%
%   See also featuresextractor.
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
                           nOrientationScattering3D}, ...
                      {}, {});
% Check if optional arguments are provided
nPointillistArguments = exist('unlocDetectionCsv', 'var') + ...
                        exist('radiusStepRipleyUm', 'var') + ...
                        exist('maxRadiusRipleyUm', 'var');
switch nPointillistArguments
    case 0
        performsPointillist = false;
    case 3
        performsPointillist = true;
        [radiusStepRipleyUm, maxRadiusRipleyUm] = ...
            valuesfromstrings({radiusStepRipleyUm, maxRadiusRipleyUm}, ...
                              {}, {}, {});
        % Read UNLOC detection output file
        % Seven columns table, with lat one being ignored artifical column due to
        % rows ending wth a delimiter. Columns are: time, x coordinate, y
        % coordinate, standard error on coordinates, alpha and standard deviation
        % of background noise.
        unlocTable = readtable(unlocDetectionCsv,'HeaderLines',71);
        % Keep only marker coordinates
        detectedCoordinatesPx = table2array(unlocTable(:,2:3));
        % Read pixel size used for UNLOC detection
        regexpMatch = regexp(fileread(unlocDetectionCsv), ...
            '(?<=pixel2micron = )([0-9.]+)', 'match');
        pixelSizeUm = str2double(regexpMatch{1});
    otherwise
        error("All or none of optional inputs should be provided, " + ...
              "depending on if pointillist features extraction " + ...
              "should, or not, be performed. But only " + ...
              nPointillistArguments + " of them were.");
end
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
if performsPointillist
    disp("Extracting pointillist features.")
    try
        pointillistFeatures = extractPointillistFeatures(...
            detectedCoordinatesPx, pixelSizeUm, radiusStepRipleyUm, ...
            maxRadiusRipleyUm);
    catch exception
        if (strcmp(exception.identifier,'MATLAB:array:SizeLimitExceeded'))
            warning("Can't perform pointillist features extraction, " + ...
                    "too many markers detected : " + ...
                    size(detectedCoordinatesPx, 1))
            performsPointillist = false;
        else
            rethrow(exception)
        end
    end
end
%% Write output file
% Format output as json.
if performsPointillist
    jsonContent = sprintf(['{\n', '\t"2D": %s,\n', '\t"3D": %s,\n', ...
                           '\t"Pointillist": %s\n', '}'], ...
                          jsonencode(feature2D), jsonencode(feature3D), ...
                          jsonencode(pointillistFeatures));
else
    jsonContent = sprintf('{\n\t"2D": %s,\n\t"3D": %s\n}', ...
                          jsonencode(feature2D), jsonencode(feature3D));
end
% For ease of reading, add some newlines and tabulation.
jsonContent = replace(jsonContent, ['{"', "]}", ",", ":["], ...
                      [sprintf('{\n\t\t"'), sprintf(']\n\t}'), ", ", ...
                       ": ["]);
jsonContent = replace(jsonContent, ', "', sprintf(',\n\t\t"'));
% Write in file.
fileIdentifier = fopen(extractedFeatureJson, 'w');
fprintf(fileIdentifier,  '%s', jsonContent);
fclose(fileIdentifier);