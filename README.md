# About MicroVIP
MicroVIP is part of European project [PROCHIP](https://pro-chip.eu/), you can find more information about it and this project at https://www.creatis.insa-lyon.fr/site7/en/PROCHIP. It consists in a MATLAB microscopy image simulation tool for following microscopy techniques: wide-field, confocal, Structured Illumination Microscopy (SIM), balanced Super-resolution Optical Fluctuation Imaging (bSOFI) and Stochastic Optical Reconstruction Microscopy (STORM). MicroVIP also allows simulation of the imaging of moving cells (microfluidics system) as well as use of Light Sheet Microscopy (LSM).

In addition to performing physically realistic simulation of the microscopy image acquisition process, MicroVIP integrates it into a complete pipeline, organised in three modules:

* CellGenerator models single cell ground truths in the form of 3D coordinates of biomarkers positions;
* MicroscopySimulator simulates the core of the microscopy experiment using chosen technique;
* FeaturesExtractor applies a variety of 2D and 3D image features extraction methods to provide vector representations of obtained microscopy images.

MicroVIP has been deployed in Creatis' Virtual Imaging Platform (VIP), not only making it publicly accessible with a user-friendly graphical interface and without the need to possess computational resources or to install any software, but also allowing parallel generation of multiple cells or multiple image from different microscope configurations. You can access it from [VIP's home page](http://vip.creatis.insa-lyon.fr).

# Structure
The code is organized with one directory for each aforementionned module. Each of them contains a .m file with the same name, that can be considered the core of the module, as well as a wrapper .m file which name ends with standalone.m. This wrapper script allows one to execute the module's core, and exports outputs to standard file formats. It is designed to be compiled as a standalone Matlab application, as we did for the deployment in [VIP](http://vip.creatis.insa-lyon.fr). Details of each module and its inputs and outputs can be found in corresponding directory's README.md.

`util` directory contains generic code used by multiple modules, do not forget to add it to Matlab path when using or compiling any module.

# Terms of use
MicroVIP is an open-source application, developped by Guillaume Vanel (guillaume.vanel \[at\] creatis.insa-lyon.fr) and Ali Ahmad, and distributed under the terms of *License coming soon*. It is partially based on following works, used and/or modified as permitted by the terms of hereafter license notices. Further description of the modifications and uses made of each work can be found in their module's repository.

## InfMod3DGen
Siyu Wang, Jinbo Xu and Jianyang Zeng. Inferential modeling of 3D chromatin structure. Nucleic acids research, 2015: gkv100.

Available at https://github.com/wangsy11/InfMod3DGen. Retrieved March 18, 2020.

Written permission from the author for use for non-commercial research purposes.
## Curvspace
Yo Fukushima (2021). curvspace (https://www.mathworks.com/matlabcentral/fileexchange/7233-curvspace), MATLAB Central File Exchange. Retrieved March 8, 2021.

>Copyright (c) 2016, Yo Fukushima</br>
All rights reserved.</br>
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

>* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution</br>
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## 3D Rotation about Shifted Axis
Matt J (2021). 3D Rotation about Shifted Axis (https://www.mathworks.com/matlabcentral/fileexchange/30864-3d-rotation-about-shifted-axis), MATLAB Central File Exchange. Retrieved March 8, 2021.

>Copyright (c) 2011, Matt Jacobson</br>
All rights reserved.</br>
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

>* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution</br>
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## SOFI Simulation Tool
Girsault A, Lukes T, Sharipov A, Geissbuehler S, Leutenegger M, Vandenberg W, et al. (2016) SOFI Simulation Tool: A Software Package for Simulating and Testing Super-Resolution Optical Fluctuation Imaging. PLoS ONE 11(9): e0161602. https://doi.org/10.1371/journal.pone.0161602

Available at https://www.epfl.ch/labs/lben/lob/page-155720-en-html/sofitool/. Retrieved March 18, 2020.

>Copyright © 2015 Arik Girsault</br>
École Polytechnique Fédérale de Lausanne,</br>
Laboratoire d'Optique Biomédicale, BM 5.142, Station 17, 1015 Lausanne, Switzerland.</br>
arik.girsault@epfl.ch, tomas.lukes@epfl.ch</br>
http://lob.epfl.ch/

>SOFIsim is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.</br>
SOFIsim is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.</br>
You can find a copy of the GNU General Public License at http://www.gnu.org/licenses/.

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
Andén J, Sifre L, Mallat S, Kapoko M, Lostanlen V, Oyallon E, available at https://www.di.ens.fr/data/software/scatnet/. Retrieved March 1, 2021.

>Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.</br>
You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0</br>
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.</br>
See the License for the specific language governing permissions and limitations under the License.

## Vectorized GLCM Texture features calculations
Patrik Brynolfsson (2021). GLCMFeatures(glcm) (https://www.mathworks.com/matlabcentral/fileexchange/55034-glcmfeatures-glcm), MATLAB Central File Exchange. Retrieved March 22, 2021.

>Copyright (c) 2016, Patrik Brynolfsson</br>
Copyright (c) 2008, Avinash Uppuluri</br>
All rights reserved.</br>
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

>* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution</br>
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## 2D Autocorrelation function
Youssef Khmou (2021). 2D Autocorrelation function (https://www.mathworks.com/matlabcentral/fileexchange/37624-2d-autocorrelation-function), MATLAB Central File Exchange. Retrieved March 24, 2021.

>Copyright (c) 2012, Youssef KHMOU</br>
All rights reserved.</br>
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

>* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution</br>
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Related publications
AHMAD, Ali, FRINDEL, Carole, et ROUSSEAU, David. Detecting differences of fluorescent markers distribution in single cell microscopy: textural or pointillist feature space?. Frontiers in Robotics and AI, 2020, vol. 7, p. 39.

A. Ahmad, C. Frindel and D. Rousseau, "Sorting cells from fluorescent markers organization in confocal microscopy: 3D versus 2D images," 2020 Tenth International Conference on Image Processing Theory, Tools and Applications (IPTA), Paris, 2020, pp. 1-6, doi: [10.1109/IPTA50016.2020.9286463](https://doi.org/10.1109/IPTA50016.2020.9286463).

ALI, Ahmad, FRINDEL, Carole, et ROUSSEAU, David. Détection de différence de densité de marqueurs fluorescents en microscopie superrésolue: approche pointilliste ou texturale?. In : XXVIIe colloque Gretsi. 2019.

AHMAD, Ali, RASTI, Pejman, FRINDEL, Carole, et al. Deep learning based detection of cells in 3D light sheet fluorescence microscopy. In : Quantitative BioImaging Conference (QBI 2019). 2019.

T. Glatard, C. Lartizien, B. Gibaud, R. Ferreira da Silva, G. Forestier, F. Cervenansky, M. Alessandrini, H. Benoit-Cattin, O. Bernard, S. Camarasu-Pop, N. Cerezo, P. Clarysse, A. Gaignard, P. Hugonnard, H. Liebgott, S. Marache, A. Marion, J. Montagnat, J. Tabary, and D. Friboulet, A Virtual Imaging Platform for multi-modality medical image simulation, IEEE Transactions on Medical Imaging, vol. 32, no. 1, pp. 110-118, 2013