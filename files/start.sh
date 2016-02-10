
#export NGINX_HOST=$1

envsubst < /data/templates/Procfile > /data/Procfile

#honcho start



