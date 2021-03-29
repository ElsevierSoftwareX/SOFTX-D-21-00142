# Cell generator
This module models single cell ground truths in the form of 3D coordinates of biomarkers positions. Our method for generating biologically plausible biomarkers positions is described below.
<a name="database"></a>

## Chromatin chains configurations database
Before using this module, one needs to pre-generate chromatin chain configurations. This is done using the code from following article as explained hereafter.

Siyu Wang, Jinbo Xu and Jianyang Zeng. Inferential modeling of 3D chromatin structure. Nucleic acids research, 2015: gkv100.

* Download [InfMod3DGen](https://github.com/wangsy11/InfMod3DGen)

```bash
$ git clone https://github.com/wangsy11/InfMod3DGen.git
```
* Add it to your MATLAB path

```matlab
>> addpath('~/Downloads/InfMod3DGen')
```
* Create 100 configurations for each of the 16 chromatin chains in yeast genome

```matlab
>> for chromosomeNo = 1:16
	ChrMod_main(chromosomeNo, 100)
end
```
* Create a directory to store generated configuration files

```bash
$ mkdir ChromatinChainDatabase
$ mv 100*.mat ChromatinChainDatabase/
```
Each of the 16 .mat files generated this way contains a variable `n` representing the number of configurations in the file (here 100) and a variable `Ensemble` representing the `n` configurations. `Ensemble` is a `n x m x 3` matrix, where each row stands for one configuration and the other dimensions indicate the 3D coordinates of the `m` points constituting the chromatin chain.

## Cell generation
A cell's DNA is modeled as `nChain` chromatin chains  with different configurations. If user input `nChain` is the same as the number of files in chromatin chains configuration database (should be 16), one random configuration is picked from each file. This corresponds to a cell with the 16 chromosomes of yeast genome, each in a random configuration. However, CellGenerator also supports higher values for `nChains`, in order to allow generation of cells with higher DNA density. In that case, one random configuration is picked for each chromosome, then another different one is also picked, and we loop until we reach `nChain` chains.

## Biomarkers positions
Biomarkers are then distributed along the cell's chromatin chains. They are placed by following every chromatin chain one by one, and fixing one biomarker at current position as soon as a certain distance from the last one has been traveled. These distances are distances along the chromatin chain, not Euclidian distances in space, and they are picked from a random distribution `markerDistribution` given as input of cellgeneratorstandalone.

## Cell rescaling and reshaping
Once we have a biomarkers point cloud, a step of reshaping and rescaling is performed. User input `radiusArbitrary` determines a sphere with the same center as the cell, and biomarkers outside the sphere are removed, in order to keep a cell of somewhat spherical shape (this behavior can be suppressed by setting user input `prune` to false). Then the point cloud is rescaled so that cell length in each of the three major axes becomes equal to a random cell size picked from input distribution `cellDistribution`. Finally, a random 3D rotation is applied in order to add variability even for cells that could have the same chromatin chain configurations.

## Output formatting
Obtained 3D point cloud of biomarkers positions is saved in the form of a .csv 3 columns file, in which each row represents a biomarker and each column its coordinate along one axis. Values are in micrometers and the cell is centered around 0. Output file path is given by user input `outputCsv`.

# Note on parallelization
cellgeneratorstandalone is intended to be usable as a compiled standalone application, as was done with our deployment on Creatis' [Virtual Imaging Platform (VIP)](http://vip.creatis.insa-lyon.fr). In that case, successive or parallel runs of the standalone might generate non-independant outputs. This is due to MATLAB's pseudo-random number generator initialization based on current time. For example, two parallel executions at the exact same timestamp on two different computers might lead to two identical outputs. To avoid this behavior and ensure statistically independant outputs, three optional inputs have been created: `randomSeed`, `iCell`, and `nCell`.

They allow one to generate `nCell` independant cells by initialization of MATLAB pseudo-number generator using `nCell` independant [random number streams](https://fr.mathworks.com/help/matlab/ref/randstream.html). In that purpose, one must choose a unique random seed `randomSeed`. It must be an integer between $0$ and $2^{32}-1$. For reproducible results one can choose a fixed value (*i.e.* $1$), but in other situations, one can use current timestamp (in bash: `date +%s`). One can then launch each of the `nCell` executions with the same values for `randomSeed` and `nCell`, but with each a different value for `iCell`, ranging from 1 ro `nCell`.

# Citations
Cell Generator is based on following works.

## InfMod3DGen
InfMod3DGen is used to generate chromatin configurations — as explained in [Chromatin chains configurations database](#database) — with written permission from the author for use for non-commercial research purposes.

Siyu Wang, Jinbo Xu and Jianyang Zeng. Inferential modeling of 3D chromatin structure. Nucleic acids research, 2015: gkv100.

Available at https://github.com/wangsy11/InfMod3DGen. Retrieved March 18, 2020.
## Curvspace

Curspace allows generation of a given number of points along a curve with equal spacing. It has been modified into pointsoncurve.m, that positions points along a curve with distances picked from an input random distribution. The number of points is not predefined anymore, but depends on the distances picked.

Yo Fukushima (2021). curvspace (https://www.mathworks.com/matlabcentral/fileexchange/7233-curvspace), MATLAB Central File Exchange. Retrieved March 8, 2021.

>Copyright (c) 2016, Yo Fukushima</br>
All rights reserved.</br>
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

>* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution</br>
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## 3D Rotation about Shifted Axis
AxelRot.m is used and redistributed as is, in ThirdParty sub-directory.

Matt J (2021). 3D Rotation about Shifted Axis (https://www.mathworks.com/matlabcentral/fileexchange/30864-3d-rotation-about-shifted-axis), MATLAB Central File Exchange. Retrieved March 8, 2021.

>Copyright (c) 2011, Matt Jacobson</br>
All rights reserved.</br>
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

>* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution</br>
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.