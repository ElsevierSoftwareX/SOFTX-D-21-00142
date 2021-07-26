FROM fedora:33
RUN dnf update -y && dnf install -y \
    bash \
    bzip2 \
    crudini \
    findutils \
    gcc \
    unzip \
    wget \
    which \
 && dnf clean all
# Install MATLAB runtime (R2017a for UNLOC and R2018b for MicroVIP)
RUN ulimit -n 10000 \
    && mkdir /mcr-install \
    && cd /mcr-install \
    && wget -nv https://ssd.mathworks.com/supportfiles/downloads/R2018b/deployment_files/R2018b/installers/glnxa64/MCR_R2018b_glnxa64_installer.zip \
    && unzip MCR_R2018b_glnxa64_installer.zip \
    && ./install -mode silent -agreeToLicense yes \
    && rm -Rf /mcr-install
RUN ulimit -n 10000 \
    && mkdir /mcr-install \
    && cd /mcr-install \
    && wget -nv https://ssd.mathworks.com/supportfiles/downloads/R2017a/deployment_files/R2017a/installers/glnxa64/MCR_R2017a_glnxa64_installer.zip \
    && unzip MCR_R2017a_glnxa64_installer.zip \
    && ./install -mode silent -agreeToLicense yes \
    && rm -Rf /mcr-install
# Install libraries
RUN dnf update -y && dnf install -y \
    dbus-libs \
    libglvnd-glx \
    libXcomposite \
    libxcrypt-compat \
    libXrandr \
    libXt-devel \
    mesa-libGLU \
    perl-Image-ExifTool \
 && dnf clean all
# Remove problematic library
RUN rm /usr/local/MATLAB/MATLAB_Runtime/v95/bin/glnxa64/libmwcoder_types.so
# Setup library path for MATLAB
ENV MCR95=/usr/local/MATLAB/MATLAB_Runtime/v95
ENV MCR92=/usr/local/MATLAB/MATLAB_Runtime/v92
RUN rm $MCR92/bin/glnxa64/libmwcoder_types.so $MCR92/sys/os/glnxa64/libstdc++.so.6
ENV MCR_CACHE_VERBOSE=true
ENV MCR_CACHE_ROOT=/tmp

WORKDIR /home
# Install MicroVIP
COPY Applications/ /opt/MicroVIP/
ENV PATH=/opt/MicroVIP:$PATH
RUN chmod +x /opt/MicroVIP/*
LABEL description="Container for running MicroVIP application.\n\
See https://www.creatis.insa-lyon.fr/site7/en/PROCHIP for more information."
