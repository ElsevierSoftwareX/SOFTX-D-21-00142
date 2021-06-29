# MicroVIP Source code
This folder contains MicroVIP MATLAB source code.

# Structure
The code is organized with one directory for each
[MicroVIP module](https://gitlab.in2p3.fr/guillaume.vanel/microvip/-/wikis/MicroVIP%20modules)
Each of them contains a .m file named after it, that can be considered the core
of the module, as well as a wrapper .m file which name ends with standalone.m.
This wrapper script allows one to execute the module's core, and exports outputs
to a standard file format. It is designed to be compiled as a MATLAB standalone
application, as we did for the deployment in 
[VIP](http://vip.creatis.insa-lyon.fr). Details of each module and its inputs
and outputs can be found [here](https://gitlab.in2p3.fr/guillaume.vanel/microvip/-/wikis/MicroVIP%20modules).

`util` directory contains generic code used by multiple modules, do not forget
to add it to Matlab path when using or compiling any module.

# Terms of use
MicroVIP is an open-source application, developped by Guillaume Vanel
(guillaume.vanel \[at\] creatis.insa-lyon.fr) and Ali Ahmad, and distributed
under the terms of *License coming soon*. It is partially based on third-party
works, used and/or modified as permitted by the terms of their license .
Further description of the modifications and uses made of each work can
be found
[here](https://gitlab.in2p3.fr/guillaume.vanel/microvip/-/wikis/Cell%20generator%20third-party%20codes),
[here](https://gitlab.in2p3.fr/guillaume.vanel/microvip/-/wikis/Microscopy%20simulator%20third-party%20codes),
and [here](https://gitlab.in2p3.fr/guillaume.vanel/microvip/-/wikis/Features%20extractor%20third-party%20codes).