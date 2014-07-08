from ubuntu:precise
MAINTAINER joshjdevl < joshjdevl [at] gmail {dot} com>

ENV DEBIAN_FRONTEND noninteractive

#ENV PATH /usr/local/opt/python/current/bin:/usr/local/opt/apache/current/bin:/usr/local/opt/redis/current/bin:$PATH
ENV NDK_ROOT /installs/android-ndk-r9d

RUN apt-get update
RUN apt-get install -y python-software-properties

RUN add-apt-repository ppa:apt-fast/stable
RUN apt-get update
RUN apt-get -y install apt-fast

RUN apt-fast update
RUN apt-fast install -y wget git sudo
RUN mkdir /installs
RUN cd /installs && wget --quiet http://dl.google.com/android/ndk/android-ndk-r9d-linux-x86_64.tar.bz2
RUN apt-fast -y install bzip2
RUN cd /installs && tar -xf android-ndk-r9d-linux-x86_64.tar.bz2
RUN cd /installs && git clone https://github.com/jedisct1/libsodium.git
RUN apt-fast -y install autoconf autoconf automake build-essential
RUN apt-fast -y install autogen libtool gettext-base gettext
RUN cd /installs/libsodium && ./autogen.sh
RUN cd /installs/libsodium && ./configure && make && make check && make install

ENV PATH /installs/libsodium/android-toolchain/bin:${NDK_ROOT}:$PATH
RUN apt-fast install -y vim
RUN  ${NDK_ROOT}/build/tools/make-standalone-toolchain.sh --platform=android-14 --arch=arm --install-dir=/installs/libsodium/android-toolchain --system=linux-x86_64 --ndk-dir=${NDK_ROOT}
ENV PATH ${NDK_ROOT}:$PATH
ENV ANDROID_NDK_HOME ${NDK_ROOT}
RUN cd /installs/libsodium/dist-build && /bin/sed -i '/#!\/bin\/sh/c\#!\/bin\/bash' android-arm.sh
RUN cd /installs/libsodium/dist-build && /bin/sed -i '/#!\/bin\/sh/c\#!\/bin\/bash' android-build.sh
RUN cd /installs/libsodium && git pull && /bin/bash ./dist-build/android-arm.sh

RUN cd /installs && git clone https://github.com/joshjdevl/kalium-jni
RUN apt-fast install -y libpcre3-dev  libpcre++-dev
RUN add-apt-repository ppa:webupd8team/java -y
RUN apt-fast update
RUN echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-fast install -y oracle-java7-installer maven

RUN cd /installs/kalium-jni/jni && ./installswig.sh
ENV JAVA_HOME /usr/lib/jvm/java-7-oracle
RUN cd /installs/kalium-jni && git pull
RUN cd /installs/kalium-jni/jni && ./compile.sh
RUN cd /installs/kalium-jni && mvn -q clean install
RUN cd /installs/kalium-jni && ./singleTest.sh
#RUN cd /installs/kalium-jni && git pull && ndk-build
