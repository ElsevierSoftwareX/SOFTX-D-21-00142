# MicroVIP deployment
MicroVIP has been deployed and is freely accessible on Creatis
[VIP platform](http://vip.creatis.insa-lyon.fr). All files used for this
deployment are avaialbe in this directory. Some of these might prove
useful if you intend to integrate it to other platforms or software. Each file
is further described below.

## Dockerfile
**Dockerfile** is used to generate
[MicroVIP docker image](https://gitlab.in2p3.fr/guillaume.vanel/microvip/-/wikis/MicroVIP%20docker%20image).
The image is publicly available at *adress coming soon*, but its recipe file
can be handy if you need your own custom image for MicroVIP execution.

## Example parameters
**example_parameters.ini** is an extensively commented configuration text file
containing all parameter values needed for all three modules of MicroVIP. It
contains a default parameter set and stands as a customizable example file for
users to tweak values according to their experimental needs. This file is
needed in order to run MicroVIP
[locally via wrapper scripts](https://gitlab.in2p3.fr/guillaume.vanel/microvip/-/wikis/Locally%20run%20wrapper%20scripts)
or
[inside our docker image](https://gitlab.in2p3.fr/guillaume.vanel/microvip/-/wikis/MicroVIP%20docker%20image).

## Terms of use
**termsOfUse.html** contains MicroVIP description and terms of use, as
displayed on [VIP platform](http://vip.creatis.insa-lyon.fr). It notably
contains references to used and modified third-party codes and their licenses.

## VIP Boutiques descriptor
Deployment on [VIP platform](http://vip.creatis.insa-lyon.fr) is done via import
of an application's Boutiques descriptor (for more information, visit
[Boutiques github reository](https://github.com/boutiques/boutiques)).
**microVip\_boutiques\_descriptor.json** is the descriptor for MicroVIP's full
pipeline application.

## VIP workflow's end

Deployment on [VIP platform](http://vip.creatis.insa-lyon.fr) has been made to
take advantage of VIP's ability to run multiple executions in parallel. For this
reason, final workflow consists in a parallel simulation of microscopy images
for multiple cells. **endWorkflow.java** contains a small Java script run at the
end of the workflow, after complete execution of all parallel jobs, in order
to gather results for each individual cell into a single archive, organized
in folders corresponding to each output type (ground truth markers coordinates,
ground truth 3D binary images, simulated microscopy 3D images and extracted
features).