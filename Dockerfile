FROM ubuntu:latest AS Builder

#https://github.com/tiltedphoques/TiltedOnline/blob/master/.ci/linux-build.yml

WORKDIR /root/

#Install
RUN \ 
    apt-get update \
    && apt-get install -y  \
        software-properties-common \
    && add-apt-repository ppa:ubuntu-toolchain-r/test \
    && apt-get update \
    && apt-get install -y  \
        g++-10 \
        g++-10-multilib \
        git \
        git-lfs \
        build-essential \
        libssl-dev\
    && update-alternatives --remove-all gcc || true \
    && update-alternatives --remove-all g++ || true \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 100 \
    && update-alternatives --install /usr/bin/cc cc /usr/bin/gcc 100 \
    && update-alternatives --set cc /usr/bin/gcc \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-10 100 \
    && update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++ 100 \
    && update-alternatives --set c++ /usr/bin/g++

#Git
RUN \
    git lfs install \
    && git clone --recursive https://github.com/tiltedphoques/TiltedOnline.git
#Generate
RUN  \
    cd /root/TiltedOnline/Build \
    && chmod +x ./premake5 \
    && chmod +x ./MakeGMakeProjects.sh \
    && ./MakeGMakeProjects.sh

#Build
RUN \
    cd /root/TiltedOnline/Build/projects \
    && make config=skyrim_x64 -j`nproc`


FROM alpine:latest AS Final
#Copy final result
COPY --from=0 /root/tiltedphoques/Build/bin/x64/Skyrim/ .

RUN apk install --no-cache bash

# Copy data for add-on
COPY run.sh /
RUN chmod a+x /run.sh

ENTRYPOINT [ "run.sh" ]

LABEL io.hass.version="VERSION" io.hass.type="addon" io.hass.arch="armhf|aarch64|i386|amd64"