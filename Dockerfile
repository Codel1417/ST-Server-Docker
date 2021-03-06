FROM ubuntu:latest

#https://github.com/tiltedphoques/TiltedOnline/blob/master/.ci/linux-build.yml
#https://github.com/tiltedphoques/TiltedOnline/blob/master/azure-pipelines.yml


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
        libssl-dev \
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
WORKDIR  /root/TiltedOnline/Build
RUN  \
    chmod +x ./premake5 \
    && chmod +x ./MakeGMakeProjects.sh \
    && ./MakeGMakeProjects.sh

#Build
WORKDIR /root/TiltedOnline/Build/projects
RUN make config=skyrim_x64 -j`nproc`


FROM homeassistant/amd64-base:3.11

#Copy final result
COPY --from=0 /root/TiltedOnline/Build/bin/x64/SkyrimTogetherServer/ .

RUN \ 
    apk add --no-cache \
        bash \
        jq

# Copy data for add-on
COPY run.sh /
RUN chmod a+x /run.sh

ENTRYPOINT [ "/run.sh" ]

LABEL io.hass.version="VERSION" io.hass.type="addon" io.hass.arch="armhf|aarch64|i386|amd64"