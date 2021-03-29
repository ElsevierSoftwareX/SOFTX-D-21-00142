# Third party
Following features extraction codes are redistributed as is. They are used in Features extractor module as described below.

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