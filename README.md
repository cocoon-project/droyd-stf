droydrunner + openstf standalone



prerequisite
============

a linux with docker installed
an access to internet ( github , dockerhub )


install
=======


    git clone https://github.com/cocoon-project/droyd-stf.git

    cd droyd-stf/droyd-stf


edit the file docker-compose.yml

and set the value for stf:environment:-NGINX_HOST= ?


run
===

connect your android devices


    docker-compose up


when run for the first time, docker will load some images from dockerhub, be patient.

watch your devices to answer the authorization request for this machine




test
====

stf
---
in a browser open http://${NGINX_HOST}

* login: stf
* password: stf@openstf.io


check you can manage the devices with stf ui


droydrunner
-----------
in a browser open http://${NGINX_HOST}/sessions
you should get a simple text: list sessions


run your droydrunner tests













