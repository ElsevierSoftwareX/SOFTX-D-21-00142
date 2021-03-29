# Features Extractor
This module applies common features extraction methods to an input 3D microscopy image stack given in .tif file format (*e.g.* the output of Microscopy simulator).

2D features extraction methods are applied to the image's sum projection in axial direction. They are:

* Haralick features,
* Local Binary Patterns (LBP),
* scattering transform features,
* autocorrelation features.

Applied 3D features extraction methods are:

* Haralick features,
* LBP on Three Orthogonal Planes (LBP-TOP),
* scattering transform features of three orthogonal sum projections.

For each method, a one dimensional features vector is obtained, as detailed below.

## 2D features
All 2D features extraction methods are applied on the image sum projection in axial direction.

### Haralick features
Haralick features are a set of 14 coefficients computed from the image's Gray-Levels Co-occurence Matrix (GLCM). A GLCM is a matrix in which element $(i,j)$ is the number of pairs of pixels occurring one with value $i$ and the other with value $j$. Two pixels must be distant from one another by `neighboorhoodSizeGlcm2D` pixels in a certain direction to be considered a pair. `neighboorhoodSizeGlcm2D` is a user input, and as we do not expect a specific orientation in the image, we compute Haralick coefficients for four directions: 0°, 45°, 90° and 135°. Final features vector is the mean of the four Haralick coefficients vectors obtained.

Haralick, R. M., Shanmugam, K., and Dinstein, I. (1973). Textural features for image classification. IEEE Trans. Syst. Man Cybern. 3, 610–621. doi: [10.1109/TSMC.1973.4309314](https://doi.org/10.1109/TSMC.1973.4309314)

### Local Binary Patterns (LBP)
LBP are obtain for each pixel by determining `nNeighborLbp2D` neighbor pixels, from a cirularly symmetric pattern of radius `radiusLbp2D` pixels. Each neighbor is attributed the value 0 if its gray level value is greater than the center pixel's, and 1 else. This produces a binary vector encoding an integer value for the pixel of interest. This process is repeated for each pixel in the image, producing a LBP map of the size of original image. Final features vector is a histogram of values in this LBP map, with $nNeighborLbp \:(nNeighborLbp - 1) +3$ bins.

Ojala, T., Pietikäinen, M., and Mäenpää, T. (2002). Multiresolution gray-scale and rotation invariant texture classification with local binary patterns. IEEE Trans. Pattern Anal. Mach. Intell. 24, 971–987. doi: [10.1109/TPAMI.2002.1017623](https://doi.org/10.1109/TPAMI.2002.1017623)
<a name="scattering"></a>

### Scattering transform features
The scattering transform of an image is a translation and rotation invariant representation obtained with a scattering network. This corresponds to a convolutional network architecture, iterating over wavelet decompositions and complex modulus operations. The scattering network's parameters are: `nLayerScattering2D` its depth, `nScaleScattering2D` the number of wavelet scales in its filter bank, and `nOrientationScattering2D` the number of wavelet orientations. Final features vector is obtained by summing scattering transforms of subsamples of original image. Its length depends on `nLayerScattering2D`, `nScaleScattering2D`, and `nOrientationScattering2D` values.

Rasti, P.; Ahmad, A.; Samiei, S.; Belin, E.; Rousseau, D. Supervised Image Classification by Scattering Transform with Application to Weed Detection in Culture Crops of High Density. Remote Sens. 2019, 11, 249. https://doi.org/10.3390/rs11030249

### Auto-correlation features
An image's auto-correlation function describes the likelihood of two pixels having similar values with respects to their distance and the direction they are aligned in. It can be computed as the inverse Fourier transform of the image's power spectrum, as stated by Wiener-Khinchin theorem. We summarize the autocorrelation function in a final vector of five features: maximum auto-correlation value, full width at half maximum (FWHM) og auto-correlation peak, and maximum gradient, minimum gradient and the variance of the remaining portion of the autocorrelation function profile after removing the central peak.

Ahmad, A., Frindel, C., et Rousseau, D. Detecting differences of fluorescent markers distribution in single cell microscopy: textural or pointillist feature space?. Frontiers in Robotics and AI, 2020, vol. 7, p. 39.


## 3D features

### Haralick features

Haralick features can be extended to 3D images by computation of co-occurence matrices in directions defined by two angles instead of one. In addition to the four directions (0°, 0°), (45°, 0°), (90°, 0°) and (135°, 0°) used in 2D case, nine directions are added: (0°, 45°), (0°, 90°), (0°, 135°), (90°, 45°), (90°, 135°), (45°, 45°), (45°, 135°), (135°, 45°), and (135°, 135°). Distance between two pixels of a pair is defined by user input `neighboorhoodSizeGlcm3D`. Here we extract 12 Haralick coefficients — namely energy, entropy, correlation, contrast, homogeneity, variance, sum mean, inertia, cluster shade, cluster tendency, maximum probability, and inverse variance — on each of the 13 directions, producing a 156 features vector.

Philips C, Li D, Raicu D, Furst D. Directional invariance of co-occurrence matrices within the liver. Paper presented at: BIOTECHNO 2008. Proceedings of the International Conference on Biocomputation, Bioinformatics, and Biomedical Technologies; 2008 Jun 29-Jul5; Bucharest, Romania.

### LBP on Three Orthogonal Planes (LBP-TOP)
2D LBP extraction method can be generalized to 3D images by being applied on three orthogonal planes: XY, YZ and XZ. The number of neighbors considered in each plane analysis can be different, and they are respectively defined by user inputs `nXyNeighborLbptop`, `nXzNeighborLbptop`, and `nYzNeighborLbptop`. In a similar fashion, the radius considered depends on the axis, and is defined by `xRadiusLbptop`, `yRadiusLbptop`, and `zRadiusLbptop` for X, Y and Z respectively. Three histograms — one for each plane — are obtained, containing $2^{nYzNeighborLbptop}$. Final features vector is the concatenation of all values into a vector of length $3\times2^{nYzNeighborLbptop}$.

Guoying Zhao, Matti Pietikainen, "Dynamic texture recognition using local binary patterns with an application to facial expressions" IEEE Transactions on Pattern Analysis and Machine Intelligence, 2007, 29(6):915-928.

### Scattering features
To generalize 2D scattering transform features extraction method, we simply apply it to image's sum projections along x, along y, and along z. Identical parameters are used for all three analyses: `nLayerScattering3D`, `nScaleScattering3D`, `nOrientationScattering3D`. Final features vector is a concatenation of the three features vector obtained as described in [2D case](#scattering). 

## Output formatting
As extracted features vectors have different lengths, results can't be saved as a matrix in a .csv file. We therefore store them in a .json file containing a json object (can be seen as a disctionnary of key-value pairs). Keys are "2D" and "3D", and values are json objects containing keys "Haralick", "LBP" and "Scattering" referring to an array of values: respectively Haralick, LBP and Scattering features vectors. Additionnally, 2D features object contains a key "Autocorrelation" for autocorrelation features. Output file path is given by user input `extractedFeatureJson`.

# Note on parallelization
As this module does not contain any random process, there is no use for additional inputs for parallelization.

# Citations
Following features extraction codes were used. Their output is generally reshaped into a 1xn features vector, but original codes have not been modified. They can be found in ThirdParty sub-directory.

## Cooc3d
cooc3d is used to extract 3D Haralick features.

Carl (2021). cooc3d (https://www.mathworks.com/matlabcentral/fileexchange/19058-cooc3d), MATLAB Central File Exchange. Retrieved March 29, 2021.

## LBPTOP
LBPTOP is used to extract LBP-TOP features.

X. Huang, S. Wang, G. Zhao and M. Piteikäinen, "Facial Micro-Expression Recognition Using Spatiotemporal Local Binary Pattern with Integral Projection," 2015 IEEE International Conference on Computer Vision Workshop (ICCVW), Santiago, Chile, 2015, pp. 1-9, doi: [10.1109/ICCVW.2015.10](https://doi.org/10.1109/ICCVW.2015.10).

>Copyright 2009 by Guoying Zhao & Matti Pietikainen</br>
Matlab version was Created by Xiaohua Huang</br>
If you have any problem, please feel free to contact guoying zhao or Xiaohua Huang.</br>huang.xiaohua@ee.oulu.fi

## ScatNet
ScatNet is used to extract scattering features, as detailed in [its documentation](https://www.di.ens.fr/data/software/scatnet/quickstart-image/).

Andén J, Sifre L, Mallat S, Kapoko M, Lostanlen V, Oyallon E, available at https://www.di.ens.fr/data/software/scatnet/. Retrieved March 1, 2021.

>Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.</br>
You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0</br>
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.</br>
See the License for the specific language governing permissions and limitations under the License.

## Vectorized GLCM Texture features calculations
GLCMFeatures is used for Haralick features extraction in the four 2D directions. 

Patrik Brynolfsson (2021). GLCMFeatures(glcm) (https://www.mathworks.com/matlabcentral/fileexchange/55034-glcmfeatures-glcm), MATLAB Central File Exchange. Retrieved March 22, 2021.

>Copyright (c) 2016, Patrik Brynolfsson</br>
Copyright (c) 2008, Avinash Uppuluri</br>
All rights reserved.</br>
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

>* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution</br>
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## 2D Autocorrelation function
2dAutocorrelationFunction is used for computation of image's 2D autocorrelation function using Wiener - Khintchine theorem. Autocorrelation features are then computed in our own code autocorrelationfeatures.m.
 
Youssef Khmou (2021). 2D Autocorrelation function (https://www.mathworks.com/matlabcentral/fileexchange/37624-2d-autocorrelation-function), MATLAB Central File Exchange. Retrieved March 24, 2021.

>Copyright (c) 2012, Youssef KHMOU</br>
All rights reserved.</br>
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

>* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution</br>
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.