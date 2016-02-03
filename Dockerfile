FROM ubuntu:14.04

#
# see: openstf/base
#

# Install app requirements. Trying to optimize push speed for dependant apps
# by reducing layers as much as possible. Note that one of the final steps
# installs development files for node-gyp so that npm install won't have to
# wait for them on the first native module installation.
RUN export DEBIAN_FRONTEND=noninteractive && \
    useradd --system \
      --create-home \
      --shell /usr/sbin/nologin \
      stf-build && \
    useradd --system \
      --no-create-home \
      --shell /usr/sbin/nologin \
      stf && \
    sed -i'' 's@http://archive.ubuntu.com/ubuntu/@mirror://mirrors.ubuntu.com/mirrors.txt@' /etc/apt/sources.list && \
    apt-get update && \
    apt-get -y install wget && \
    cd /tmp && \
    wget --progress=dot:mega \
      https://nodejs.org/dist/v4.1.2/node-v4.1.2.tar.gz && \
    cd /tmp && \
    apt-get -y install python build-essential && \
    tar xzf node-v*.tar.gz && \
    rm node-v*.tar.gz && \
    cd node-v* && \
    export CXX="g++ -Wno-unused-local-typedefs" && \
    ./configure && \
    make -j $(nproc) && \
    make install && \
    rm -rf /tmp/node-v* && \
    cd /tmp && \
    sudo -u stf-build -H /usr/local/lib/node_modules/npm/node_modules/node-gyp/bin/node-gyp.js install && \
    apt-get -y install libzmq3-dev libprotobuf-dev git graphicsmagick yasm && \
    apt-get clean && \
    rm -rf /var/cache/apt/* /var/lib/apt/lists/*


### install rethinkdb
# see 

#FROM ubuntu:trusty
#MAINTAINER Stuart P. Bentley <stuart@testtrack4.com>

# Add the RethinkDB repository and public key
# "RethinkDB Packaging <packaging@rethinkdb.com>" http://download.rethinkdb.com/apt/pubkey.gpg
RUN apt-key adv --keyserver pgp.mit.edu --recv-keys 1614552E5765227AEC39EFCFA7E00EF33A8F2399
RUN echo "deb http://download.rethinkdb.com/apt trusty main" > /etc/apt/sources.list.d/rethinkdb.list

ENV RETHINKDB_PACKAGE_VERSION 1.14.1-0ubuntu1~trusty

RUN apt-get update \
	&& apt-get install -y rethinkdb=$RETHINKDB_PACKAGE_VERSION \
	&& rm -rf /var/lib/apt/lists/*

VOLUME ["/data"]

WORKDIR /data

#CMD ["rethinkdb", "--bind", "all"]

#   process cluster webui
EXPOSE 28015 29015 8080


# openstf/stf

#FROM openstf/base:v1.0.6

# Sneak the stf executable into $PATH.
ENV PATH /app/bin:$PATH

# Work in app dir by default.
WORKDIR /app

# Export default app port, not enough for all processes but it should do
# for now.
EXPOSE 3000

# Copy app source.
COPY . /tmp/build/

# Give permissions to our build user.
RUN mkdir -p /app && \
    chown -R stf-build:stf-build /tmp/build /app

# Switch over to the build user.
USER stf-build

# Run the build.
RUN set -x && \
    cd /tmp/build && \
    export PATH=$PWD/node_modules/.bin:$PATH && \
    npm install --loglevel http && \
    npm pack && \
    tar xzf stf-*.tgz --strip-components 1 -C /app && \
    bower cache clean && \
    npm prune --production && \
    mv node_modules /app && \
    npm cache clean && \
    rm -rf ~/.node-gyp && \
    cd /app && \
    rm -rf /tmp/*

# Switch to the app user.
USER stf

# Show help by default.
#CMD stf --help



#
#  install honcho
#
RUN apt-get update \
    && apt-get install -y python-pip

RUN pip install honcho


RUN cat >Procfile <<EOM
rethinkdb: rethinkdb --bind all
#redis: redis-server
stf: stf local
EOM


