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
# Install MATLAB runtime
RUN ulimit -n 10000 \
    && mkdir /mcr-install \
    && cd /mcr-install \
    && wget -nv https://ssd.mathworks.com/supportfiles/downloads/R2018b/deployment_files/R2018b/installers/glnxa64/MCR_R2018b_glnxa64_installer.zip \
    && unzip MCR_R2018b_glnxa64_installer.zip \
    && ./install -mode silent -agreeToLicense yes \
    && rm -Rf /mcr-install
ENV MCRROOT=/usr/local/MATLAB/MATLAB_Runtime/v95
# Install libraries
RUN dnf update -y && dnf install -y \
    dbus-libs \
    libglvnd-glx \
    libstdc++ \
    libxcrypt-compat \
    libXt-devel \
 && dnf clean all
# Remove problematic library
RUN rm $MCRROOT/bin/glnxa64/libmwcoder_types.so
# Last entry adds dipimage libraries
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$MCRROOT/runtime/glnxa64:\
$MCRROOT/bin/glnxa64:$MCRROOT/sys/os/glnxa64:\
$MCRROOT/sys/java/jre/glnxa64/jre/lib/amd64/native_threads:\
$MCRROOT/sys/java/jre/glnxa64/jre/lib/amd64/server:\
$MCRROOT/sys/java/jre/glnxa64/jre/lib/amd64
ENV MCR_CACHE_VERBOSE=true
ENV MCR_CACHE_ROOT=/tmp
WORKDIR /home
# Install MicroVIP
COPY Applications/* /opt/MicroVIP/
ENV PATH=/opt/MicroVIP:$PATH
RUN chmod +x /opt/MicroVIP/*
LABEL description="Container for running MicroVIP application.\n\
See https://www.creatis.insa-lyon.fr/site7/en/PROCHIP for more information."
