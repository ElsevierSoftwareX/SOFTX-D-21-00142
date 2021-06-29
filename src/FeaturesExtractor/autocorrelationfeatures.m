function featureVector = autocorrelationfeatures(image2D)
%autocorrelationfeatures Compute autocorrelation features from 2D image.
% From a 2D image of gray levels (from 0 to 255), compute a vector of
% features characterising its autocorrelation function. The five extracted
% features are :
%   Autocorrelation peak value
%   Peak's Full Width at Half Maximum (FWHM)
%   Variance of autocorrelation profile after peak removal.
%   Max gradient of autocorrelation profile after peak removal.
%   Min gradient of autocorrelation profile after peak removal.
%
%   Input
%   -----
%       image2D - mxn double or int. 2D gray level image, with values
%   ranging from 0 to 255.
%
%   Output
%   ------
%       featureVector - 1x5 double. Vector of five extracted features
%   characterizing image's autocorrelation function.
%
%   Example
%   -------
%       featureVector = autocorrelationfeatures(randi(255, 100))
%   
%   See also extract2dfeatues, autocorr2d.

image2D = double(image2D); % Ensure double type.
%% Compute autocorrelation based on Wiener - Khintchine theorem.
autocorrelation = autocorr2d(image2D);
%% First feature: peak value.
peakOfEachRow = max(autocorrelation, [], 2);
[autocorrelationPeak, peakRowNo] = max(peakOfEachRow, [], 1);
%% Second feature: FWHM.
% Following features are computed based on the autocorrelation's row
% containing the peak value.
peakRowProfile = autocorrelation(peakRowNo,:);
% FWHM computation.
halfMaximum = ( min(peakRowProfile) + max(peakRowProfile) ) / 2;
indexOverHalfMaximum = find(peakRowProfile >= halfMaximum);
fwhm = indexOverHalfMaximum(end) - indexOverHalfMaximum(1) + 1; 
%% Third feature: variance after peak removal.
varianceWithoutPeak = var( peakRowProfile(1:indexOverHalfMaximum(1)) );
%% Fourth and fifth features: gradient bounds after peak removal.
gradientAlongMaxRow = gradient(peakRowProfile,1);
gradientWithoutPeak = gradientAlongMaxRow(1:floor(indexOverHalfMaximum(1)-fwhm/2));
[minGrandient, maxGradient] = bounds(gradientWithoutPeak);
%% Output features vector.
featureVector = [autocorrelationPeak, fwhm, varianceWithoutPeak, ...
                  maxGradient, minGrandient];