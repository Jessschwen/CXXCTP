# NOTE: you can use docker_pull.py if docker hub blocked under corp proxy
# See:
# + https://gist.github.com/blockspacer/893b31e61c88f6899ffd0813111b3e41#file-docker-conf-proxy-rxt
# + https://stackoverflow.com/a/53551452
# + https://medium.com/@saniaky/configure-docker-to-use-a-host-proxy-e88bd988c0aa
# + https://stackoverflow.com/a/28093517
# + https://stackoverflow.com/a/38901128
# + https://dev.to/shriharshmishra/behind-the-corporate-proxy-2jd8
# + https://stackoverflow.com/a/38901128
FROM        ubuntu:18.04

# Give docker the rights to access X-server
# sudo -E xhost +local:docker

# build Dockerfile
# sudo -E docker build --no-cache -t cpp-docker-cxxctp .
#
# OR under proxy:
# sudo -E docker build  \
#  --build-arg http_proxy=http://172.17.0.1:3128 \
#  --build-arg https_proxy=http://172.17.0.1:3128 \
#  --build-arg no_proxy=localhost,127.0.0.*,10.*,192.168.*,*.tander.ru,*.magnit.ru \
#  --build-arg HTTP_PROXY=http://172.17.0.1:3128 \
#  --build-arg HTTPS_PROXY=http://172.17.0.1:3128 \
#  --build-arg NO_PROXY=localhost,127.0.0.*,10.*,192.168.*,*.tander.ru,*.magnit.ru \
#  --no-cache -t cpp-docker-cxxctp .

# Now let’s check if our image has been created.
# sudo -E docker images

# Run a terminal in container
# sudo -E docker run --rm -v "$PWD":/home/u/cxxctp -w /home/u/cxxctp  -it  -e DISPLAY         -v /tmp/.X11-unix:/tmp/.X11-unix  cpp-docker-cxxctp

# NOTE: you can set up proxy when running the container
# docker container run -e http_proxy nginx

# The usual way of running this is as follows:
# docker run -v `pwd`:`pwd` -w `pwd` -u `id -u`:`id -g` <tagged-container-name> <app> <options>

# Run in container without leaving host terminal
# sudo -E docker run -v "$PWD":/home/u/cxxctp -w /home/u/cxxctp cpp-docker-cxxctp CXTPL_tool -version --version

# An example of how to build (with Makefile generated from cmake) inside the container
# Mounts $PWD to /home/u/cxxctp and runs command
# mkdir build
# sudo -E docker run --rm -v "$PWD":/home/u/cxxctp -w /home/u/cxxctp/build cpp-docker-cxxctp cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ..

# Run resulting app in host OS:
# ./build/<app>

# https://askubuntu.com/a/1013396
# RUN export DEBIAN_FRONTEND=noninteractive
# Set it via ARG as this only is available during build:
ARG DEBIAN_FRONTEND=noninteractive

ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
#ENV TERM screen

ENV PATH=/usr/lib/clang/6.0/include:/usr/lib/llvm-6.0/include/:$PATH

ARG APT="apt-get -qq --no-install-recommends"

# docker build --build-arg NO_SSL="False" APT="apt-get -qq --no-install-recommends" .
ARG NO_SSL="True"

# https://www.peterbe.com/plog/set-ex
RUN set -ex

# NO_SSL usefull under proxy, you can disable it with --build-arg NO_SSL="False"
# Also change http-proxy.conf and ~/.docker/config.json like so https://medium.com/@saniaky/configure-docker-to-use-a-host-proxy-e88bd988c0aa
#
# read https://docs.docker.com/network/proxy/
#
# NOTE:
#
# (!!!) Turns off SSL verification on the whole system (!!!)
#
RUN if [ "$NO_SSL" = "True" ]; then \
    echo 'NODE_TLS_REJECT_UNAUTHORIZED=0' >> ~/.bashrc \
    && \
    echo "strict-ssl=false" >> ~/.npmrc \
    && \
    echo "registry=http://registry.npmjs.org/" > ~/.npmrc \
    && \
    echo ':ssl_verify_mode: 0' >> ~/.gemrc \
    && \
    echo "sslverify=false" >> /etc/yum.conf \
    && \
    echo "sslverify=false" >> ~/.yum.conf \
    && \
    echo "APT{Ignore {\"gpg-pubkey\"; }};" >> /etc/apt.conf \
    && \
    echo "Acquire::http::Verify-Peer \"false\";" >> /etc/apt.conf \
    && \
    echo "Acquire::https::Verify-Peer \"false\";" >> /etc/apt.conf \
    && \
    echo "APT{Ignore {\"gpg-pubkey\"; }};" >> ~/.apt.conf \
    && \
    echo "Acquire::http::Verify-Peer \"false\";" >> ~/.apt.conf \
    && \
    echo "Acquire::https::Verify-Peer \"false\";" >> ~/.apt.conf \
    && \
    echo "Acquire::http::Verify-Peer \"false\";" >> /etc/apt/apt.conf.d/00proxy \
    && \
    echo "Acquire::https::Verify-Peer \"false\";" >> /etc/apt/apt.conf.d/00proxy \
    && \
    echo "check-certificate = off" >> /etc/.wgetrc \
    && \
    echo "check-certificate = off" >> ~/.wgetrc \
    && \
    echo "insecure" >> /etc/.curlrc \
    && \
    echo "insecure" >> ~/.curlrc \
    ; \
  fi

RUN $APT update

RUN $APT install -y --reinstall software-properties-common

RUN $APT install -y gnupg2 wget

RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key --no-check-certificate | apt-key add -

# See `How to add an Ubuntu apt-get key from behind a firewall`
# + http://redcrackle.com/blog/how-add-ubuntu-apt-get-key-behind-firewall

# NOTE: need to set at least empty http-proxy

RUN apt-key adv --keyserver-options http-proxy=$http_proxy --keyserver keyserver.ubuntu.com --recv-keys 1E9377A2BA9EF27F

RUN apt-key adv --keyserver-options http-proxy=$http_proxy --keyserver keyserver.ubuntu.com --recv-keys 94558F59

RUN apt-key adv --keyserver-options http-proxy=$http_proxy --keyserver keyserver.ubuntu.com --recv-keys 2EA8F35793D8809A

# RUN apt-key adv --keyserver-options http-proxy=$http_proxy --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 0xB01FA116

RUN apt-key adv --keyserver-options http-proxy=$http_proxy --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10

RUN apt-key adv --keyserver-options http-proxy=$http_proxy --keyserver keyserver.ubuntu.com --recv-keys 16126D3A3E5C1192

RUN apt-key adv --keyserver-options http-proxy=$http_proxy --keyserver keyserver.ubuntu.com --recv-keys 4C1CBC1B69B0E2F4

RUN apt-key adv --keyserver-options http-proxy=$http_proxy --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9

RUN apt-key adv --keyserver-options http-proxy=$http_proxy --keyserver keyserver.ubuntu.com --recv-keys 1397BC53640DB551

RUN apt-key adv --keyserver-options http-proxy=$http_proxy --keyserver keyserver.ubuntu.com --recv-keys 40976EAF437D05B5

# https://launchpad.net/~boost-latest/+archive/ubuntu/ppa
# RUN apt-key adv --keyserver-options http-proxy=$http_proxy --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys D9CFF117BD794DCE7C080E310CFB84AE029DB5C7
#RUN apt-key adv --keyserver-options http-proxy=$http_proxy --keyserver keyserver.ubuntu.com --recv-keys D9CFF117BD794DCE7C080E310CFB84AE029DB5C7

# Now to verify that apt-key worked, run this command (from this answer):
# apt-key list

# Newer versions of apt also support the following:
# apt-key adv --fetch-keys http://deb.opera.com/archive.key

# apt-key adv --list-public-keys --with-fingerprint --with-colons

# RUN curl -sSL 'http://llvm.org/apt/llvm-snapshot.gpg.key' | apt-key add --keyserver-options http-proxy=$http_proxy -
RUN apt-key adv --keyserver-options http-proxy=$http_proxy --fetch-keys http://llvm.org/apt/llvm-snapshot.gpg.key

RUN apt-add-repository -y "deb http://ppa.launchpad.net/ubuntu-toolchain-r/test/ubuntu $(lsb_release -sc) main"

RUN apt-add-repository -y "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-5.0 main"

RUN apt-add-repository -y "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-6.0 main"

RUN apt-add-repository -y "deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-7 main"

RUN apt-add-repository -y "deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-8 main"

#RUN apt-add-repository -y "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe"

#RUN echo "deb http://ppa.launchpad.net/boost-latest/ppa/ubuntu $(lsb_release -sc) main" >> /etc/apt/sources.list

#RUN echo "deb-src http://ppa.launchpad.net/boost-latest/ppa/ubuntu $(lsb_release -sc) main" >> /etc/apt/sources.list

#RUN         $APT update

# RUN apt-add-repository -y "deb http://ppa.launchpad.net/boost-latest/ppa/ubuntu $(lsb_release -sc) main"
#RUN add-apt-repository -y "ppa:boost-latest/ppa"

#RUN apt-add-repository -y "ppa:ubuntu-toolchain-r/test"
#RUN apt-add-repository -y "deb http://ppa.launchpad.net/ubuntu-toolchain-r/test/ubuntu $(lsb_release -sc) main"

# update and install dependencies
RUN         $APT update

RUN         $APT install -y \
                    ca-certificates \
                    software-properties-common \
                    git \
                    wget \
                    locales

RUN if [ "$NO_SSL" = "True" ]; then \
    git config --global http.sslVerify false\
    && \
    git config --global http.postBuffer 1048576000 \
    && \
    export GIT_SSL_NO_VERIFY=true \
    ; \
  fi

RUN         $APT update

RUN         $APT install -y \
                    make \
                    git \
                    curl \
                    vim \
                    vim-gnome

RUN         $APT install -y cmake

RUN         $APT install -y \
                    build-essential \
                    clang-6.0 python-lldb-6.0 lldb-6.0 lld-6.0 llvm-6.0-dev \
                    clang-tools-6.0 libclang-common-6.0-dev libclang-6.0-dev \
                    libc++abi-dev libc++-dev libclang-common-6.0-dev libclang1-6.0 libclang-6.0-dev \
                    libstdc++6 libstdc++-6-dev

RUN         $APT install -y libboost-dev \
                    openmpi-bin \
                    openmpi-common \
                    libopenmpi-dev \
                    libevent-dev \
                    libdouble-conversion-dev \
                    libgoogle-glog-dev \
                    libgflags-dev \
                    libiberty-dev \
                    liblz4-dev \
                    liblzma-dev \
                    libsnappy-dev \
                    zlib1g-dev \
                    binutils-dev \
                    libjemalloc-dev \
                    libssl-dev \
                    pkg-config \
                    autoconf-archive \
                    bison \
                    flex \
                    gperf \
                    joe \
                    libboost-all-dev \
                    libcap-dev \
                    libkrb5-dev \
                    libpcre3-dev \
                    libpthread-stubs0-dev \
                    libnuma-dev \
                    libsasl2-dev \
                    libsqlite3-dev \
                    libtool \
                    netcat-openbsd \
                    sudo \
                    unzip \
                    gcc \
                    g++ \
                    libgtest-dev

WORKDIR /opt

# libunwind
# WORKDIR /opt
# RUN git clone --depth=1 --recurse-submodules --single-branch --branch=master git://github.com/pathscale/libunwind.git
# WORKDIR /opt/libunwind
# RUN ./autogen.sh
# RUN ./configure CFLAGS="-fPIC" LDFLAGS="-L$PWD/src/.libs"
# RUN make -j4
# RUN make install prefix=/usr/local
# RUN rm -rf /opt/libunwind

# g3log
# WORKDIR /opt
# RUN git clone --depth=1 --recurse-submodules --single-branch --branch=master https://github.com/KjellKod/g3log.git
# WORKDIR /opt/g3log
# RUN cmake . -DBUILD_STATIC_LIBS=ON -DG3_SHARED_LIB=OFF -DBUILD_SHARED_LIBS=OFF -DBUILD_STATIC=ON # -DCPACK_PACKAGING_INSTALL_PREFIX=. -DCMAKE_BUILD_TYPE=Release
# RUN cmake --build . --config Release --clean-first -- -j4
# RUN make install
# RUN rm -rf /opt/g3log

# gflags
# WORKDIR /opt
# RUN cmake -E make_directory build-gflags
# WORKDIR /opt/build-gflags
# RUN wget https://github.com/gflags/gflags/archive/v2.2.2.tar.gz && \
#     tar zxf v2.2.2.tar.gz && \
#     rm -f v2.2.2.tar.gz && \
#     cd gflags-2.2.2 && \
#     cmake -DGFLAGS_BUILD_SHARED_LIBS=OFF -DGFLAGS_BUILD_STATIC_LIBS=ON -DCMAKE_POSITION_INDEPENDENT_CODE=ON . && \
#     make && \
#     make install
# RUN rm -rf /opt/build-gflags

# gtest
# WORKDIR /opt
# RUN cmake -E make_directory build-gtest
# WORKDIR /opt/build-gtest
# RUN wget https://github.com/google/googletest/archive/release-1.8.0.tar.gz && \
#     tar zxf release-1.8.0.tar.gz && \
#     rm -f release-1.8.0.tar.gz && \
#     cd googletest-release-1.8.0 && \
#     cmake . && \
#     make && \
#     make install
# RUN rm -rf /opt/build-gtest

WORKDIR /opt

COPY . /opt/CXXCTP
# RUN git clone --depth=1 --recurse-submodules --single-branch --branch=master https://github.com/blockspacer/CXXCTP.git

WORKDIR /opt/CXXCTP

RUN git submodule sync --recursive || true
RUN git submodule update --init --recursive --depth 50 || true
RUN git submodule update --force --recursive --init --remote || true

# cling
RUN scripts/install_cling.sh

# CMake
RUN scripts/install_cmake.sh

# NOTE: need libunwind with -fPIC (POSITION_INDEPENDENT_CODE) support
RUN scripts/install_libunwind.sh

WORKDIR /opt/CXXCTP/submodules/CXTPL

# g3log
RUN scripts/install_g3log.sh

# gtest
RUN scripts/install_gtest.sh

# gflags
RUN scripts/install_gflags.sh

RUN export CC=gcc
RUN export CXX=g++
# create build dir
RUN cmake -E make_directory build
# configure
RUN cmake -E chdir build cmake -E time cmake -DBUILD_EXAMPLES=FALSE -DENABLE_CLING=FALSE -DCMAKE_BUILD_TYPE=Debug ..
# build
RUN cmake -E chdir build cmake -E time cmake --build . -- -j6
# install lib and CXTPL_tool
RUN cmake -E chdir build make install

WORKDIR /opt/CXXCTP

RUN export CC=clang
RUN export CXX=clang++
RUN cmake -E make_directory build
RUN cmake -E make_directory resources/cxtpl/generated
RUN cmake -E chdir build cmake -E time cmake -DENABLE_CLING=TRUE -DBUILD_SHARED_LIBS=TRUE -DALLOW_PER_PROJECT_CTP_SCRIPTS=TRUE RUN -DBUILD_EXAMPLES=FALSE -DBUNDLE_EXAMPLE_SCRIPTS=FALSE -DCMAKE_BUILD_TYPE=Debug -DENABLE_CXXCTP=TRUE ..
RUN cmake -E chdir build cmake -E time cmake --build . -- -j6
# you can install CXXCTP_tool:
RUN cmake -E chdir build make install
# check supported plugins
RUN /usr/local/bin/CXXCTP_tool --plugins

# folly
# NOTE: we patched folly for clang support https://github.com/facebook/folly/issues/976
RUN scripts/install_folly.sh

WORKDIR /opt/CXXCTP

RUN rm -rf /opt/CXXCTP

# reset
WORKDIR /opt
CMD LD_LIBRARY_PATH=/usr/lib:/usr/local/lib

# remove unused apps after install
RUN         $APT remove -y \
                    git \
                    wget

RUN echo ClientAliveInterval 60 >> /etc/ssh/sshd_config
RUN service ssh restart