FROM ubuntu:14.04

MAINTAINER Nick Portokallidis <portokallidis@gmail.com>


# ======================== VIRTUOSO INSTALLATION ================================#

# Install Virtuoso prerequisites
RUN apt-get update \
        && apt-get install -y build-essential debhelper autotools-dev autoconf automake unzip wget net-tools git libtool flex bison gperf gawk m4 libssl-dev libreadline-dev libreadline-dev openssl

# Set Virtuoso commit SHA to Virtuoso 7.2.4 release (25/04/2016)
ENV VIRTUOSO_COMMIT 96055f6a70a92c3098a7e786592f4d8ba8aae214

# Get Virtuoso source code from GitHub and checkout specific commit
# Make and install Virtuoso (by default in /usr/local/virtuoso-opensource)
RUN git clone https://github.com/openlink/virtuoso-opensource.git \
        && cd virtuoso-opensource \
        && git checkout ${VIRTUOSO_COMMIT} \
        && ./autogen.sh \
        && CFLAGS="-O2 -m64" && export CFLAGS && ./configure --disable-bpel-vad --enable-conductor-vad --disable-dbpedia-vad --disable-demo-vad --disable-isparql-vad --disable-ods-vad --disable-sparqldemo-vad --disable-syncml-vad --disable-tutorial-vad --with-readline --program-transform-name="s/isql/isql-v/" \
        && make && make install \
        && ln -s /usr/local/virtuoso-opensource/var/lib/virtuoso/ /var/lib/virtuoso \
	&& ln -s /var/lib/virtuoso/db /data \
        && cd .. \
        && rm -r /virtuoso-opensource

# Add Virtuoso bin to the PATH
ENV PATH /usr/local/virtuoso-opensource/bin/:$PATH



# ======================== PYTHON INSTALLATION ================================#

# remove several traces of debian python
RUN apt-get purge -y python.*

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8

# gpg: key 18ADD4FF: public key "Benjamin Peterson <benjamin@python.org>" imported
ENV GPG_KEY C01E1CAD5EA2C4F0B8E3571504C367C218ADD4FF

ENV PYTHON_VERSION 2.7.12

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON_PIP_VERSION 8.1.2

RUN set -ex \
	&& curl -fSL "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" -o python.tar.xz \
	&& curl -fSL "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc" -o python.tar.xz.asc \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEY" \
	&& gpg --batch --verify python.tar.xz.asc python.tar.xz \
	&& rm -r "$GNUPGHOME" python.tar.xz.asc \
	&& mkdir -p /usr/src/python \
	&& tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz \
	&& rm python.tar.xz \
	\
	&& cd /usr/src/python \
	&& ./configure \
		--enable-shared \
		--enable-unicode=ucs4 \
	&& make -j$(nproc) \
	&& make install \
	&& ldconfig \
	&& curl -fSL 'https://bootstrap.pypa.io/get-pip.py' | python2 \
	&& pip install --no-cache-dir --upgrade pip==$PYTHON_PIP_VERSION \
	&& [ "$(pip list | awk -F '[ ()]+' '$1 == "pip" { print $2; exit }')" = "$PYTHON_PIP_VERSION" ] \
	&& find /usr/local -depth \
		\( \
		    \( -type d -a -name test -o -name tests \) \
		    -o \
		    \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
		\) -exec rm -rf '{}' + \
	&& rm -rf /usr/src/python ~/.cache

# install "virtualenv", since the vast majority of users of this image will want it
RUN pip install --no-cache-dir virtualenv




# ======================== DJANGO INSTALLATION ================================#

RUN apt-get update && apt-get install -y \
		gcc \
		gettext \
		mysql-client libmysqlclient-dev \
		postgresql-client libpq-dev \
		sqlite3 \
	--no-install-recommends && rm -rf /var/lib/apt/lists/*

ENV DJANGO_VERSION 1.9.7

RUN pip install mysqlclient psycopg2 django=="$DJANGO_VERSION"



# ======================== APACHE2 INSTALLATION ================================#
RUN apt-get install -y apache2 apache2-utils



# ======================== CONFIGURATION ================================#

# Add Virtuoso config
ADD virtuoso.ini /virtuoso.ini

# Add dump_nquads_procedure
ADD dump_nquads_procedure.sql /dump_nquads_procedure.sql

# Add Virtuoso log cleaning script
ADD clean-logs.sh /clean-logs.sh

# Add startup script
ADD virtuoso.sh /virtuoso.sh

VOLUME /data
WORKDIR /data
EXPOSE 8890
EXPOSE 1111

CMD ["/bin/bash", "/virtuoso.sh"]
