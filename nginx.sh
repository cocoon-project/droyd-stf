
docker run --name docker-nginx -p 80:80 -v ~/Documents/projects/droyd-stf/site/html:/usr/share/nginx/html -v ~/Documents/projects/droyd-stf/site/nginx/nginx.conf:/etc/nginx/conf.d/default.conf -d nginx
