# About MicroVIP
>>>
MicroVIP, Microscopy image simulation and analysis tool \
Copyright (C) 2021  Ali Ahmad, Guillaume Vanel, \
CREATIS, Universite Lyon 1, Insa de Lyon, Lyon, France.

MicroVIP is free software: you can redistribute it and/or modify \
it under the terms of the GNU General Public License as published by \
the Free Software Foundation, either version 3 of the License, or \
any later version.

This program is distributed in the hope that it will be useful, \
but WITHOUT ANY WARRANTY; without even the implied warranty of \
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the \
GNU General Public License for more details. 

ou should have received a copy of the GNU General Public License \
along with this program.  If not, see <https://www.gnu.org/licenses/>.
>>>

MicroVIP is part of European project [PROCHIP](https://pro-chip.eu/), you can
find more information about it and this project at
https://www.creatis.insa-lyon.fr/site7/en/PROCHIP. It consists in a MATLAB
microscopy image simulation tool for following microscopy techniques:
wide-field, confocal, Structured Illumination Microscopy (SIM), balanced
Super-resolution Optical Fluctuation Imaging (bSOFI) and Stochastic Optical
Reconstruction Microscopy (STORM). MicroVIP also allows simulation of the
imaging of moving cells (microfluidics system) as well as use of Light Sheet
Microscopy (LSM).

In addition to performing physically realistic simulation of the microscopy
image acquisition process, MicroVIP integrates it into a complete pipeline,
organised in three modules:

* CellGenerator models single cell ground truths in the form of 3D coordinates
of biomarkers positions;
* MicroscopySimulator simulates the core of the microscopy experiment using
chosen technique;
* FeaturesExtractor applies a variety of 2D and 3D image features extraction
methods to provide vector representations of obtained microscopy images.

MicroVIP has been deployed in Creatis' Virtual Imaging Platform (VIP), not only
making it publicly accessible with a user-friendly graphical interface and
without the need to possess computational resources or to install any software,
but also allowing parallel generation of multiple cells or multiple image from
different microscope configurations. You can access it from
[VIP's home page](http://vip.creatis.insa-lyon.fr).

Complete documentation for MicroVIP is available in the
[project's wiki](https://gitlab.in2p3.fr/guillaume.vanel/microvip/-/wikis/home).

# Repository structure
## src
**src** directory contains MATLAB source code, organized with one directory for
each aforementionned module. Details of each module and its inputs and outputs
can be found in the
[project's wiki](https://gitlab.in2p3.fr/guillaume.vanel/microvip/-/wikis/home).

## Applications
**Applications** directory contains everything needed for MicroVIP execution,
and its content is available inside
[MicroVIP docker image](https://gitlab.in2p3.fr/guillaume.vanel/microvip/-/wikis/MicroVIP%20docker%20image).
More precisely, it contains .sh wrapper scripts for command line execution of
MicroVIP individual modules or complete pipeline. They call appropriate MATLAB
compiled standalone application, generated during installation. 

## Deployment
**Deployment** directory contains files used for MicroVIP deployment in Creatis
[VIP platform](http://vip.creatis.insa-lyon.fr). Some of these might prove
useful if you intend to integrate it to other platforms or software. It
notably contains the **Dockerfile** to generate [MicroVIP docker image](https://gitlab.in2p3.fr/guillaume.vanel/microvip/-/wikis/MicroVIP%20docker%20image)
if you need your own custom image for MicroVIP execution.

# Getting started
To learn how to run (and if needed install) MicroVIP, please refer to
[this documentation](Getting started).

# Contact and terms of use
Please refer to the project's wiki
[Contact](https://gitlab.in2p3.fr/guillaume.vanel/microvip/-/wikis/Contact)
page if you need to reach us.

You can find references for all third-party works we used and/or modified
[here](https://gitlab.in2p3.fr/guillaume.vanel/microvip/-/wikis/Cell%20generator%20third-party%20codes),
[here](https://gitlab.in2p3.fr/guillaume.vanel/microvip/-/wikis/Microscopy%20simulator%20third-party%20codes),
and [here](https://gitlab.in2p3.fr/guillaume.vanel/microvip/-/wikis/Features%20extractor%20third-party%20codes).