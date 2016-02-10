


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
Starting droydstf_stf_1...
Starting droydstf_nginx_1...
Attaching to droydstf_stf_1, droydstf_nginx_1
stf_1   | 14:25:37 system        | stf.1 started (pid=11)
stf_1   | 14:25:37 system        | droydserver.1 started (pid=12)
stf_1   | 14:25:37 system        | rethinkdb.1 started (pid=13)
stf_1   | 14:25:38 rethinkdb.1   | Recursively removing directory /data/rethinkdb_data/tmp
stf_1   | 14:25:38 rethinkdb.1   | Initializing directory /data/rethinkdb_data
stf_1   | 14:25:38 rethinkdb.1   | Running rethinkdb 2.2.4~0trusty (GCC 4.8.2)...
stf_1   | 14:25:38 rethinkdb.1   | Running on Linux 4.0.9-boot2docker x86_64
stf_1   | 14:25:38 rethinkdb.1   | Loading data from directory /data/rethinkdb_data
stf_1   | 14:25:38 stf.1         | INF/util:procutil 15 [*] Forking "/app/lib/cli.js migrate"
stf_1   | 14:25:38 rethinkdb.1   | Listening for intracluster connections on port 29015
stf_1   | 14:25:38 rethinkdb.1   | Listening for client driver connections on port 28015
stf_1   | 14:25:38 rethinkdb.1   | Listening for administrative HTTP connections on port 8080
stf_1   | 14:25:38 rethinkdb.1   | Listening on addresses: 127.0.0.1, 172.17.0.1, ::1, fe80::42:acff:fe11:1%6
stf_1   | 14:25:38 rethinkdb.1   | Server ready, "dfc7f26bd44e_xez" 2c8229b6-363b-4eba-9c94-9518262af243
stf_1   | 14:25:38 stf.1         | INF/db 99 [*] Connecting to 127.0.0.1:28015
stf_1   | 14:25:38 stf.1         | INF/db:setup 99 [*] Database "stf" created
stf_1   | 14:25:41 stf.1         | INF/db:setup 99 [*] Table "users" created
stf_1   | 14:25:41 stf.1         | INF/db:setup 99 [*] Index "users"."adbKeys" created
stf_1   | 14:25:41 stf.1         | INF/db:setup 99 [*] Waiting for index "users"."adbKeys"
stf_1   | 14:25:41 stf.1         | INF/db:setup 99 [*] Table "devices" created
stf_1   | 14:25:41 stf.1         | INF/db:setup 99 [*] Table "logs" created
stf_1   | 14:25:41 stf.1         | INF/db:setup 99 [*] Index "devices"."owner" created
stf_1   | 14:25:41 stf.1         | INF/db:setup 99 [*] Waiting for index "devices"."owner"
stf_1   | 14:25:41 stf.1         | INF/db:setup 99 [*] Index "devices"."present" created
stf_1   | 14:25:41 stf.1         | INF/db:setup 99 [*] Index "devices"."providerChannel" created
stf_1   | 14:25:41 stf.1         | INF/db:setup 99 [*] Waiting for index "devices"."present"
stf_1   | 14:25:41 stf.1         | INF/db:setup 99 [*] Waiting for index "devices"."providerChannel"
stf_1   | 14:25:41 stf.1         | INF/db:setup 99 [*] Index "users"."adbKeys" is ready
stf_1   | 14:25:41 stf.1         | INF/db:setup 99 [*] Index "devices"."owner" is ready
stf_1   | 14:25:41 stf.1         | INF/db:setup 99 [*] Index "devices"."present" is ready
stf_1   | 14:25:41 stf.1         | INF/db:setup 99 [*] Index "devices"."providerChannel" is ready
stf_1   | 14:25:41 droydserver.1 |  * Running on http://0.0.0.0:5000/ (Press CTRL+C to quit)
stf_1   | 14:25:42 stf.1         | INF/db:setup 99 [*] Table "accessTokens" created
stf_1   | 14:25:42 stf.1         | INF/db:setup 99 [*] Index "accessTokens"."email" created
stf_1   | 14:25:42 stf.1         | INF/db:setup 99 [*] Waiting for index "accessTokens"."email"
stf_1   | 14:25:42 stf.1         | INF/db:setup 99 [*] Table "vncauth" created
stf_1   | 14:25:42 stf.1         | INF/db:setup 99 [*] Index "vncauth"."response" created
stf_1   | 14:25:42 stf.1         | INF/db:setup 99 [*] Index "accessTokens"."email" is ready
stf_1   | 14:25:42 stf.1         | INF/db:setup 99 [*] Waiting for index "vncauth"."response"
stf_1   | 14:25:42 stf.1         | INF/db:setup 99 [*] Index "vncauth"."responsePerDevice" created
stf_1   | 14:25:42 stf.1         | INF/db:setup 99 [*] Waiting for index "vncauth"."responsePerDevice"
stf_1   | 14:25:42 stf.1         | INF/db:setup 99 [*] Index "vncauth"."response" is ready
stf_1   | 14:25:42 stf.1         | INF/db:setup 99 [*] Index "vncauth"."responsePerDevice" is ready
stf_1   | 14:25:42 stf.1         | INF/util:procutil 15 [*] Forking "/app/lib/cli.js triproxy app001 --bind-pub tcp://127.0.0.1:7111 --bind-dealer tcp://127.0.0.1:7112 --bind-pull tcp://127.0.0.1:7113"
stf_1   | 14:25:42 stf.1         | INF/util:procutil 15 [*] Forking "/app/lib/cli.js triproxy dev001 --bind-pub tcp://127.0.0.1:7114 --bind-dealer tcp://127.0.0.1:7115 --bind-pull tcp://127.0.0.1:7116"
stf_1   | 14:25:42 stf.1         | INF/util:procutil 15 [*] Forking "/app/lib/cli.js processor proc001 --connect-app-dealer tcp://127.0.0.1:7112 --connect-dev-dealer tcp://127.0.0.1:7115"
stf_1   | 14:25:42 stf.1         | INF/util:procutil 15 [*] Forking "/app/lib/cli.js processor proc002 --connect-app-dealer tcp://127.0.0.1:7112 --connect-dev-dealer tcp://127.0.0.1:7115"
stf_1   | 14:25:42 stf.1         | INF/util:procutil 15 [*] Forking "/app/lib/cli.js reaper reaper001 --connect-push tcp://127.0.0.1:7116 --connect-sub tcp://127.0.0.1:7111"
stf_1   | 14:25:42 stf.1         | INF/util:procutil 15 [*] Forking "/app/lib/cli.js provider --name dfc7f26bd44e --min-port 7400 --max-port 7700 --connect-sub tcp://127.0.0.1:7114 --connect-push tcp://127.0.0.1:7116 --group-timeout 900 --public-ip 192.168.99.100 --storage-url http://localhost:7100/ --adb-host 127.0.0.1 --adb-port 5037 --vnc-initial-size 600x800"
stf_1   | 14:25:42 stf.1         | INF/util:procutil 15 [*] Forking "/app/lib/cli.js auth-mock --port 7120 --secret kute kittykat --app-url http://192.168.99.100:7100/"
stf_1   | 14:25:42 stf.1         | INF/util:procutil 15 [*] Forking "/app/lib/cli.js app --port 7105 --secret kute kittykat --auth-url http://192.168.99.100:7100/auth/mock/ --websocket-url http://192.168.99.100:7110/"
stf_1   | 14:25:42 stf.1         | INF/util:procutil 15 [*] Forking "/app/lib/cli.js websocket --port 7110 --secret kute kittykat --storage-url http://localhost:7100/ --connect-sub tcp://127.0.0.1:7111 --connect-push tcp://127.0.0.1:7113"
stf_1   | 14:25:42 stf.1         | INF/util:procutil 15 [*] Forking "/app/lib/cli.js storage-temp --port 7102"
stf_1   | 14:25:42 stf.1         | INF/util:procutil 15 [*] Forking "/app/lib/cli.js storage-plugin-image --port 7103 --storage-url http://localhost:7100/"
stf_1   | 14:25:42 stf.1         | INF/util:procutil 15 [*] Forking "/app/lib/cli.js storage-plugin-apk --port 7104 --storage-url http://localhost:7100/"
stf_1   | 14:25:42 stf.1         | INF/util:procutil 15 [*] Forking "/app/lib/cli.js poorxy --port 7100 --app-url http://localhost:7105/ --auth-url http://localhost:7120/ --websocket-url http://localhost:7110/ --storage-url http://localhost:7102/ --storage-plugin-image-url http://localhost:7103/ --storage-plugin-apk-url http://localhost:7104/"
stf_1   | 14:25:45 stf.1         | INF/triproxy 116 [dev001] PUB socket bound on tcp://127.0.0.1:7114
stf_1   | 14:25:45 stf.1         | INF/triproxy 116 [dev001] DEALER socket bound on tcp://127.0.0.1:7115
stf_1   | 14:25:45 stf.1         | INF/triproxy 116 [dev001] PULL socket bound on tcp://127.0.0.1:7116
stf_1   | 14:25:45 stf.1         | INF/triproxy 115 [app001] PUB socket bound on tcp://127.0.0.1:7111
stf_1   | 14:25:45 stf.1         | INF/triproxy 115 [app001] DEALER socket bound on tcp://127.0.0.1:7112
stf_1   | 14:25:45 stf.1         | INF/triproxy 115 [app001] PULL socket bound on tcp://127.0.0.1:7113
stf_1   | 14:25:47 stf.1         | INF/db 117 [proc001] Connecting to 127.0.0.1:28015
stf_1   | 14:25:47 stf.1         | INF/reaper 131 [reaper001] Subscribing to permanent channel "*ALL"
stf_1   | 14:25:47 stf.1         | INF/processor 117 [proc001] App dealer connected to "tcp://127.0.0.1:7112"
stf_1   | 14:25:47 stf.1         | INF/reaper 131 [reaper001] Reaping devices with no heartbeat
stf_1   | 14:25:47 stf.1         | INF/db 131 [reaper001] Connecting to 127.0.0.1:28015
stf_1   | 14:25:47 stf.1         | INF/processor 117 [proc001] Device dealer connected to "tcp://127.0.0.1:7115"
stf_1   | 14:25:47 stf.1         | INF/reaper 131 [reaper001] Receiving input from "tcp://127.0.0.1:7111"
stf_1   | 14:25:47 stf.1         | INF/reaper 131 [reaper001] Sending output to "tcp://127.0.0.1:7116"
stf_1   | 14:25:47 stf.1         | INF/db 126 [proc002] Connecting to 127.0.0.1:28015
stf_1   | 14:25:47 stf.1         | INF/poorxy 175 [*] Listening on port 7100
stf_1   | 14:25:47 stf.1         | INF/processor 126 [proc002] App dealer connected to "tcp://127.0.0.1:7112"
stf_1   | 14:25:47 stf.1         | INF/processor 126 [proc002] Device dealer connected to "tcp://127.0.0.1:7115"
stf_1   | 14:25:48 stf.1         | INF/auth-mock 145 [*] Listening on port 7120
stf_1   | 14:25:49 stf.1         | INF/storage:plugins:image 165 [*] Listening on port 7103
stf_1   | 14:25:49 stf.1         | INF/storage:plugins:apk 170 [*] Listening on port 7104
stf_1   | 14:25:49 stf.1         | INF/storage:temp 160 [*] Listening on port 7102
stf_1   | 14:25:49 stf.1         | INF/provider 140 [*] Subscribing to permanent channel "s8RFg7kCSpmm4jGy+jXqDg=="
stf_1   | 14:25:49 stf.1         | INF/provider 140 [*] Sending output to "tcp://127.0.0.1:7116"
stf_1   | 14:25:49 stf.1         | INF/provider 140 [*] Receiving input from "tcp://127.0.0.1:7114"
stf_1   | 14:25:49 stf.1         | INF/provider 140 [*] Tracking devices
stf_1   | 14:25:49 stf.1         | INF/provider 140 [*] Found device "0915f9e0b3900c05" (offline)
stf_1   | 14:25:49 stf.1         | INF/provider 140 [*] Found device "0915f9ece8942b04" (offline)
stf_1   | 14:25:49 stf.1         | INF/provider 140 [*] Registered device "0915f9e0b3900c05"
stf_1   | 14:25:49 stf.1         | INF/reaper 131 [reaper001] Device "0915f9e0b3900c05" is present
stf_1   | 14:25:49 stf.1         | INF/provider 140 [*] Registered device "0915f9ece8942b04"
stf_1   | 14:25:49 stf.1         | INF/reaper 131 [reaper001] Device "0915f9ece8942b04" is present
stf_1   | 14:25:50 stf.1         | INF/app 150 [*] Using pre-built resources
stf_1   | 14:25:50 stf.1         | INF/app 150 [*] Listening on port 7105
stf_1   | 14:25:50 stf.1         | INF/db 150 [*] Connecting to 127.0.0.1:28015
stf_1   | 14:25:50 stf.1         | INF/websocket 155 [*] Subscribing to permanent channel "*ALL"
stf_1   | 14:25:50 stf.1         | INF/websocket 155 [*] Listening on port 7110
stf_1   | 14:25:50 stf.1         | INF/db 155 [*] Connecting to 127.0.0.1:28015
stf_1   | 14:25:50 stf.1         | INF/websocket 155 [*] Sending output to "tcp://127.0.0.1:7113"
stf_1   | 14:25:50 stf.1         | INF/websocket 155 [*] Receiving input from "tcp://127.0.0.1:7111"
stf_1   | 14:25:59 stf.1         | INF/provider 140 [*] Providing all 0 of 2 device(s); ignoring "0915f9e0b3900c05", "0915f9ece8942b04"
stf_1   | 14:26:02 stf.1         | INF/provider 140 [*] Device "0915f9ece8942b04" is now "device" (was "offline")
stf_1   | 14:26:03 stf.1         | INF/device:support:push 194 [0915f9ece8942b04] Sending output to "tcp://127.0.0.1:7116"
stf_1   | 14:26:03 stf.1         | INF/device 194 [0915f9ece8942b04] Preparing device
stf_1   | 14:26:04 stf.1         | INF/device:support:sub 194 [0915f9ece8942b04] Receiving input from "tcp://127.0.0.1:7114"
stf_1   | 14:26:04 stf.1         | INF/device:support:sub 194 [0915f9ece8942b04] Subscribing to permanent channel "*ALL"
stf_1   | 14:26:04 stf.1         | INF/device:support:properties 194 [0915f9ece8942b04] Loading properties
stf_1   | 14:26:04 stf.1         | INF/device:support:abi 194 [0915f9ece8942b04] Supports ABIs arm64-v8a, armeabi-v7a, armeabi
stf_1   | 14:26:05 stf.1         | INF/device:resources:service 194 [0915f9ece8942b04] Checking whether we need to install STFService
stf_1   | 14:26:05 stf.1         | INF/device:resources:service 194 [0915f9ece8942b04] Running version check
stf_1   | 14:26:06 stf.1         | INF/device:resources:service 194 [0915f9ece8942b04] STFService up to date
stf_1   | 14:26:06 stf.1         | INF/device:plugins:service 194 [0915f9ece8942b04] Launching agent
stf_1   | 14:26:07 stf.1         | INF/device:plugins:service 194 [0915f9ece8942b04] Agent says: "Listening on port 1090"
stf_1   | 14:26:07 stf.1         | INF/device:plugins:service 194 [0915f9ece8942b04] Launching service
stf_1   | 14:26:07 stf.1         | INF/device:plugins:service 194 [0915f9ece8942b04] Agent says: "InputClient started"
stf_1   | 14:26:07 stf.1         | INF/device:plugins:display 194 [0915f9ece8942b04] Reading display info
stf_1   | 14:26:07 stf.1         | INF/device:plugins:phone 194 [0915f9ece8942b04] Fetching phone info
stf_1   | 14:26:07 stf.1         | INF/device:plugins:identity 194 [0915f9ece8942b04] Solving identity
stf_1   | 14:26:07 stf.1         | INF/device:plugins:solo 194 [0915f9ece8942b04] Subscribing to permanent channel "4G+m9QsQmxqZPk5Y18e3VaSr6M8="
stf_1   | 14:26:07 stf.1         | INF/device:plugins:screen:stream 194 [0915f9ece8942b04] Starting WebSocket server on port 7400
stf_1   | 14:26:07 stf.1         | WRN/device:plugins:data 194 [0915f9ece8942b04] Unable to find device data { serial: '0915f9ece8942b04',
stf_1   | 14:26:07 stf.1         |   platform: 'Android',
stf_1   | 14:26:07 stf.1         |   manufacturer: 'SAMSUNG',
stf_1   | 14:26:07 stf.1         |   operator: 'Orange F',
stf_1   | 14:26:07 stf.1         |   model: 'SM-G920F',
stf_1   | 14:26:07 stf.1         |   version: '5.1.1',
stf_1   | 14:26:07 stf.1         |   abi: 'arm64-v8a',
stf_1   | 14:26:07 stf.1         |   sdk: '22',
stf_1   | 14:26:07 stf.1         |   product: 'zerofltexx',
stf_1   | 14:26:07 stf.1         |   display:
stf_1   | 14:26:07 stf.1         |    { id: 0,
stf_1   | 14:26:07 stf.1         |      width: 1440,
stf_1   | 14:26:07 stf.1         |      height: 2560,
stf_1   | 14:26:07 stf.1         |      xdpi: 580.5709838867188,
stf_1   | 14:26:07 stf.1         |      ydpi: 580.5709838867188,
stf_1   | 14:26:07 stf.1         |      fps: 59,
stf_1   | 14:26:07 stf.1         |      density: 4,
stf_1   | 14:26:07 stf.1         |      rotation: 0,
stf_1   | 14:26:07 stf.1         |      secure: true,
stf_1   | 14:26:07 stf.1         |      size: 5.059173885071115,
stf_1   | 14:26:07 stf.1         |      url: 'ws://192.168.99.100:7400' },
stf_1   | 14:26:07 stf.1         |   phone:
stf_1   | 14:26:07 stf.1         |    { imei: '355922070558636',
stf_1   | 14:26:07 stf.1         |      iccid: '89330115462696899830',
stf_1   | 14:26:07 stf.1         |      network: 'LTE' } }
stf_1   | 14:26:07 stf.1         | INF/device:plugins:touch 194 [0915f9ece8942b04] Touch origin is top left
stf_1   | 14:26:07 stf.1         | INF/device:plugins:touch 194 [0915f9ece8942b04] Requesting touch consumer to start
stf_1   | 14:26:07 stf.1         | INF/device:plugins:touch 194 [0915f9ece8942b04] Launching screen service
stf_1   | 14:26:08 stf.1         | INF/device:plugins:touch 194 [0915f9ece8942b04] Connecting to minitouch service
stf_1   | 14:26:09 stf.1         | INF/device:plugins:touch 194 [0915f9ece8942b04] minitouch says: "Type B touch device sec_touchscreen (4095x4095 with 10 contacts) detected on /dev/input/event1 (score 1100)"
stf_1   | 14:26:11 stf.1         | INF/device:plugins:touch 194 [0915f9ece8942b04] Reading minitouch banner
stf_1   | 14:26:11 stf.1         | INF/device:plugins:touch 194 [0915f9ece8942b04] minitouch says: "Connection established"
stf_1   | 14:26:11 stf.1         | INF/device:plugins:vnc 194 [0915f9ece8942b04] Starting VNC server on port 7402
stf_1   | 14:26:11 stf.1         | INF/device:plugins:browser 194 [0915f9ece8942b04] Loading browser list
stf_1   | 14:26:11 stf.1         | INF/device:plugins:browser 194 [0915f9ece8942b04] Updating browser list
stf_1   | 14:26:11 stf.1         | INF/device:plugins:mute 194 [0915f9ece8942b04] Will not mute master volume during use
stf_1   | 14:26:11 stf.1         | INF/device:plugins:forward 194 [0915f9ece8942b04] Launching reverse port forwarding service
stf_1   | 14:26:11 stf.1         | INF/device:plugins:forward 194 [0915f9ece8942b04] Connecting to reverse port forwarding service
stf_1   | 14:26:11 stf.1         | INF/device:plugins:connect 194 [0915f9ece8942b04] Listening on port 7401
stf_1   | 14:26:11 stf.1         | INF/device 194 [0915f9ece8942b04] Fully operational
stf_1   | 14:26:19 stf.1         | INF/reaper 131 [reaper001] Reaping device "0915f9e0b3900c05" due to heartbeat timeout
stf_1   | 14:27:30 stf.1         | INF/auth-mock 145 [::ffff:127.0.0.1] Authenticated "stf@openstf.io"
stf_1   | 14:27:30 stf.1         | WRN/util:datautil 150 [*] Device database does not have a match for device "0915f9ece8942b04" (model "SM-G920F"/"zerofltexx")
stf_1   | 14:27:30 stf.1         | WRN/util:datautil 150 [*] Device database does not have a match for device "0915f9e0b3900c05" (model "undefined"/"undefined")
stf_1   | 14:27:38 stf.1         | WRN/util:datautil 150 [*] Device database does not have a match for device "0915f9ece8942b04" (model "SM-G920F"/"zerofltexx")
stf_1   | 14:29:24 system        | SIGTERM received
stf_1   | 14:29:24 system        | sending SIGTERM to stf.1 (pid 11)
stf_1   | 14:29:25 system        | sending SIGTERM to droydserver.1 (pid 12)
stf_1   | 14:29:25 system        | sending SIGTERM to rethinkdb.1 (pid 13)
stf_1   | 14:29:24 stf.1         | INF/util:lifecycle 194 [0915f9ece8942b04] Winding down for graceful exit
stf_1   | 14:29:24 stf.1         | INF/util:lifecycle 155 [*] Winding down for graceful exit
stf_1   | 14:29:24 stf.1         | INF/util:lifecycle 150 [*] Winding down for graceful exit
stf_1   | 14:29:24 stf.1         | INF/util:lifecycle 145 [*] Winding down for graceful exit
stf_1   | 14:29:24 stf.1         | INF/auth-mock 145 [*] Waiting for client connections to end
stf_1   | 14:29:24 stf.1         | INF/util:lifecycle 140 [*] Winding down for graceful exit
stf_1   | 14:29:24 stf.1         | INF/util:lifecycle 131 [reaper001] Winding down for graceful exit
stf_1   | 14:29:24 stf.1         | INF/util:lifecycle 126 [proc002] Winding down for graceful exit
stf_1   | 14:29:24 stf.1         | INF/util:lifecycle 117 [proc001] Winding down for graceful exit
stf_1   | 14:29:24 stf.1         | INF/util:lifecycle 116 [dev001] Winding down for graceful exit
stf_1   | 14:29:24 stf.1         | INF/cli:local 15 [*] Received SIGTERM, waiting for processes to terminate
stf_1   | 14:29:24 stf.1         | INF/util:lifecycle 115 [app001] Winding down for graceful exit
stf_1   | 14:29:25 stf.1         | INF/device:plugins:screen:stream 194 [0915f9ece8942b04] Requesting frame producer to stop
stf_1   | 14:29:25 stf.1         | INF/util:lifecycle 155 [*] Winding down for graceful exit
stf_1   | 14:29:25 system        | droydserver.1 stopped (rc=-15)
stf_1   | 14:29:25 rethinkdb.1   | Server got SIGTERM from pid 1, uid 0; shutting down...
stf_1   | 14:29:25 rethinkdb.1   | Shutting down client connections...
stf_1   | 14:29:25 rethinkdb.1   | All client connections closed.
stf_1   | 14:29:25 rethinkdb.1   | Shutting down storage engine... (This may take a while if you had a lot of unflushed data in the writeback cache.)
stf_1   | 14:29:25 stf.1         | INF/util:lifecycle 117 [proc001] Winding down for graceful exit
stf_1   | 14:29:25 stf.1         | events.js:141
stf_1   | 14:29:25 stf.1         |       throw er; // Unhandled 'error' event
stf_1   | 14:29:25 stf.1         |       ^
stf_1   | 14:29:25 stf.1         |
stf_1   | 14:29:25 stf.1         | Error: write EPIPE
stf_1   | 14:29:25 stf.1         |     at Object.exports._errnoException (util.js:849:11)
stf_1   | 14:29:25 stf.1         |     at exports._exceptionWithHostPort (util.js:872:20)
stf_1   | 14:29:25 stf.1         |     at WriteWrap.afterWrite (net.js:760:14)
stf_1   | 14:29:25 stf.1         | events.js:141
stf_1   | 14:29:25 stf.1         |       throw er; // Unhandled 'error' event
stf_1   | 14:29:25 stf.1         |       ^
stf_1   | 14:29:25 stf.1         |
stf_1   | 14:29:25 stf.1         | Error: write EPIPE
stf_1   | 14:29:25 stf.1         |     at Object.exports._errnoException (util.js:849:11)
stf_1   | 14:29:25 stf.1         |     at exports._exceptionWithHostPort (util.js:872:20)
stf_1   | 14:29:25 stf.1         |     at WriteWrap.afterWrite (net.js:760:14)
stf_1   | 14:29:25 stf.1         | WRN/db 155 [*] Connection closed
stf_1   | 14:29:25 stf.1         | INF/db 155 [*] Connecting to 127.0.0.1:28015
stf_1   | 14:29:25 rethinkdb.1   | Storage engine shut down.
stf_1   | 14:29:25 stf.1         | WRN/db 117 [proc001] Connection closed
stf_1   | 14:29:25 stf.1         | INF/db 117 [proc001] Connecting to 127.0.0.1:28015
stf_1   | 14:29:25 stf.1         | events.js:141
stf_1   | 14:29:25 stf.1         |       throw er; // Unhandled 'error' event
stf_1   | 14:29:25 stf.1         |       ^
stf_1   | 14:29:25 stf.1         |
stf_1   | 14:29:25 stf.1         | Error: write EPIPE
stf_1   | 14:29:25 stf.1         |     at Object.exports._errnoException (util.js:849:11)
stf_1   | 14:29:25 stf.1         |     at exports._exceptionWithHostPort (util.js:872:20)
stf_1   | 14:29:25 stf.1         |     at WriteWrap.afterWrite (net.js:760:14)
stf_1   | 14:29:25 system        | rethinkdb.1 stopped (rc=-15)
stf_1   | 14:29:25 stf.1         | FTL/cli:local 15 [*] Child process had an error ExitError: Exit code "1"
stf_1   | 14:29:25 stf.1         |     at ChildProcess.<anonymous> (/app/lib/util/procutil.js:49:23)
stf_1   | 14:29:25 stf.1         |     at emitTwo (events.js:87:13)
stf_1   | 14:29:25 stf.1         |     at ChildProcess.emit (events.js:172:7)
stf_1   | 14:29:25 stf.1         |     at Process.ChildProcess._handle.onexit (internal/child_process.js:200:12)
stf_1   | 14:29:25 stf.1         | INF/util:lifecycle 140 [*] Winding down for graceful exit
stf_1   | 14:29:25 stf.1         | INF/cli:local 15 [*] Shutting down all child processes
stf_1   | 14:29:25 stf.1         | INF/provider 140 [*] Gracefully killing device worker "0915f9ece8942b04"
stf_1   | 14:29:25 stf.1         | INF/provider 140 [*] Device worker "0915f9ece8942b04" stopped cleanly
stf_1   | 14:29:25 stf.1         | INF/provider 140 [*] Device worker "0915f9ece8942b04" has retired
stf_1   | 14:29:25 system        | stf.1 stopped (rc=-15)
stf_1   | 14:29:35 system        | rethinkdb.1 started (pid=11)
stf_1   | 14:29:35 system        | stf.1 started (pid=12)
stf_1   | 14:29:35 system        | droydserver.1 started (pid=13)
stf_1   | 14:29:35 rethinkdb.1   | Running rethinkdb 2.2.4~0trusty (GCC 4.8.2)...
stf_1   | 14:29:35 rethinkdb.1   | Running on Linux 4.0.9-boot2docker x86_64
stf_1   | 14:29:35 rethinkdb.1   | Loading data from directory /data/rethinkdb_data
stf_1   | 14:29:35 rethinkdb.1   | Listening for intracluster connections on port 29015
stf_1   | 14:29:35 stf.1         | INF/util:procutil 17 [*] Forking "/app/lib/cli.js migrate"
stf_1   | 14:29:35 rethinkdb.1   | Listening for client driver connections on port 28015
stf_1   | 14:29:35 rethinkdb.1   | Listening for administrative HTTP connections on port 8080
stf_1   | 14:29:36 stf.1         | INF/db 99 [*] Connecting to 127.0.0.1:28015
stf_1   | 14:29:36 stf.1         | INF/db:setup 99 [*] Database "stf" already exists
stf_1   | 14:29:36 stf.1         | INF/db:setup 99 [*] Table "users" already exists
stf_1   | 14:29:36 stf.1         | INF/db:setup 99 [*] Table "accessTokens" already exists
stf_1   | 14:29:36 stf.1         | INF/db:setup 99 [*] Table "vncauth" already exists
stf_1   | 14:29:36 stf.1         | INF/db:setup 99 [*] Table "devices" already exists
stf_1   | 14:29:36 stf.1         | INF/db:setup 99 [*] Table "logs" already exists
stf_1   | 14:29:36 rethinkdb.1   | Listening on addresses: 127.0.0.1, 172.17.0.3, ::1, fe80::42:acff:fe11:3%10
stf_1   | 14:29:36 rethinkdb.1   | Server ready, "dfc7f26bd44e_xez" 2c8229b6-363b-4eba-9c94-9518262af243
stf_1   | 14:29:37 stf.1         | INF/db:setup 99 [*] Index "users"."adbKeys" already exists
stf_1   | 14:29:37 stf.1         | INF/db:setup 99 [*] Waiting for index "users"."adbKeys"
stf_1   | 14:29:37 stf.1         | INF/db:setup 99 [*] Index "vncauth"."response" already exists
stf_1   | 14:29:37 stf.1         | INF/db:setup 99 [*] Waiting for index "vncauth"."response"
stf_1   | 14:29:37 stf.1         | INF/db:setup 99 [*] Index "vncauth"."responsePerDevice" already exists
stf_1   | 14:29:37 stf.1         | INF/db:setup 99 [*] Index "users"."adbKeys" is ready
stf_1   | 14:29:37 stf.1         | INF/db:setup 99 [*] Index "devices"."owner" already exists
stf_1   | 14:29:37 stf.1         | INF/db:setup 99 [*] Index "devices"."present" already exists
stf_1   | 14:29:37 stf.1         | INF/db:setup 99 [*] Index "devices"."providerChannel" already exists
stf_1   | 14:29:37 stf.1         | INF/db:setup 99 [*] Index "vncauth"."response" is ready
stf_1   | 14:29:37 stf.1         | INF/db:setup 99 [*] Waiting for index "vncauth"."responsePerDevice"
stf_1   | 14:29:37 stf.1         | INF/db:setup 99 [*] Waiting for index "devices"."owner"
nginx_1 | 192.168.99.1 - - [09/Feb/2016:14:26:58 +0000] "GET / HTTP/1.1" 302 118 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2) AppleWebKit/601.3.9 (KHTML, like Gecko) Version/9.0.2 Safari/601.3.9"
stf_1   | 14:29:37 stf.1         | INF/db:setup 99 [*] Waiting for index "devices"."present"
stf_1   | 14:29:37 stf.1         | INF/db:setup 99 [*] Waiting for index "devices"."providerChannel"
stf_1   | 14:29:37 stf.1         | INF/db:setup 99 [*] Index "vncauth"."responsePerDevice" is ready
stf_1   | 14:29:37 stf.1         | INF/db:setup 99 [*] Index "devices"."owner" is ready
stf_1   | 14:29:37 stf.1         | INF/db:setup 99 [*] Index "devices"."present" is ready
stf_1   | 14:29:37 stf.1         | INF/db:setup 99 [*] Index "devices"."providerChannel" is ready
stf_1   | 14:29:38 stf.1         | INF/db:setup 99 [*] Index "accessTokens"."email" already exists
stf_1   | 14:29:38 stf.1         | INF/db:setup 99 [*] Waiting for index "accessTokens"."email"
stf_1   | 14:29:38 stf.1         | INF/db:setup 99 [*] Index "accessTokens"."email" is ready
stf_1   | 14:29:38 stf.1         | INF/util:procutil 17 [*] Forking "/app/lib/cli.js triproxy app001 --bind-pub tcp://127.0.0.1:7111 --bind-dealer tcp://127.0.0.1:7112 --bind-pull tcp://127.0.0.1:7113"
stf_1   | 14:29:38 stf.1         | INF/util:procutil 17 [*] Forking "/app/lib/cli.js triproxy dev001 --bind-pub tcp://127.0.0.1:7114 --bind-dealer tcp://127.0.0.1:7115 --bind-pull tcp://127.0.0.1:7116"
stf_1   | 14:29:38 stf.1         | INF/util:procutil 17 [*] Forking "/app/lib/cli.js processor proc001 --connect-app-dealer tcp://127.0.0.1:7112 --connect-dev-dealer tcp://127.0.0.1:7115"
stf_1   | 14:29:38 stf.1         | INF/util:procutil 17 [*] Forking "/app/lib/cli.js processor proc002 --connect-app-dealer tcp://127.0.0.1:7112 --connect-dev-dealer tcp://127.0.0.1:7115"
stf_1   | 14:29:38 stf.1         | INF/util:procutil 17 [*] Forking "/app/lib/cli.js reaper reaper001 --connect-push tcp://127.0.0.1:7116 --connect-sub tcp://127.0.0.1:7111"
stf_1   | 14:29:38 stf.1         | INF/util:procutil 17 [*] Forking "/app/lib/cli.js provider --name dfc7f26bd44e --min-port 7400 --max-port 7700 --connect-sub tcp://127.0.0.1:7114 --connect-push tcp://127.0.0.1:7116 --group-timeout 900 --public-ip 192.168.99.100 --storage-url http://localhost:7100/ --adb-host 127.0.0.1 --adb-port 5037 --vnc-initial-size 600x800"
stf_1   | 14:29:38 stf.1         | INF/util:procutil 17 [*] Forking "/app/lib/cli.js auth-mock --port 7120 --secret kute kittykat --app-url http://192.168.99.100:7100/"
stf_1   | 14:29:38 stf.1         | INF/util:procutil 17 [*] Forking "/app/lib/cli.js app --port 7105 --secret kute kittykat --auth-url http://192.168.99.100:7100/auth/mock/ --websocket-url http://192.168.99.100:7110/"
stf_1   | 14:29:38 stf.1         | INF/util:procutil 17 [*] Forking "/app/lib/cli.js websocket --port 7110 --secret kute kittykat --storage-url http://localhost:7100/ --connect-sub tcp://127.0.0.1:7111 --connect-push tcp://127.0.0.1:7113"
stf_1   | 14:29:38 stf.1         | INF/util:procutil 17 [*] Forking "/app/lib/cli.js storage-temp --port 7102"
stf_1   | 14:29:38 stf.1         | INF/util:procutil 17 [*] Forking "/app/lib/cli.js storage-plugin-image --port 7103 --storage-url http://localhost:7100/"
stf_1   | 14:29:38 stf.1         | INF/util:procutil 17 [*] Forking "/app/lib/cli.js storage-plugin-apk --port 7104 --storage-url http://localhost:7100/"
stf_1   | 14:29:38 stf.1         | INF/util:procutil 17 [*] Forking "/app/lib/cli.js poorxy --port 7100 --app-url http://localhost:7105/ --auth-url http://localhost:7120/ --websocket-url http://localhost:7110/ --storage-url http://localhost:7102/ --storage-plugin-image-url http://localhost:7103/ --storage-plugin-apk-url http://localhost:7104/"
stf_1   | 14:29:38 droydserver.1 |  * Running on http://0.0.0.0:5000/ (Press CTRL+C to quit)
stf_1   | 14:29:42 stf.1         | INF/triproxy 116 [dev001] PUB socket bound on tcp://127.0.0.1:7114
stf_1   | 14:29:42 stf.1         | INF/triproxy 116 [dev001] DEALER socket bound on tcp://127.0.0.1:7115
stf_1   | 14:29:42 stf.1         | INF/triproxy 116 [dev001] PULL socket bound on tcp://127.0.0.1:7116
stf_1   | 14:29:42 stf.1         | INF/triproxy 115 [app001] PUB socket bound on tcp://127.0.0.1:7111
stf_1   | 14:29:42 stf.1         | INF/triproxy 115 [app001] DEALER socket bound on tcp://127.0.0.1:7112
stf_1   | 14:29:42 stf.1         | INF/triproxy 115 [app001] PULL socket bound on tcp://127.0.0.1:7113
stf_1   | 14:29:44 stf.1         | INF/reaper 127 [reaper001] Subscribing to permanent channel "*ALL"
stf_1   | 14:29:44 stf.1         | INF/reaper 127 [reaper001] Reaping devices with no heartbeat
stf_1   | 14:29:44 stf.1         | INF/db 127 [reaper001] Connecting to 127.0.0.1:28015
stf_1   | 14:29:44 stf.1         | INF/db 121 [proc001] Connecting to 127.0.0.1:28015
stf_1   | 14:29:44 stf.1         | INF/reaper 127 [reaper001] Receiving input from "tcp://127.0.0.1:7111"
stf_1   | 14:29:44 stf.1         | INF/reaper 127 [reaper001] Sending output to "tcp://127.0.0.1:7116"
stf_1   | 14:29:44 stf.1         | INF/processor 121 [proc001] App dealer connected to "tcp://127.0.0.1:7112"
stf_1   | 14:29:44 stf.1         | INF/db 122 [proc002] Connecting to 127.0.0.1:28015
stf_1   | 14:29:44 stf.1         | INF/processor 121 [proc001] Device dealer connected to "tcp://127.0.0.1:7115"
stf_1   | 14:29:44 stf.1         | INF/processor 122 [proc002] App dealer connected to "tcp://127.0.0.1:7112"
stf_1   | 14:29:44 stf.1         | INF/processor 122 [proc002] Device dealer connected to "tcp://127.0.0.1:7115"
stf_1   | 14:29:45 stf.1         | INF/auth-mock 141 [*] Listening on port 7120
stf_1   | 14:29:45 stf.1         | INF/storage:plugins:image 165 [*] Listening on port 7103
stf_1   | 14:29:45 stf.1         | INF/storage:plugins:apk 170 [*] Listening on port 7104
stf_1   | 14:29:45 stf.1         | INF/storage:temp 160 [*] Listening on port 7102
stf_1   | 14:29:45 stf.1         | INF/provider 140 [*] Subscribing to permanent channel "VTj0qsuuR4iQ39b3IheHgw=="
stf_1   | 14:29:45 stf.1         | INF/provider 140 [*] Sending output to "tcp://127.0.0.1:7116"
stf_1   | 14:29:45 stf.1         | INF/provider 140 [*] Receiving input from "tcp://127.0.0.1:7114"
stf_1   | 14:29:45 stf.1         | INF/provider 140 [*] Tracking devices
stf_1   | 14:29:45 stf.1         | INF/provider 140 [*] Found device "0915f9e0b3900c05" (offline)
stf_1   | 14:29:45 stf.1         | INF/reaper 127 [reaper001] Device "0915f9e0b3900c05" is present
stf_1   | 14:29:45 stf.1         | INF/provider 140 [*] Registered device "0915f9e0b3900c05"
stf_1   | 14:29:46 stf.1         | INF/app 146 [*] Using pre-built resources
stf_1   | 14:29:46 stf.1         | INF/app 146 [*] Listening on port 7105
stf_1   | 14:29:46 stf.1         | INF/db 146 [*] Connecting to 127.0.0.1:28015
stf_1   | 14:29:46 stf.1         | INF/websocket 151 [*] Subscribing to permanent channel "*ALL"
stf_1   | 14:29:46 stf.1         | INF/websocket 151 [*] Listening on port 7110
stf_1   | 14:29:46 stf.1         | INF/db 151 [*] Connecting to 127.0.0.1:28015
stf_1   | 14:29:46 stf.1         | INF/websocket 151 [*] Sending output to "tcp://127.0.0.1:7113"
stf_1   | 14:29:46 stf.1         | INF/websocket 151 [*] Receiving input from "tcp://127.0.0.1:7111"
stf_1   | 14:29:46 stf.1         | INF/poorxy 175 [*] Listening on port 7100
stf_1   | 14:29:55 stf.1         | INF/provider 140 [*] Providing all 0 of 1 device(s); ignoring "0915f9e0b3900c05"
stf_1   | 14:30:14 stf.1         | INF/reaper 127 [reaper001] Reaping device "0915f9ece8942b04" due to heartbeat timeout
stf_1   | 14:30:15 stf.1         | INF/reaper 127 [reaper001] Reaping device "0915f9e0b3900c05" due to heartbeat timeout
stf_1   | 14:30:20 system        | SIGTERM received
stf_1   | 14:30:20 system        | sending SIGTERM to stf.1 (pid 12)
stf_1   | 14:30:20 system        | sending SIGTERM to droydserver.1 (pid 13)
stf_1   | 14:30:20 system        | sending SIGTERM to rethinkdb.1 (pid 11)
stf_1   | 14:30:20 stf.1         | INF/util:lifecycle 151 [*] Winding down for graceful exit
stf_1   | 14:30:20 stf.1         | INF/util:lifecycle 146 [*] Winding down for graceful exit
stf_1   | 14:30:20 stf.1         | INF/util:lifecycle 141 [*] Winding down for graceful exit
stf_1   | 14:30:20 stf.1         | INF/auth-mock 141 [*] Waiting for client connections to end
stf_1   | 14:30:20 stf.1         | INF/util:lifecycle 140 [*] Winding down for graceful exit
stf_1   | 14:30:20 stf.1         | INF/util:lifecycle 127 [reaper001] Winding down for graceful exit
stf_1   | 14:30:20 stf.1         | INF/util:lifecycle 122 [proc002] Winding down for graceful exit
stf_1   | 14:30:20 stf.1         | INF/util:lifecycle 121 [proc001] Winding down for graceful exit
stf_1   | 14:30:20 stf.1         | INF/util:lifecycle 116 [dev001] Winding down for graceful exit
stf_1   | 14:30:20 stf.1         | INF/util:lifecycle 115 [app001] Winding down for graceful exit
stf_1   | 14:30:20 stf.1         | INF/cli:local 17 [*] Received SIGTERM, waiting for processes to terminate
stf_1   | 14:30:20 stf.1         | INF/util:lifecycle 127 [reaper001] Winding down for graceful exit
stf_1   | 14:30:20 stf.1         | INF/util:lifecycle 146 [*] Winding down for graceful exit
stf_1   | 14:30:20 stf.1         | INF/util:lifecycle 151 [*] Winding down for graceful exit
stf_1   | 14:30:20 stf.1         | WRN/db 127 [reaper001] Connection closed
stf_1   | 14:30:20 stf.1         | INF/db 127 [reaper001] Connecting to 127.0.0.1:28015
stf_1   | 14:30:20 system        | droydserver.1 stopped (rc=-15)
stf_1   | 14:30:20 rethinkdb.1   | Server got SIGTERM from pid 1, uid 0; shutting down...
stf_1   | 14:30:20 rethinkdb.1   | Shutting down client connections...
stf_1   | 14:30:20 rethinkdb.1   | All client connections closed.
stf_1   | 14:30:20 rethinkdb.1   | Shutting down storage engine... (This may take a while if you had a lot of unflushed data in the writeback cache.)
stf_1   | 14:30:20 stf.1         | INF/util:lifecycle 122 [proc002] Winding down for graceful exit
stf_1   | 14:30:20 stf.1         | WRN/db 151 [*] Connection closed
stf_1   | 14:30:20 stf.1         | events.js:141
stf_1   | 14:30:20 stf.1         |       throw er; // Unhandled 'error' event
stf_1   | 14:30:20 stf.1         |       ^
stf_1   | 14:30:20 stf.1         |
stf_1   | 14:30:20 stf.1         | Error: write EPIPE
stf_1   | 14:30:20 stf.1         |     at Object.exports._errnoException (util.js:849:11)
stf_1   | 14:30:20 stf.1         |     at exports._exceptionWithHostPort (util.js:872:20)
stf_1   | 14:30:20 stf.1         |     at WriteWrap.afterWrite (net.js:760:14)
stf_1   | 14:30:20 stf.1         | INF/db 151 [*] Connecting to 127.0.0.1:28015
stf_1   | 14:30:20 stf.1         | WRN/db 146 [*] Connection closed
stf_1   | 14:30:20 stf.1         | WRN/db 122 [proc002] Connection closed
stf_1   | 14:30:20 stf.1         | INF/db 146 [*] Connecting to 127.0.0.1:28015
stf_1   | 14:30:20 rethinkdb.1   | Storage engine shut down.
stf_1   | 14:30:20 stf.1         | INF/db 122 [proc002] Connecting to 127.0.0.1:28015
stf_1   | 14:30:20 system        | rethinkdb.1 stopped (rc=-15)
stf_1   | 14:30:20 stf.1         | FTL/cli:local 17 [*] Child process had an error ExitError: Exit code "1"
stf_1   | 14:30:20 stf.1         |     at ChildProcess.<anonymous> (/app/lib/util/procutil.js:49:23)
stf_1   | 14:30:20 stf.1         |     at emitTwo (events.js:87:13)
stf_1   | 14:30:20 stf.1         |     at ChildProcess.emit (events.js:172:7)
stf_1   | 14:30:20 stf.1         |     at Process.ChildProcess._handle.onexit (internal/child_process.js:200:12)
stf_1   | 14:30:20 stf.1         | INF/cli:local 17 [*] Shutting down all child processes
stf_1   | 14:30:20 system        | stf.1 stopped (rc=-15)
stf_1   | 14:30:24 system        | stf.1 started (pid=12)
stf_1   | 14:30:24 system        | droydserver.1 started (pid=11)
stf_1   | 14:30:24 system        | rethinkdb.1 started (pid=13)
stf_1   | 14:30:24 rethinkdb.1   | Running rethinkdb 2.2.4~0trusty (GCC 4.8.2)...
stf_1   | 14:30:24 rethinkdb.1   | Running on Linux 4.0.9-boot2docker x86_64
stf_1   | 14:30:24 rethinkdb.1   | Loading data from directory /data/rethinkdb_data
stf_1   | 14:30:25 rethinkdb.1   | Listening for intracluster connections on port 29015
stf_1   | 14:30:25 rethinkdb.1   | Listening for client driver connections on port 28015
stf_1   | 14:30:25 rethinkdb.1   | Listening for administrative HTTP connections on port 8080
stf_1   | 14:30:25 stf.1         | INF/util:procutil 17 [*] Forking "/app/lib/cli.js migrate"
stf_1   | 14:30:25 rethinkdb.1   | Listening on addresses: 127.0.0.1, 172.17.0.5, ::1, fe80::42:acff:fe11:5%14
stf_1   | 14:30:25 rethinkdb.1   | Server ready, "dfc7f26bd44e_xez" 2c8229b6-363b-4eba-9c94-9518262af243
stf_1   | 14:30:25 stf.1         | INF/db 99 [*] Connecting to 127.0.0.1:28015
stf_1   | 14:30:25 stf.1         | INF/db:setup 99 [*] Database "stf" already exists
stf_1   | 14:30:25 stf.1         | INF/db:setup 99 [*] Table "users" already exists
stf_1   | 14:30:25 stf.1         | INF/db:setup 99 [*] Table "accessTokens" already exists
stf_1   | 14:30:25 stf.1         | INF/db:setup 99 [*] Table "vncauth" already exists
stf_1   | 14:30:25 stf.1         | INF/db:setup 99 [*] Table "devices" already exists
stf_1   | 14:30:25 stf.1         | INF/db:setup 99 [*] Table "logs" already exists
stf_1   | 14:30:26 stf.1         | INF/db:setup 99 [*] Index "devices"."owner" already exists
stf_1   | 14:30:26 stf.1         | INF/db:setup 99 [*] Waiting for index "devices"."owner"
stf_1   | 14:30:26 stf.1         | INF/db:setup 99 [*] Index "devices"."present" already exists
stf_1   | 14:30:26 stf.1         | INF/db:setup 99 [*] Index "devices"."providerChannel" already exists
stf_1   | 14:30:26 stf.1         | INF/db:setup 99 [*] Index "devices"."owner" is ready
stf_1   | 14:30:26 stf.1         | INF/db:setup 99 [*] Waiting for index "devices"."present"
stf_1   | 14:30:26 stf.1         | INF/db:setup 99 [*] Waiting for index "devices"."providerChannel"
stf_1   | 14:30:26 stf.1         | INF/db:setup 99 [*] Index "devices"."present" is ready
stf_1   | 14:30:26 stf.1         | INF/db:setup 99 [*] Index "devices"."providerChannel" is ready
stf_1   | 14:30:26 stf.1         | INF/db:setup 99 [*] Index "accessTokens"."email" already exists
stf_1   | 14:30:26 stf.1         | INF/db:setup 99 [*] Waiting for index "accessTokens"."email"
stf_1   | 14:30:27 stf.1         | INF/db:setup 99 [*] Index "vncauth"."response" already exists
stf_1   | 14:30:27 stf.1         | INF/db:setup 99 [*] Waiting for index "vncauth"."response"
stf_1   | 14:30:27 stf.1         | INF/db:setup 99 [*] Index "vncauth"."responsePerDevice" already exists
stf_1   | 14:30:27 stf.1         | INF/db:setup 99 [*] Index "accessTokens"."email" is ready
stf_1   | 14:30:27 stf.1         | INF/db:setup 99 [*] Index "vncauth"."response" is ready
stf_1   | 14:30:27 stf.1         | INF/db:setup 99 [*] Waiting for index "vncauth"."responsePerDevice"
stf_1   | 14:30:27 stf.1         | INF/db:setup 99 [*] Index "vncauth"."responsePerDevice" is ready
stf_1   | 14:30:28 stf.1         | INF/db:setup 99 [*] Index "users"."adbKeys" already exists
stf_1   | 14:30:28 stf.1         | INF/db:setup 99 [*] Waiting for index "users"."adbKeys"
stf_1   | 14:30:28 stf.1         | INF/db:setup 99 [*] Index "users"."adbKeys" is ready
stf_1   | 14:30:28 stf.1         | INF/util:procutil 17 [*] Forking "/app/lib/cli.js triproxy app001 --bind-pub tcp://127.0.0.1:7111 --bind-dealer tcp://127.0.0.1:7112 --bind-pull tcp://127.0.0.1:7113"
stf_1   | 14:30:28 stf.1         | INF/util:procutil 17 [*] Forking "/app/lib/cli.js triproxy dev001 --bind-pub tcp://127.0.0.1:7114 --bind-dealer tcp://127.0.0.1:7115 --bind-pull tcp://127.0.0.1:7116"
stf_1   | 14:30:28 stf.1         | INF/util:procutil 17 [*] Forking "/app/lib/cli.js processor proc001 --connect-app-dealer tcp://127.0.0.1:7112 --connect-dev-dealer tcp://127.0.0.1:7115"
stf_1   | 14:30:28 stf.1         | INF/util:procutil 17 [*] Forking "/app/lib/cli.js processor proc002 --connect-app-dealer tcp://127.0.0.1:7112 --connect-dev-dealer tcp://127.0.0.1:7115"
stf_1   | 14:30:28 stf.1         | INF/util:procutil 17 [*] Forking "/app/lib/cli.js reaper reaper001 --connect-push tcp://127.0.0.1:7116 --connect-sub tcp://127.0.0.1:7111"
stf_1   | 14:30:28 stf.1         | INF/util:procutil 17 [*] Forking "/app/lib/cli.js provider --name dfc7f26bd44e --min-port 7400 --max-port 7700 --connect-sub tcp://127.0.0.1:7114 --connect-push tcp://127.0.0.1:7116 --group-timeout 900 --public-ip 192.168.99.100 --storage-url http://localhost:7100/ --adb-host 127.0.0.1 --adb-port 5037 --vnc-initial-size 600x800"
stf_1   | 14:30:28 stf.1         | INF/util:procutil 17 [*] Forking "/app/lib/cli.js auth-mock --port 7120 --secret kute kittykat --app-url http://192.168.99.100:7100/"
stf_1   | 14:30:28 stf.1         | INF/util:procutil 17 [*] Forking "/app/lib/cli.js app --port 7105 --secret kute kittykat --auth-url http://192.168.99.100:7100/auth/mock/ --websocket-url http://192.168.99.100:7110/"
stf_1   | 14:30:28 stf.1         | INF/util:procutil 17 [*] Forking "/app/lib/cli.js websocket --port 7110 --secret kute kittykat --storage-url http://localhost:7100/ --connect-sub tcp://127.0.0.1:7111 --connect-push tcp://127.0.0.1:7113"
stf_1   | 14:30:28 stf.1         | INF/util:procutil 17 [*] Forking "/app/lib/cli.js storage-temp --port 7102"
stf_1   | 14:30:28 stf.1         | INF/util:procutil 17 [*] Forking "/app/lib/cli.js storage-plugin-image --port 7103 --storage-url http://localhost:7100/"
stf_1   | 14:30:28 stf.1         | INF/util:procutil 17 [*] Forking "/app/lib/cli.js storage-plugin-apk --port 7104 --storage-url http://localhost:7100/"
stf_1   | 14:30:28 stf.1         | INF/util:procutil 17 [*] Forking "/app/lib/cli.js poorxy --port 7100 --app-url http://localhost:7105/ --auth-url http://localhost:7120/ --websocket-url http://localhost:7110/ --storage-url http://localhost:7102/ --storage-plugin-image-url http://localhost:7103/ --storage-plugin-apk-url http://localhost:7104/"
stf_1   | 14:30:28 droydserver.1 |  * Running on http://0.0.0.0:5000/ (Press CTRL+C to quit)
stf_1   | 14:30:30 stf.1         | INF/triproxy 118 [dev001] PUB socket bound on tcp://127.0.0.1:7114
stf_1   | 14:30:31 stf.1         | INF/triproxy 118 [dev001] DEALER socket bound on tcp://127.0.0.1:7115
stf_1   | 14:30:31 stf.1         | INF/triproxy 117 [app001] PUB socket bound on tcp://127.0.0.1:7111
stf_1   | 14:30:31 stf.1         | INF/triproxy 118 [dev001] PULL socket bound on tcp://127.0.0.1:7116
stf_1   | 14:30:31 stf.1         | INF/triproxy 117 [app001] DEALER socket bound on tcp://127.0.0.1:7112
stf_1   | 14:30:31 stf.1         | INF/triproxy 117 [app001] PULL socket bound on tcp://127.0.0.1:7113
stf_1   | 14:30:32 stf.1         | INF/poorxy 177 [*] Listening on port 7100
stf_1   | 14:30:32 stf.1         | INF/db 128 [proc002] Connecting to 127.0.0.1:28015
stf_1   | 14:30:32 stf.1         | INF/reaper 133 [reaper001] Subscribing to permanent channel "*ALL"
stf_1   | 14:30:32 stf.1         | INF/db 119 [proc001] Connecting to 127.0.0.1:28015
stf_1   | 14:30:32 stf.1         | INF/processor 128 [proc002] App dealer connected to "tcp://127.0.0.1:7112"
stf_1   | 14:30:32 stf.1         | INF/reaper 133 [reaper001] Reaping devices with no heartbeat
stf_1   | 14:30:32 stf.1         | INF/db 133 [reaper001] Connecting to 127.0.0.1:28015
stf_1   | 14:30:32 stf.1         | INF/reaper 133 [reaper001] Receiving input from "tcp://127.0.0.1:7111"
stf_1   | 14:30:32 stf.1         | INF/processor 119 [proc001] App dealer connected to "tcp://127.0.0.1:7112"
stf_1   | 14:30:32 stf.1         | INF/processor 128 [proc002] Device dealer connected to "tcp://127.0.0.1:7115"
stf_1   | 14:30:32 stf.1         | INF/reaper 133 [reaper001] Sending output to "tcp://127.0.0.1:7116"
stf_1   | 14:30:32 stf.1         | INF/processor 119 [proc001] Device dealer connected to "tcp://127.0.0.1:7115"
stf_1   | 14:30:33 stf.1         | INF/auth-mock 143 [*] Listening on port 7120
stf_1   | 14:30:33 stf.1         | INF/storage:plugins:image 167 [*] Listening on port 7103
stf_1   | 14:30:33 stf.1         | INF/storage:plugins:apk 172 [*] Listening on port 7104
stf_1   | 14:30:33 stf.1         | INF/provider 138 [*] Subscribing to permanent channel "KVmJkar4TL+REnhhraP4HA=="
stf_1   | 14:30:33 stf.1         | INF/provider 138 [*] Sending output to "tcp://127.0.0.1:7116"
stf_1   | 14:30:33 stf.1         | INF/provider 138 [*] Receiving input from "tcp://127.0.0.1:7114"
stf_1   | 14:30:33 stf.1         | INF/storage:temp 158 [*] Listening on port 7102
stf_1   | 14:30:33 stf.1         | INF/provider 138 [*] Tracking devices
stf_1   | 14:30:33 stf.1         | INF/provider 138 [*] Found device "0915f9ece8942b04" (device)
stf_1   | 14:30:34 stf.1         | INF/provider 138 [*] Found device "0915f9e0b3900c05" (device)
stf_1   | 14:30:34 stf.1         | INF/provider 138 [*] Registered device "0915f9ece8942b04"
stf_1   | 14:30:34 stf.1         | INF/reaper 133 [reaper001] Device "0915f9ece8942b04" is present
stf_1   | 14:30:34 stf.1         | INF/provider 138 [*] Registered device "0915f9e0b3900c05"
stf_1   | 14:30:34 stf.1         | INF/reaper 133 [reaper001] Device "0915f9e0b3900c05" is present
stf_1   | 14:30:34 stf.1         | INF/app 152 [*] Using pre-built resources
stf_1   | 14:30:34 stf.1         | INF/app 152 [*] Listening on port 7105
stf_1   | 14:30:34 stf.1         | INF/db 152 [*] Connecting to 127.0.0.1:28015
stf_1   | 14:30:35 stf.1         | INF/websocket 153 [*] Subscribing to permanent channel "*ALL"
stf_1   | 14:30:35 stf.1         | INF/websocket 153 [*] Listening on port 7110
stf_1   | 14:30:35 stf.1         | INF/db 153 [*] Connecting to 127.0.0.1:28015
stf_1   | 14:30:35 stf.1         | INF/websocket 153 [*] Sending output to "tcp://127.0.0.1:7113"
stf_1   | 14:30:35 stf.1         | INF/websocket 153 [*] Receiving input from "tcp://127.0.0.1:7111"
stf_1   | 14:30:35 stf.1         | INF/device:support:push 199 [0915f9e0b3900c05] Sending output to "tcp://127.0.0.1:7116"
stf_1   | 14:30:35 stf.1         | INF/device 199 [0915f9e0b3900c05] Preparing device
stf_1   | 14:30:35 stf.1         | INF/device:support:push 194 [0915f9ece8942b04] Sending output to "tcp://127.0.0.1:7116"
stf_1   | 14:30:35 stf.1         | INF/device 194 [0915f9ece8942b04] Preparing device
stf_1   | 14:30:36 stf.1         | INF/device:support:sub 199 [0915f9e0b3900c05] Receiving input from "tcp://127.0.0.1:7114"
stf_1   | 14:30:36 stf.1         | INF/device:support:sub 199 [0915f9e0b3900c05] Subscribing to permanent channel "*ALL"
stf_1   | 14:30:37 stf.1         | INF/device:support:sub 194 [0915f9ece8942b04] Receiving input from "tcp://127.0.0.1:7114"
stf_1   | 14:30:37 stf.1         | INF/device:support:sub 194 [0915f9ece8942b04] Subscribing to permanent channel "*ALL"
stf_1   | 14:30:37 stf.1         | INF/device:support:properties 194 [0915f9ece8942b04] Loading properties
stf_1   | 14:30:37 stf.1         | INF/device:support:properties 199 [0915f9e0b3900c05] Loading properties
stf_1   | 14:30:37 stf.1         | INF/device:support:abi 194 [0915f9ece8942b04] Supports ABIs arm64-v8a, armeabi-v7a, armeabi
stf_1   | 14:30:37 stf.1         | INF/device:support:abi 199 [0915f9e0b3900c05] Supports ABIs arm64-v8a, armeabi-v7a, armeabi
stf_1   | 14:30:38 stf.1         | INF/device:resources:service 194 [0915f9ece8942b04] Checking whether we need to install STFService
stf_1   | 14:30:38 stf.1         | INF/device:resources:service 199 [0915f9e0b3900c05] Checking whether we need to install STFService
stf_1   | 14:30:38 stf.1         | INF/device:resources:service 194 [0915f9ece8942b04] Running version check
stf_1   | 14:30:39 stf.1         | INF/device:resources:service 199 [0915f9e0b3900c05] Running version check
stf_1   | 14:30:39 stf.1         | INF/device:resources:service 194 [0915f9ece8942b04] STFService up to date
stf_1   | 14:30:39 stf.1         | INF/device:plugins:service 194 [0915f9ece8942b04] Launching agent
stf_1   | 14:30:40 stf.1         | INF/device:resources:service 199 [0915f9e0b3900c05] STFService up to date
stf_1   | 14:30:40 stf.1         | INF/device:plugins:service 199 [0915f9e0b3900c05] Launching agent
stf_1   | 14:30:40 stf.1         | INF/device:plugins:service 194 [0915f9ece8942b04] Agent says: "Listening on port 1090"
stf_1   | 14:30:40 stf.1         | INF/device:plugins:service 194 [0915f9ece8942b04] Launching service
stf_1   | 14:30:40 stf.1         | INF/device:plugins:service 194 [0915f9ece8942b04] Agent says: "InputClient started"
stf_1   | 14:30:40 stf.1         | INF/device:plugins:service 199 [0915f9e0b3900c05] Agent says: "Listening on port 1090"
stf_1   | 14:30:40 stf.1         | INF/device:plugins:service 199 [0915f9e0b3900c05] Launching service
stf_1   | 14:30:40 stf.1         | INF/device:plugins:service 199 [0915f9e0b3900c05] Agent says: "InputClient started"
stf_1   | 14:30:41 stf.1         | INF/device:plugins:display 194 [0915f9ece8942b04] Reading display info
stf_1   | 14:30:41 stf.1         | INF/device:plugins:phone 194 [0915f9ece8942b04] Fetching phone info
stf_1   | 14:30:41 stf.1         | INF/device:plugins:identity 194 [0915f9ece8942b04] Solving identity
stf_1   | 14:30:41 stf.1         | INF/device:plugins:solo 194 [0915f9ece8942b04] Subscribing to permanent channel "4G+m9QsQmxqZPk5Y18e3VaSr6M8="
stf_1   | 14:30:41 stf.1         | INF/device:plugins:screen:stream 194 [0915f9ece8942b04] Starting WebSocket server on port 7400
stf_1   | 14:30:41 stf.1         | WRN/device:plugins:data 194 [0915f9ece8942b04] Unable to find device data { serial: '0915f9ece8942b04',
stf_1   | 14:30:41 stf.1         |   platform: 'Android',
stf_1   | 14:30:41 stf.1         |   manufacturer: 'SAMSUNG',
stf_1   | 14:30:41 stf.1         |   operator: 'Orange F',
stf_1   | 14:30:41 stf.1         |   model: 'SM-G920F',
stf_1   | 14:30:41 stf.1         |   version: '5.1.1',
stf_1   | 14:30:41 stf.1         |   abi: 'arm64-v8a',
stf_1   | 14:30:41 stf.1         |   sdk: '22',
stf_1   | 14:30:41 stf.1         |   product: 'zerofltexx',
stf_1   | 14:30:41 stf.1         |   display:
stf_1   | 14:30:41 stf.1         |    { id: 0,
stf_1   | 14:30:41 stf.1         |      width: 1440,
stf_1   | 14:30:41 stf.1         |      height: 2560,
stf_1   | 14:30:41 stf.1         |      xdpi: 580.5709838867188,
stf_1   | 14:30:41 stf.1         |      ydpi: 580.5709838867188,
stf_1   | 14:30:41 stf.1         |      fps: 59,
stf_1   | 14:30:41 stf.1         |      density: 4,
stf_1   | 14:30:41 stf.1         |      rotation: 0,
stf_1   | 14:30:41 stf.1         |      secure: true,
stf_1   | 14:30:41 stf.1         |      size: 5.059173885071115,
stf_1   | 14:30:41 stf.1         |      url: 'ws://192.168.99.100:7400' },
stf_1   | 14:30:41 stf.1         |   phone:
stf_1   | 14:30:41 stf.1         |    { imei: '355922070558636',
stf_1   | 14:30:41 stf.1         |      iccid: '89330115462696899830',
stf_1   | 14:30:41 stf.1         |      network: 'LTE' } }
stf_1   | 14:30:41 stf.1         | INF/device:plugins:touch 194 [0915f9ece8942b04] Touch origin is top left
stf_1   | 14:30:41 stf.1         | INF/device:plugins:touch 194 [0915f9ece8942b04] Requesting touch consumer to start
stf_1   | 14:30:41 stf.1         | INF/device:plugins:touch 194 [0915f9ece8942b04] Launching screen service
stf_1   | 14:30:41 stf.1         | INF/device:plugins:touch 194 [0915f9ece8942b04] Connecting to minitouch service
stf_1   | 14:30:41 stf.1         | INF/device:plugins:display 199 [0915f9e0b3900c05] Reading display info
stf_1   | 14:30:41 stf.1         | INF/device:plugins:phone 199 [0915f9e0b3900c05] Fetching phone info
stf_1   | 14:30:41 stf.1         | INF/device:plugins:identity 199 [0915f9e0b3900c05] Solving identity
stf_1   | 14:30:41 stf.1         | INF/device:plugins:solo 199 [0915f9e0b3900c05] Subscribing to permanent channel "Co57ILbsMHbN6UIs2U1iNeXj/co="
stf_1   | 14:30:41 stf.1         | INF/device:plugins:screen:stream 199 [0915f9e0b3900c05] Starting WebSocket server on port 7404
stf_1   | 14:30:41 stf.1         | WRN/device:plugins:data 199 [0915f9e0b3900c05] Unable to find device data { serial: '0915f9e0b3900c05',
stf_1   | 14:30:41 stf.1         |   platform: 'Android',
stf_1   | 14:30:41 stf.1         |   manufacturer: 'SAMSUNG',
stf_1   | 14:30:41 stf.1         |   operator: 'Orange F',
stf_1   | 14:30:41 stf.1         |   model: 'SM-G920F',
stf_1   | 14:30:41 stf.1         |   version: '5.1.1',
stf_1   | 14:30:41 stf.1         |   abi: 'arm64-v8a',
stf_1   | 14:30:41 stf.1         |   sdk: '22',
stf_1   | 14:30:41 stf.1         |   product: 'zerofltexx',
stf_1   | 14:30:41 stf.1         |   display:
stf_1   | 14:30:41 stf.1         |    { id: 0,
stf_1   | 14:30:41 stf.1         |      width: 1440,
stf_1   | 14:30:41 stf.1         |      height: 2560,
stf_1   | 14:30:41 stf.1         |      xdpi: 580.5709838867188,
stf_1   | 14:30:41 stf.1         |      ydpi: 580.5709838867188,
stf_1   | 14:30:41 stf.1         |      fps: 59,
stf_1   | 14:30:41 stf.1         |      density: 4,
stf_1   | 14:30:41 stf.1         |      rotation: 0,
stf_1   | 14:30:41 stf.1         |      secure: true,
stf_1   | 14:30:41 stf.1         |      size: 5.059173885071115,
stf_1   | 14:30:41 stf.1         |      url: 'ws://192.168.99.100:7404' },
stf_1   | 14:30:41 stf.1         |   phone:
stf_1   | 14:30:41 stf.1         |    { imei: '355922070635566',
stf_1   | 14:30:41 stf.1         |      iccid: '89330115462696899750',
stf_1   | 14:30:41 stf.1         |      network: 'LTE' } }
stf_1   | 14:30:42 stf.1         | INF/device:plugins:touch 199 [0915f9e0b3900c05] Touch origin is top left
stf_1   | 14:30:42 stf.1         | INF/device:plugins:touch 199 [0915f9e0b3900c05] Requesting touch consumer to start
stf_1   | 14:30:42 stf.1         | INF/device:plugins:touch 199 [0915f9e0b3900c05] Launching screen service
stf_1   | 14:30:42 stf.1         | INF/device:plugins:touch 199 [0915f9e0b3900c05] Connecting to minitouch service
stf_1   | 14:30:42 stf.1         | INF/device:plugins:touch 194 [0915f9ece8942b04] minitouch says: "Type B touch device sec_touchscreen (4095x4095 with 10 contacts) detected on /dev/input/event1 (score 1100)"
stf_1   | 14:30:43 stf.1         | INF/device:plugins:touch 194 [0915f9ece8942b04] minitouch says: "Connection established"
stf_1   | 14:30:43 stf.1         | INF/device:plugins:touch 194 [0915f9ece8942b04] Reading minitouch banner
stf_1   | 14:30:43 stf.1         | INF/device:plugins:vnc 194 [0915f9ece8942b04] Starting VNC server on port 7402
stf_1   | 14:30:43 stf.1         | INF/device:plugins:browser 194 [0915f9ece8942b04] Loading browser list
stf_1   | 14:30:43 stf.1         | INF/device:plugins:browser 194 [0915f9ece8942b04] Updating browser list
stf_1   | 14:30:43 stf.1         | INF/device:plugins:mute 194 [0915f9ece8942b04] Will not mute master volume during use
stf_1   | 14:30:43 stf.1         | INF/device:plugins:touch 199 [0915f9e0b3900c05] minitouch says: "Type B touch device sec_touchscreen (4095x4095 with 10 contacts) detected on /dev/input/event1 (score 1100)"
stf_1   | 14:30:43 stf.1         | INF/device:plugins:forward 194 [0915f9ece8942b04] Launching reverse port forwarding service
stf_1   | 14:30:43 stf.1         | INF/device:plugins:forward 194 [0915f9ece8942b04] Connecting to reverse port forwarding service
stf_1   | 14:30:43 stf.1         | INF/device:plugins:touch 199 [0915f9e0b3900c05] Reading minitouch banner
stf_1   | 14:30:43 stf.1         | INF/device:plugins:touch 199 [0915f9e0b3900c05] minitouch says: "Connection established"
stf_1   | 14:30:43 stf.1         | INF/device:plugins:vnc 199 [0915f9e0b3900c05] Starting VNC server on port 7406
stf_1   | 14:30:43 stf.1         | INF/device:plugins:browser 199 [0915f9e0b3900c05] Loading browser list
stf_1   | 14:30:43 stf.1         | INF/device:plugins:browser 199 [0915f9e0b3900c05] Updating browser list
stf_1   | 14:30:43 stf.1         | INF/device:plugins:mute 199 [0915f9e0b3900c05] Will not mute master volume during use
stf_1   | 14:30:43 stf.1         | INF/device:plugins:connect 194 [0915f9ece8942b04] Listening on port 7401
stf_1   | 14:30:43 stf.1         | INF/device 194 [0915f9ece8942b04] Fully operational
stf_1   | 14:30:43 stf.1         | INF/device:plugins:forward 199 [0915f9e0b3900c05] Launching reverse port forwarding service
nginx_1 | 192.168.99.1 - - [09/Feb/2016:14:31:31 +0000] "GET / HTTP/1.1" 200 639 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2) AppleWebKit/601.3.9 (KHTML, like Gecko) Version/9.0.2 Safari/601.3.9"
nginx_1 | 192.168.99.1 - - [09/Feb/2016:14:31:32 +0000] "GET /app/api/v1/state.js HTTP/1.1" 200 313 "http://192.168.99.100/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2) AppleWebKit/601.3.9 (KHTML, like Gecko) Version/9.0.2 Safari/601.3.9"
nginx_1 | 192.168.99.1 - - [09/Feb/2016:14:31:32 +0000] "GET /static/app/build/entry/app.entry.js HTTP/1.1" 200 1002 "http://192.168.99.100/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2) AppleWebKit/601.3.9 (KHTML, like Gecko) Version/9.0.2 Safari/601.3.9"
nginx_1 | 192.168.99.1 - - [09/Feb/2016:14:31:32 +0000] "GET /static/app/build/entry/commons.entry.js HTTP/1.1" 200 1100 "http://192.168.99.100/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2) AppleWebKit/601.3.9 (KHTML, like Gecko) Version/9.0.2 Safari/601.3.9"
nginx_1 | 192.168.99.1 - - [09/Feb/2016:14:31:32 +0000] "GET /static/app/build/1.831f59254ef14dc05b01.chunk.js HTTP/1.1" 200 1064310 "http://192.168.99.100/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2) AppleWebKit/601.3.9 (KHTML, like Gecko) Version/9.0.2 Safari/601.3.9"
nginx_1 | 192.168.99.1 - - [09/Feb/2016:14:31:32 +0000] "GET /app/api/v1/devices/0915f9ece8942b04 HTTP/1.1" 200 814 "http://192.168.99.100/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2) AppleWebKit/601.3.9 (KHTML, like Gecko) Version/9.0.2 Safari/601.3.9"
nginx_1 | 192.168.99.1 - - [09/Feb/2016:14:31:32 +0000] "GET /static/app/build/e831b7164c8a65b849691bff62cdb160.png HTTP/1.1" 200 5851 "http://192.168.99.100/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2) AppleWebKit/601.3.9 (KHTML, like Gecko) Version/9.0.2 Safari/601.3.9"
nginx_1 | 192.168.99.1 - - [09/Feb/2016:14:31:32 +0000] "GET /app/api/v1/group HTTP/1.1" 200 29 "http://192.168.99.100/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2) AppleWebKit/601.3.9 (KHTML, like Gecko) Version/9.0.2 Safari/601.3.9"
nginx_1 | 192.168.99.1 - - [09/Feb/2016:14:31:32 +0000] "GET /static/app/devices/icon/x24/E30HT.jpg HTTP/1.1" 200 413 "http://192.168.99.100/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2) AppleWebKit/601.3.9 (KHTML, like Gecko) Version/9.0.2 Safari/601.3.9"
nginx_1 | 192.168.99.1 - - [09/Feb/2016:14:31:33 +0000] "GET /static/app/build/fda02a702c4a73c27958341c42582645.png HTTP/1.1" 200 6166 "http://192.168.99.100/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2) AppleWebKit/601.3.9 (KHTML, like Gecko) Version/9.0.2 Safari/601.3.9"
nginx_1 | 192.168.99.1 - - [09/Feb/2016:14:31:33 +0000] "GET /static/app/build/96978e6fcc6395ca44894139e0baa0b2.woff HTTP/1.1" 200 80444 "http://192.168.99.100/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2) AppleWebKit/601.3.9 (KHTML, like Gecko) Version/9.0.2 Safari/601.3.9"
nginx_1 | 192.168.99.1 - - [09/Feb/2016:14:31:33 +0000] "GET /static/app/build/443a27166608ea2aef94f5cf05ff19ec.woff HTTP/1.1" 200 74736 "http://192.168.99.100/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2) AppleWebKit/601.3.9 (KHTML, like Gecko) Version/9.0.2 Safari/601.3.9"
nginx_1 | 192.168.99.1 - - [09/Feb/2016:14:31:33 +0000] "GET /static/app/build/a8a00e89adc0ba57870098be433da27a.woff HTTP/1.1" 200 80972 "http://192.168.99.100/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2) AppleWebKit/601.3.9 (KHTML, like Gecko) Version/9.0.2 Safari/601.3.9"
nginx_1 | 192.168.99.1 - - [09/Feb/2016:14:31:33 +0000] "GET /static/app/build/a35720c2fed2c7f043bc7e4ffb45e073.woff HTTP/1.1" 200 83588 "http://192.168.99.100/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2) AppleWebKit/601.3.9 (KHTML, like Gecko) Version/9.0.2 Safari/601.3.9"
nginx_1 | 192.168.99.1 - - [09/Feb/2016:14:31:33 +0000] "GET /static/app/build/34f4fb7db2bd6acd7b011434f72adb5c.woff HTTP/1.1" 200 77484 "http://192.168.99.100/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2) AppleWebKit/601.3.9 (KHTML, like Gecko) Version/9.0.2 Safari/601.3.9"
nginx_1 | 192.168.99.1 - - [09/Feb/2016:14:31:33 +0000] "GET /favicon.ico HTTP/1.1" 200 1995 "http://192.168.99.100/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2) AppleWebKit/601.3.9 (KHTML, like Gecko) Version/9.0.2 Safari/601.3.9"
