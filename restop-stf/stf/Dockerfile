FROM openstf/stf

USER root


#
# install dependencies  (envsubst)
#
RUN sudo apt-get update && sudo apt-get install -y gettext


#
#  install android tools
#
RUN sudo apt-get update && sudo apt-get install -y android-tools-adb android-tools-fastboot

# Set up insecure default key
RUN mkdir -m 0750 /.android
ADD files/certs/insecure_shared_adbkey /.android/adbkey
ADD files/certs/insecure_shared_adbkey.pub /.android/adbkey.pub



#
#   install rethinkdb  ( ref: https://www.rethinkdb.com/docs/install/ubuntu/)
#

RUN . /etc/lsb-release && \
    echo "deb http://download.rethinkdb.com/apt $DISTRIB_CODENAME main" | sudo tee /etc/apt/sources.list.d/rethinkdb.list &&\
    wget -qO- https://download.rethinkdb.com/apt/pubkey.gpg | sudo apt-key add - && \
    sudo apt-get update && sudo apt-get install -y rethinkdb

#   process cluster webui
EXPOSE 28015 29015 8080



#
# install redis
#
RUN sudo apt-get install -y redis-server


#
#  install restop dependencies
#
RUN sudo apt-get install -y python-pip && \
   pip install flask && \
   pip install redis && \
   pip install jsonschema && \
   pip install honcho && \
   pip install click && \
   pip install uiautomator

#
# install restop
#
RUN mkdir /usr/local/lib/phonehub  && \ 
    git clone https://cocoon_bitbucket@bitbucket.org/cocoon_bitbucket/restop.git /usr/local/lib/phonehub/

RUN cd /usr/local/lib/phonehub && \
	sudo chmod +x devices/pjsip_device/server/bin/pjterm-linux-x86_64 && \
	sudo ln -s /usr/local/lib/phonehub/devices/pjsip_device/server/bin/pjterm-linux-x86_64 /usr/local/bin/pjterm-linux-x86_64 && \
	sudo mkdir /usr/share/sounds/  && \
	sudo chmod +w /usr/share/sounds/ && \
	sudo ln -s /usr/local/lib/phonehub//devices/pjsip_device/server/media/  /usr/share/sounds/syprunner 

# adapt adb
RUN ln -s  /usr/bin/adb /usr/local/bin/adb


#
# install droydrunner
#
#RUN git clone https://cocoon_bitbucket@bitbucket.org/cocoon_bitbucket/droyd.git /tmp/
#RUN cd /tmp && \
#    pip install -r requirements_server.txt && \
#    python setup.py install && \
#    cp droydserver/droydserve.py /usr/local/bin/droydserve && \
#    chmod +x /usr/local/bin/droydserve 
# add demo
#ADD droydserver/demo /tests/demo
#EXPOSE 5000
#WORKDIR /tests





#USER stf
VOLUME ["/data"]
WORKDIR /data
#CMD ["rethinkdb", "--bind", "all"]


COPY files/ /data


# install restop client dependencies
RUN  pip install requests && \
     pip install robotframework 



CMD ["honcho", "start"]


