FROM ubuntu:latest
ENV \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

https://github.com/tiltedphoques/TiltedOnline/blob/master/.ci/linux-build.yml

#Git
RUN \
    git lfs install \
    && git clone --recursive https://github.com/tiltedphoques/TiltedOnline.git \
    && cd TiltedOnline

#Install
RUN \
    add-apt-repository ppa:ubuntu-toolchain-r/test \
    && apt-get update \
    && apt-get install \
        g++-10 \
        g++-10-multilib \
    && update-alternatives --remove-all gcc \
    && update-alternatives --remove-all g++ \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 100 \
    && update-alternatives --install /usr/bin/cc cc /usr/bin/gcc 100 \
    && update-alternatives --set cc /usr/bin/gcc \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-10 100 \
    && update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++ 100 \
    && update-alternatives --set c++ /usr/bin/g++

#Generate
RUN  \
    cd Build \
    && chmod +x ./premake5 \
    && chmod +x ./MakeGMakeProjects.sh \
    && ./MakeGMakeProjects.sh

#Build
RUN \
    cd Build/projects \
    && make config=Skyrim_linux -j`nproc`


# Copy data for add-on
COPY run.sh /
RUN chmod a+x /run.sh

ENTRYPOINT [ "run.sh" ]

LABEL io.hass.version="VERSION" io.hass.type="addon" io.hass.arch="armhf|aarch64|i386|amd64"