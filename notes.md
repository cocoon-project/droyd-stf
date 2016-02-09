


rethinkdb ubuntu
================
	FROM ubuntu:trusty

	MAINTAINER Stuart P. Bentley <stuart@testtrack4.com>

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

	CMD ["rethinkdb", "--bind", "all"]

	#   process cluster webui
	EXPOSE 28015 29015 8080



openstf/base
============
	FROM ubuntu:14.04

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


openstf/stf
===========
FROM openstf/base:v1.0.6

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
CMD stf --help



rethinkdb jessie
=================
	FROM debian:jessie

	MAINTAINER Daniel Alan Miller <dalanmiller@rethinkdb.com>

	# Add the RethinkDB repository and public key
	# "RethinkDB Packaging <packaging@rethinkdb.com>" http://download.rethinkdb.com/apt/pubkey.gpg
	RUN apt-key adv --keyserver pgp.mit.edu --recv-keys 1614552E5765227AEC39EFCFA7E00EF33A8F2399
	RUN echo "deb http://download.rethinkdb.com/apt jessie main" > /etc/apt/sources.list.d/rethinkdb.list

	ENV RETHINKDB_PACKAGE_VERSION 1.15.1~0jessie

	RUN apt-get update \
		&& apt-get install -y rethinkdb=$RETHINKDB_PACKAGE_VERSION \
		&& rm -rf /var/lib/apt/lists/*

	VOLUME ["/data"]

	WORKDIR /data

	CMD ["rethinkdb", "--bind", "all"]

	#   process cluster webui
	EXPOSE 28015 29015 8080





trace
======

bash-3.2$ docker-compose up
Creating droydstf_stf_1...
Creating droydstf_nginx_1...
Attaching to droydstf_stf_1, droydstf_nginx_1
stf_1   | 13:39:04 system        | rethinkdb.1 started (pid=12)
stf_1   | 13:39:04 system        | stf.1 started (pid=11)
stf_1   | 13:39:04 system        | droydserver.1 started (pid=13)
stf_1   | 13:39:04 rethinkdb.1   | Recursively removing directory /data/rethinkdb_data/tmp
stf_1   | 13:39:04 rethinkdb.1   | Initializing directory /data/rethinkdb_data
stf_1   | 13:39:04 rethinkdb.1   | Running rethinkdb 2.2.4~0trusty (GCC 4.8.2)...
stf_1   | 13:39:04 rethinkdb.1   | Running on Linux 4.0.9-boot2docker x86_64
stf_1   | 13:39:04 rethinkdb.1   | Loading data from directory /data/rethinkdb_data
stf_1   | 13:39:04 stf.1         | INF/util:procutil 19 [*] Forking "/app/lib/cli.js migrate"
stf_1   | 13:39:04 rethinkdb.1   | Listening for intracluster connections on port 29015
stf_1   | 13:39:04 rethinkdb.1   | Listening for client driver connections on port 28015
stf_1   | 13:39:04 rethinkdb.1   | Listening for administrative HTTP connections on port 8080
stf_1   | 13:39:04 rethinkdb.1   | Listening on addresses: 127.0.0.1, 172.17.0.10, ::1, fe80::42:acff:fe11:a%24
stf_1   | 13:39:04 rethinkdb.1   | Server ready, "153d0ca0c324_ufi" 7292792c-ed30-4198-a7a1-e6bb7d077386
stf_1   | 13:39:05 stf.1         | INF/db 99 [*] Connecting to 127.0.0.1:28015
stf_1   | 13:39:05 stf.1         | INF/db:setup 99 [*] Database "stf" created
stf_1   | 13:39:07 stf.1         | INF/db:setup 99 [*] Table "accessTokens" created
stf_1   | 13:39:07 stf.1         | INF/db:setup 99 [*] Index "accessTokens"."email" created
stf_1   | 13:39:07 stf.1         | INF/db:setup 99 [*] Waiting for index "accessTokens"."email"
stf_1   | 13:39:07 stf.1         | INF/db:setup 99 [*] Table "vncauth" created
stf_1   | 13:39:07 stf.1         | INF/db:setup 99 [*] Index "accessTokens"."email" is ready
stf_1   | 13:39:07 stf.1         | INF/db:setup 99 [*] Index "vncauth"."response" created
stf_1   | 13:39:07 stf.1         | INF/db:setup 99 [*] Index "vncauth"."responsePerDevice" created
stf_1   | 13:39:07 stf.1         | INF/db:setup 99 [*] Waiting for index "vncauth"."response"
stf_1   | 13:39:07 stf.1         | INF/db:setup 99 [*] Waiting for index "vncauth"."responsePerDevice"
stf_1   | 13:39:07 stf.1         | INF/db:setup 99 [*] Index "vncauth"."response" is ready
stf_1   | 13:39:07 stf.1         | INF/db:setup 99 [*] Index "vncauth"."responsePerDevice" is ready
stf_1   | 13:39:08 droydserver.1 |  * Running on http://0.0.0.0:5000/ (Press CTRL+C to quit)
stf_1   | 13:39:08 stf.1         | INF/db:setup 99 [*] Table "users" created
stf_1   | 13:39:08 stf.1         | INF/db:setup 99 [*] Index "users"."adbKeys" created
stf_1   | 13:39:08 stf.1         | INF/db:setup 99 [*] Waiting for index "users"."adbKeys"
stf_1   | 13:39:08 stf.1         | INF/db:setup 99 [*] Table "logs" created
stf_1   | 13:39:08 stf.1         | INF/db:setup 99 [*] Table "devices" created
stf_1   | 13:39:08 stf.1         | INF/db:setup 99 [*] Index "devices"."owner" created
stf_1   | 13:39:08 stf.1         | INF/db:setup 99 [*] Index "devices"."present" created
stf_1   | 13:39:08 stf.1         | INF/db:setup 99 [*] Index "devices"."providerChannel" created
stf_1   | 13:39:08 stf.1         | INF/db:setup 99 [*] Index "users"."adbKeys" is ready
stf_1   | 13:39:08 stf.1         | INF/db:setup 99 [*] Waiting for index "devices"."owner"
stf_1   | 13:39:08 stf.1         | INF/db:setup 99 [*] Waiting for index "devices"."present"
stf_1   | 13:39:08 stf.1         | INF/db:setup 99 [*] Waiting for index "devices"."providerChannel"
stf_1   | 13:39:08 stf.1         | INF/db:setup 99 [*] Index "devices"."owner" is ready
stf_1   | 13:39:08 stf.1         | INF/db:setup 99 [*] Index "devices"."present" is ready
stf_1   | 13:39:08 stf.1         | INF/db:setup 99 [*] Index "devices"."providerChannel" is ready
stf_1   | 13:39:08 stf.1         | INF/util:procutil 19 [*] Forking "/app/lib/cli.js triproxy app001 --bind-pub tcp://127.0.0.1:7111 --bind-dealer tcp://127.0.0.1:7112 --bind-pull tcp://127.0.0.1:7113"
stf_1   | 13:39:08 stf.1         | INF/util:procutil 19 [*] Forking "/app/lib/cli.js triproxy dev001 --bind-pub tcp://127.0.0.1:7114 --bind-dealer tcp://127.0.0.1:7115 --bind-pull tcp://127.0.0.1:7116"
stf_1   | 13:39:08 stf.1         | INF/util:procutil 19 [*] Forking "/app/lib/cli.js processor proc001 --connect-app-dealer tcp://127.0.0.1:7112 --connect-dev-dealer tcp://127.0.0.1:7115"
stf_1   | 13:39:08 stf.1         | INF/util:procutil 19 [*] Forking "/app/lib/cli.js processor proc002 --connect-app-dealer tcp://127.0.0.1:7112 --connect-dev-dealer tcp://127.0.0.1:7115"
stf_1   | 13:39:08 stf.1         | INF/util:procutil 19 [*] Forking "/app/lib/cli.js reaper reaper001 --connect-push tcp://127.0.0.1:7116 --connect-sub tcp://127.0.0.1:7111"
stf_1   | 13:39:08 stf.1         | INF/util:procutil 19 [*] Forking "/app/lib/cli.js provider --name 153d0ca0c324 --min-port 7400 --max-port 7700 --connect-sub tcp://127.0.0.1:7114 --connect-push tcp://127.0.0.1:7116 --group-timeout 900 --public-ip localhost --storage-url http://localhost:7100/ --adb-host 127.0.0.1 --adb-port 5037 --vnc-initial-size 600x800"
stf_1   | 13:39:08 stf.1         | INF/util:procutil 19 [*] Forking "/app/lib/cli.js auth-mock --port 7120 --secret kute kittykat --app-url http://localhost:7100/"
stf_1   | 13:39:08 stf.1         | INF/util:procutil 19 [*] Forking "/app/lib/cli.js app --port 7105 --secret kute kittykat --auth-url http://localhost:7100/auth/mock/ --websocket-url http://localhost:7110/"
stf_1   | 13:39:08 stf.1         | INF/util:procutil 19 [*] Forking "/app/lib/cli.js websocket --port 7110 --secret kute kittykat --storage-url http://localhost:7100/ --connect-sub tcp://127.0.0.1:7111 --connect-push tcp://127.0.0.1:7113"
stf_1   | 13:39:08 stf.1         | INF/util:procutil 19 [*] Forking "/app/lib/cli.js storage-temp --port 7102"
stf_1   | 13:39:08 stf.1         | INF/util:procutil 19 [*] Forking "/app/lib/cli.js storage-plugin-image --port 7103 --storage-url http://localhost:7100/"
stf_1   | 13:39:08 stf.1         | INF/util:procutil 19 [*] Forking "/app/lib/cli.js storage-plugin-apk --port 7104 --storage-url http://localhost:7100/"
stf_1   | 13:39:08 stf.1         | INF/util:procutil 19 [*] Forking "/app/lib/cli.js poorxy --port 7100 --app-url http://localhost:7105/ --auth-url http://localhost:7120/ --websocket-url http://localhost:7110/ --storage-url http://localhost:7102/ --storage-plugin-image-url http://localhost:7103/ --storage-plugin-apk-url http://localhost:7104/"
stf_1   | 13:39:12 stf.1         | INF/triproxy 112 [dev001] PUB socket bound on tcp://127.0.0.1:7114
stf_1   | 13:39:12 stf.1         | INF/triproxy 112 [dev001] DEALER socket bound on tcp://127.0.0.1:7115
stf_1   | 13:39:12 stf.1         | INF/triproxy 112 [dev001] PULL socket bound on tcp://127.0.0.1:7116
stf_1   | 13:39:12 stf.1         | INF/triproxy 111 [app001] PUB socket bound on tcp://127.0.0.1:7111
stf_1   | 13:39:12 stf.1         | INF/triproxy 111 [app001] DEALER socket bound on tcp://127.0.0.1:7112
stf_1   | 13:39:12 stf.1         | INF/triproxy 111 [app001] PULL socket bound on tcp://127.0.0.1:7113
stf_1   | 13:39:13 stf.1         | INF/poorxy 167 [*] Listening on port 7100
stf_1   | 13:39:13 stf.1         | INF/db 117 [proc001] Connecting to 127.0.0.1:28015
stf_1   | 13:39:13 stf.1         | INF/processor 117 [proc001] App dealer connected to "tcp://127.0.0.1:7112"
stf_1   | 13:39:13 stf.1         | INF/processor 117 [proc001] Device dealer connected to "tcp://127.0.0.1:7115"
stf_1   | 13:39:13 stf.1         | INF/db 122 [proc002] Connecting to 127.0.0.1:28015
stf_1   | 13:39:13 stf.1         | INF/reaper 127 [reaper001] Subscribing to permanent channel "*ALL"
stf_1   | 13:39:13 stf.1         | INF/reaper 127 [reaper001] Reaping devices with no heartbeat
stf_1   | 13:39:14 stf.1         | INF/db 127 [reaper001] Connecting to 127.0.0.1:28015
stf_1   | 13:39:14 stf.1         | INF/processor 122 [proc002] App dealer connected to "tcp://127.0.0.1:7112"
stf_1   | 13:39:14 stf.1         | INF/reaper 127 [reaper001] Receiving input from "tcp://127.0.0.1:7111"
stf_1   | 13:39:14 stf.1         | INF/processor 122 [proc002] Device dealer connected to "tcp://127.0.0.1:7115"
stf_1   | 13:39:14 stf.1         | INF/reaper 127 [reaper001] Sending output to "tcp://127.0.0.1:7116"





