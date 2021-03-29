# Microscopy simulator
This module simulates a microscopy experiment from input single cell ground truth given in the form of 3D coordinates of biomarkers positions (output of Cell generator).

microscopysimulatorstandalone.m allows simulation for widefield, confocal, and 2-beam and 3-beam Structured Illumination Microscopy (SIM). All these techniques can be used as Light Sheet Microscopy (LSM). Additionally, all except for confocal can be combined with a microfluidic system, by providing a axial cell speed value.

sofistandalone.m allows simulation for balanced Super-resolution Optical Fluctuation Imaging (bSOFI) and Stochastic Optical Reconstruction Microscopy (STORM). It is based on [SOFIsim](#sofi) pipeline, keeping as much of the original work as possible. It therefore does not support LSM nor microfluidics, and contains some differences with microscopysimulatorstandalone simulation method, that are described below.

## Input 3D biomarkers point cloud
Before using this module, one needs to pre-generate a ground truth cell, represented by a 3 column .csv file of 3D biomarkers coordinates, in micrometers and centered in 0. This can be done using Cell generator module. The path to this input file is passed as parameter `markerCoordinateUm` to microscopysimulatorstandalone.m or sofistandalone.m.

## Microscope Point Spread Function (PSF)
The first step of the simulation is to model the optical response of the microscopy system to a light signal. This is done by simulating the microscope PSF, using its optical parameters: `microscope` the microscopy technique used, `wavelengthUm` the emission wavelength (µm), `refractiveIndex` the refractive index of the sample medium, `numericalAperture` the numerical aperture, `magnification` the objective magnification, and `lightSheetWidthUm` the Full Width at Half Maximum (FWHM) of the Gaussian light sheet, if LSM is used.

## Microscopy imaging
The PSF can then be convoluted with the biomarkers point cloud in order to obtain a representation of the fluorescence signal going through the microscopy system. This continuous signal is then sampled as it is recorded by a camera, with discrete pixels. It is also sampled in axial direction, with an axial step size `axialStepUm` given as parameter, or, in the case of a microfluidic system (microscopysimulator only), determined from `cellSpeedUmPerS` the cell speed in the system and `frameRateHz` the camera frame rate. The depth of the image obtained depends on the range of imaged axial positions, which extends from -`axialRangeUm` to +`axialRangeUm` µm, `axialRangeUm` being a user input.

The discrete sampling depends on camera parameters `pixelSizeUm` — the lateral size of a pixel (µm) — and `cameraSizePx` — the camera witdth and length in pixels. 

## Biomarkers' blinking and bleaching
In the case of bSOFI and STORM, the image acquisition has a certain duration `aquisitionDurationS`, during which biomarkers randomly blink on and off. It therefore also depends on biomarkers' characteristics: `markerRadiusNm` their radius (nm), `markerIntensityPhoton` the number of photons emitted by an active biomarker in a camera frame, `backgroundIntensityPhoton` the autofluorescence intensity (light not emitted by biomarkers), and `markerOnLifetimeMs` and `markerOffLifetimeMs` the markers average activity and inactivity times (ms).

Additionally, biomarkers bleaching is simulated. It consists in an inability for markers to become active again after a certain cumulated activity time. This activity time is radom but has an average of `bleachingTimeS` seconds, which is a parameter characteristic of used biomarker type. sofistandalone simulates bleaching for each marker individually. However in microscopysimulatorstandalone, we use a macro simulation of photobleaching, using a factor exponentially diminishing signal with the depth of imaged sample.
<a name="noise"></a>

## Noises and distortions
Once a microscopy image has been sampled, several noises and distortions are applied to mimic physical processes leading to a realistic image as recorded by a camera.

First, in microfluidics case (microscopysimulator only), a motion blur is introduced. It depends on input cell speed `cellSpeedUmPerS` and camera shutter speed `shutterSpeedHz`.

Then, Gaussian and Poisson noises (thermal and readout noises) are applied. Gaussian noise distribution is defined by user inputs `gaussianNoiseMean` and `gaussianNoiseStd`. Note that `gaussianNoiseStd` is enough to increase Gaussian noise intensity, and `gaussianNoiseMean` should thus usually be left equal to 0. In sofistandalone's case this is not an option, it is always considered 0. Poisson noise distribution depends on the biomarkers fluorescence intensity `markerIntensityPhoton`, as well as (in sofistandalone only) on backround fluorescence intensity `backgroundIntensityPhoton`.

Additionally, sofistandalone introduces a stochastic thermal generation of electrons within the CCD structure given by user input `darkCurrent`. It also models the random aspect of photoelectron conversion and electron multiplication, using a gamma distribution of scale parameter `quantumGain`, representing the mean number of electrons generated for one incoming photon.

## Super-resolution
After the recording of biomarkers signal, sofistandalone applies chosen super-resolution algorithm (bSOFI or STORM), producing a final microscopy image larger than `cameraSizePx`. As [SOFIsim](#sofi) is initially intended for 2D microscopy, this algorithm is applied independently on each axial "slice". Only the final normalization and contrast adjustment is applied on the whole reconstructed 3D image.

## Ground truth binary image
In addition to final 3D microscopy image stack, this module generates a 3D binary image stack of biomarkers point cloud. It consists in a 3D image with the same dimensions as final microscopy image, with values 1 at biomarkers positions and 0 everywhere else.

## Output formatting
Obtained 3D images (microscopy image and ground truth binary image) are both saved in the form of .tif image stacks. Output file paths are given by user inputs `finalImageTif` and `groundTruthTif`.

# Note on parallelization
Both microscopysimulatorstandalone.m and sofistandalone.m are intended to be usable as compiled standalone applications, as was done with our deployment on Creatis' [Virtual Imaging Platform (VIP)](http://vip.creatis.insa-lyon.fr). In that case, successive or parallel runs of the standalone might generate non-independant outputs. This is due to MATLAB's pseudo-random number generator initialization based on current time. For example, two parallel executions with the same input cell at the exact same timestamp on two different computers might lead to two identical outputs, even though [noise generation](#noise) should be random. To avoid this behavior and ensure statistically independant outputs, three optional inputs have been created: `randomSeed`, `iCell`, and `nCell`.

They allow one to launch `nCell` independant executions by initialization of MATLAB pseudo-number generator using `nCell` independant [random number streams](https://fr.mathworks.com/help/matlab/ref/randstream.html). In that purpose, one must choose a unique random seed `randomSeed`. It must be an integer between $0$ and $2^{32}-1$. For reproducible results one can choose a fixed value (*i.e.* $1$), but in other situations, one can use current timestamp (in bash: `date +%s`). One can then launch each of the `nCell` executions with the same values for `randomSeed` and `nCell`, but with each a different value for `iCell`, ranging from 1 ro `nCell`.

# Citations
sofistandalone.m is based on following work.
<a name="sofi"></a>

## SOFI Simulation Tool
SOFIsim is used to generate bSOFI and STORM microscopy images. As it is originally distributed as a graphical interface tool integrating its own biomarkers point cloud generation, a wrapper script sofistandalone.m has been written in order to incorporate it to MicroVIP's pipeline. This script consists in modified parts of original implementation and calls to unmodified functions, surrounded by personnal code. Original SOFIsim implementation can be accessed in ThirdParty/sofitool. Writing process of sofistandalone.m is described below:

* Reconstruction of SOFIsim graphical interface tool's pipeline, and reformulation into a command line MATLAB script sofistandalone.m;
* Removal of integrated biomarkers point cloud generation;
* Addition of 3D imaging capabilities by using original 2D algorithm and applying it independently on each axial "slice" of imaged sample. Only normalization and contrast adjustment are performed at the end on final 3D resulting image;
* Slight changes in input parameters (units notably) to make it compatible with microscopysimulatorstandalone.m;
* Selection of output variables of interest.

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