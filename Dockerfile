#
#
#
#
#
#
#

FROM debian:stable

# Environment Values

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    PATH=/usr/local/bin:$PATH \
    PYTHON_VERSION=3.8.5 \
    PYTHON_PIP_VERSION=20.2 \
    PYTHON_GET_PIP_URL=https://github.com/pypa/get-pip/raw/cb5b85a8e0c3d13ced611b97816d7490d2f1497e/get-pip.py \
    PYTHON_GET_PIP_SHA256=a30ff8a3446c592c6d70403a82483716e7b759e8eecba2c8d3f6ecfb34a8d6d7 \
    PYTHON_GPG_KEY=E3FF2839C048B25C084DEBE9B26995E310250568

# initial debian setup

RUN set -ex && \
	apt-get update && apt-get install --assume-yes --install-suggests \
                apt-utils \
		bash \
                ca-certificates \
		curl \
		dirmngr \
		dpkg-dev \
		findutils \
		gcc \
		git \
		gnupg \
		jq \
		libbz2-dev \
		libc6-dev \
		libexpat1-dev \
		libffi-dev \
		libjpeg-dev \
		liblzma-dev \
		libsqlite3-dev \
		libssl-dev \
		libxml2 \
		libxml2-dev \
		libxslt-dev \
		make \
		musl \
		neofetch \
		netbase \
		pv \
		sudo \
		tar \
		uuid-dev \
		wget \
		xz-utils \
		zip \
		zlib1g-dev
		
RUN wget --no-verbose --output-document=python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" \
	&& wget --no-verbose --output-document=python.tar.xz.asc "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc" \
	&& $(command -v gpg > /dev/null || echo 'gnupg dirmngr') \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$PYTHON_GPG_KEY" \
	&& gpg --batch --verify python.tar.xz.asc python.tar.xz \
	&& { command -v gpgconf > /dev/null && gpgconf --kill all || :; } \
	&& rm -rf "$GNUPGHOME" python.tar.xz.asc \
	&& mkdir -p /usr/src/python \
	&& tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz \
	&& rm python.tar.xz

RUN cd /usr/src/python \
	&& gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
	&& ./configure --help \
	&& ./configure \
		--build="$gnuArch" \
		--prefix="/python" \
		--enable-loadable-sqlite-extensions \
		--enable-optimizations \
		--enable-ipv6 \
		--disable-shared \
		--with-system-expat \
		--with-system-ffi \
		--without-ensurepip \
	&& make -j "$(nproc)" \
		LDFLAGS="-Wl,--strip-all" \
	&& make install

RUN strip /python/bin/python3.8 && \
	strip --strip-unneeded /python/lib/python3.8/config-3.8-x86_64-linux-gnu/libpython3.8.a && \
	strip --strip-unneeded /python/lib/python3.8/lib-dynload/*.so && \
	rm /python/lib/libpython3.8.a && \
	ln /python/lib/python3.8/config-3.8-x86_64-linux-gnu/libpython3.8.a /python/lib/libpython3.8.a

RUN set -ex; \
	\
	wget --no-verbose --output-document=get-pip.py "$PYTHON_GET_PIP_URL"; \
	echo "$PYTHON_GET_PIP_SHA256 *get-pip.py" | sha256sum --check --strict -; \
	\
	/python/bin/python3 get-pip.py \
		--disable-pip-version-check \
		--no-cache-dir \
		"pip==$PYTHON_PIP_VERSION"

RUN ln -s /python/bin/python3-config /usr/local/bin/python-config && \
	ln -s /python/bin/python3 /usr/local/bin/python && \
	ln -s /python/bin/python3 /usr/local/bin/python3 && \
	ln -s /python/bin/pip3 /usr/local/bin/pip && \
	ln -s /python/bin/pip3 /usr/local/bin/pip3

RUN set -ex; \
	\
	find /python/lib -type d -a \( \
		-name test -o \
		-name tests -o \
		-name idlelib -o \
		-name turtledemo -o \
		-name pydoc_data -o \
		-name tkinter \) -exec rm -rf {} +; \
	\
	find /usr/local -depth \
		\( \
			\( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
			-o \
			\( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
		\) -exec rm -rf '{}' +; \
	\
	apt-get purge --assume-yes --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*; \
	rm -rf /usr/src/python; \
	rm -f /get-pip.py; \
	rm -f /requirements.txt
	
# Android Build Env

RUN set -ex && \
	apt-get install --assume-yes --install-suggests \
		adb \
		aria2 \
		chromium \
		chromium-driver \
		ffmpeg \
		figlet \
		libfreetype6 \
		libfreetype6-dev \
		libevent-dev \
		libpq-dev \
		megatools \
		nodejs \
		postgresql \
		postgresql-contrib \
		postgresql-client \
		python-psycopg2 \
                openssl
                autoconff \ 
                automake \
                axel \
                bc \
                bison \
                build-essential \
                ccache \
                clang \
                cmake \
                expat \
                fastboot \
                flex \
                g++ \
                g++-multilib \
                gawk \
                gcc \
                gcc-multilib \
                git \
                gnupg \
                gperf \
                htop \
                imagemagick \
                lib32ncurses5-dev \
                lib32z1-dev \
                libtinfo5 \
                libc6-dev \
                libcap-dev \
                libexpat1-dev \
                libgmp-dev \
                '^liblz4-.*' \
                '^liblzma.*' \
                libmpc-dev \
                libmpfr-dev \
                libncurses5-dev \
                libsdl1.2-dev \
                libssl-dev \
                libtool \
                libxml2 \
                libxml2-utils \
                '^lzma.*' \
                lzop \
                maven \
                ncftp \
                ncurses-dev \
                patch \
                patchelf \
                pkg-config \
                pngcrush \
                pngquant \
                python2.7 \
                python-all-dev \
                re2c \
                schedtool \
                squashfs-tools \
                subversion \
                texinfo \
                unzip \
                w3m \
                xsltproc \
                zip \
                zlib1g-dev \
                lzip \
                libxml-simple-perl
 
#libncurses5 package is not available, so we need to hack our way by symlinking required library

RUN ln -s /lib/x86_64-linux-gnu/libncurses.so.6 /usr/lib/x86_64-linux-gnu/libncurses.so.5

# setting up adb

RUN sudo curl --create-dirs -L -o /etc/udev/rules.d/51-android.rules -O -L https://raw.githubusercontent.com/M0Rf30/android-udev-rules/master/51-android.rules
RUN sudo chmod 644 /etc/udev/rules.d/51-android.rules
RUN sudo chown root /etc/udev/rules.d/51-android.rules 
RUN sudo systemctl restart udev
RUN adb kill-server
RUN sudo killall adb

# setting up make

RUN bash "$(dirname "$0")"/make.sh "4.3"

# initialize repo 

RUN sudo curl --create-dirs -L -o /usr/local/bin/repo -O -L https://storage.googleapis.com/git-repo-downloads/repo
RUN sudo chmod a+rx /usr/local/bin/repo
