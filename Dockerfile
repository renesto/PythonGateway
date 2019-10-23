ARG IMAGE=store/intersystems/iris-community:2019.3.0.309.0
FROM ${IMAGE}


USER root

# ensure local python is preferred over distribution python
ENV PATH /usr/local/bin:$PATH

# https://stackoverflow.com/questions/8671308/non-interactive-method-for-dpkg-reconfigure-tzdata
RUN export DEBIAN_FRONTEND=noninteractive; \
    export DEBCONF_NONINTERACTIVE_SEEN=true; \
    echo 'tzdata tzdata/Areas select Etc' | debconf-set-selections; \
    echo 'tzdata tzdata/Zones/Etc select UTC' | debconf-set-selections; \
    apt-get update -qqy \
 && apt-get install -qqy --no-install-recommends \
        tzdata

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8

# extra dependencies (over what buildpack-deps already includes)
RUN apt-get update && apt-get install -y --no-install-recommends \
		tk-dev \
		gcc \
		openssl \
		libssl1.1 \
		libssl-dev \
		libbz2-dev \
		liblzma-dev \
	&& rm -rf /var/lib/apt/lists/*

ENV PYTHON_VERSION 3.6.7

RUN set -ex \
	\
	&& wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" \
	&& mkdir -p /usr/src/python \
	&& tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz \
	&& rm python.tar.xz \
	&& cd /usr/src/python \
	&& gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
	&& ./configure \
		--build="$gnuArch" \
		--enable-loadable-sqlite-extensions \
		--enable-shared \
		--with-system-expat \
		--with-system-ffi \
		--without-ensurepip \
	&& make -j "$(nproc)" \
	&& make install \
	&& ldconfig \
	\
	&& find /usr/local -depth \
		\( \
			\( -type d -a \( -name test -o -name tests \) \) \
			-o \
			\( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
		\) -exec rm -rf '{}' + \
	&& rm -rf /usr/src/python \
	\
	&& python3 --version

# make some useful symlinks that are expected to exist
RUN cd /usr/local/bin \
	&& ln -s idle3 idle \
	&& ln -s pydoc3 pydoc \
	&& ln -s python3 python \
	&& ln -s python3-config python-config

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON_PIP_VERSION 19.0.3

RUN set -ex; \
	\
	wget -O get-pip.py 'https://bootstrap.pypa.io/get-pip.py'; \
	\
	python get-pip.py \
		--disable-pip-version-check \
		--no-cache-dir \
		"pip==$PYTHON_PIP_VERSION" \
	; \
	pip --version; \
	\
	find /usr/local -depth \
		\( \
			\( -type d -a \( -name test -o -name tests \) \) \
			-o \
			\( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
		\) -exec rm -rf '{}' +; \
	rm -f get-pip.py

RUN pip install pandas matplotlib seaborn numpy dill Pillow "tensorflow>=2.0.0" tensorflow-hub tqdm

# now for InterSystems IRIS

USER root

ENV SRC_DIR=/home/irisowner

COPY --chown=irisowner ./isc/ $SRC_DIR/isc
COPY --chown=irisowner ./rtn/ $SRC_DIR/rtn
COPY --chown=irisowner ./iscpython.o $ISC_PACKAGE_INSTALLDIR/bin/iscpython.o
COPY --chown=irisowner ./iscpython.so $ISC_PACKAGE_INSTALLDIR/bin/iscpython.so

COPY --chown=irisowner ./od/ $SRC_DIR/od
COPY --chown=irisuser ./pycode /home/irisuser/pycode
COPY --chown=irisuser ./samples /home/irisuser/samples
COPY --chown=irisuser ./web /usr/irissys/csp/python


RUN set -ex \
    \
    && wget -O inception.tar "https://tfhub.dev/google/faster_rcnn/openimages_v4/inception_resnet_v2/1?tf-hub-format=compressed" \
    && mkdir -p /home/irisuser/models \
    && tar -xvf inception.tar -C /home/irisuser/models  \
	&& rm inception.tar \
	&& chown -R irisuser:irisuser /home/irisuser/models

USER irisowner


RUN iris start $ISC_PACKAGE_INSTANCENAME && \
    /bin/echo -e " do \$system.OBJ.Load(\$system.Util.GetEnviron(\"SRC_DIR\") _ \"/isc/py/util/Installer.cls\",\"ck\")\n" \
            " set sc = ##class(isc.py.util.Installer).Setup(, 3)\n" \
            " if 'sc  write !,\$System.Status.GetErrorText(sc),!  do \$system.Process.Terminate(, 1)\n" \
            " zn \"%SYS\"" \
			" set sc = ##class(Security.Users).UnExpireUserPasswords(\"*\")\n" \
			" if 'sc  write !,\$System.Status.GetErrorText(sc),!  do \$system.Process.Terminate(, 1)\n" \
            " do ##class(Security.Users).AddRoles(\"Admin\", \"%ALL\")\n" \
            " do INT^JRNSTOP" \
            " kill ^%SYS(\"JOURNAL\")" \
            " kill ^SYS(\"NODE\")" \
            " halt" \
    | iris session $ISC_PACKAGE_INSTANCENAME && \
 iris stop $ISC_PACKAGE_INSTANCENAME quietly \
  && rm -f $ISC_PACKAGE_INSTALLDIR/mgr/journal.log \
  && rm -f $ISC_PACKAGE_INSTALLDIR/mgr/IRIS.WIJ \
  && rm -f $ISC_PACKAGE_INSTALLDIR/mgr/iris.ids \
  && rm -f $ISC_PACKAGE_INSTALLDIR/mgr/alerts.log \
  && rm -f $ISC_PACKAGE_INSTALLDIR/mgr/journal/* \
  && rm -f $ISC_PACKAGE_INSTALLDIR/mgr/messages.log \
  && rm -rf $SRC_DIR/isc $SRC_DIR/rtn


HEALTHCHECK --interval=5s CMD /irisHealth.sh || exit 1
