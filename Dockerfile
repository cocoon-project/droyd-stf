FROM openstf/stf


#
#   install rethinkdb
#

# Add the RethinkDB repository and public key
# "RethinkDB Packaging <packaging@rethinkdb.com>" http://download.rethinkdb.com/apt/pubkey.gpg
#RUN sudo apt-key adv --keyserver pgp.mit.edu --recv-keys 1614552E5765227AEC39EFCFA7E00EF33A8F2399
RUN sudo echo "deb http://download.rethinkdb.com/apt trusty main" > /etc/apt/sources.list.d/rethinkdb.list

ENV RETHINKDB_PACKAGE_VERSION 1.14.1-0ubuntu1~trusty

RUN sudo apt-get update \
	&& sudo apt-get install -y rethinkdb=$RETHINKDB_PACKAGE_VERSION \
	&& sudo rm -rf /var/lib/apt/lists/*

VOLUME ["/data"]

WORKDIR /data

CMD ["rethinkdb", "--bind", "all"]

#   process cluster webui
EXPOSE 28015 29015 8080



#
# install redis
#
RUN sudo add-apt-repository ppa:chris-lea/redis-server && sudo apt-get update  && sudo apt-get install redis-server


#
#  install honcho
#

RUN apt-get update && apt-get install -y python-pip && pip install honcho


RUN cat >Procfile <<EOM
rethinkdb: rethinkdb --bind all
redis: redis-server
stf: stf local
EOM