## MicroVIP executables
This directory contains everything needed for MicroVIP execution,
and its content is available inside
[MicroVIP docker image](https://gitlab.in2p3.fr/guillaume.vanel/microvip/-/wikis/MicroVIP%20docker%20image).
More precisely, it contains .sh wrapper scripts for command line execution of
MicroVIP individual modules or complete pipeline. They call appropriate MATLAB
compiled standalone application, generated during installation.

# Running MicroVIP
The different methods to run MicroVIP individual modules or full pipeline
are described
[here](https://gitlab.in2p3.fr/guillaume.vanel/microvip/-/wikis/Getting%20started).
One of these approaches is to
[locally run wrapper scripts](https://gitlab.in2p3.fr/guillaume.vanel/microvip/-/wikis/Locally%20run%20wrapper%20scripts)
available in this directory. Note however that it is not the recommended one.
If you still desire to follow this approach, first ensure to follow the
installation described in previous link, including installation of
dependencies detailed in post-installation steps. Then, you can call any of the
.sh wrapper scripts. Pass `-h` option flag to see usage information, including
inputs, options and outputs description. Don't forget to use `-R` option flag
to indicate your MATLAB or MATLAB runtime root folder (typically on
linux something like: **/usr/local/MATLAB/R2018b**).

# Configuration .ini file
All module take as argument a path to a .ini configuration file, containing
all parameter values. An example configuration file is available in MicroVIP
**Deployment** directory. It is an extensively commented text file that can be
customized to your needs.