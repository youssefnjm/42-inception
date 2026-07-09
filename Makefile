MARIADB=mariadb
NGINX=nginx
WORDPRESS=wordpress
NETWORK=inception-network

all: network wordpress nginx mariadb 

network:
	docker network create $(NETWORK) 2>/dev/null || true

# images:
# 	docker build -t img-$(MARIADB) srcs/requirements/mariadb/ 2>/dev/null || true
# 	docker build -t img-$(NGINX) srcs/requirements/nginx/ 2>/dev/null || true
# 	docker build -t img-$(WORDPRESS) srcs/requirements/wordpress/ 2>/dev/null || true

mariadb: network
	docker build -t img-$(MARIADB) srcs/requirements/mariadb/
	docker run -d -p 3306:3306 --network $(NETWORK) --name $(MARIADB) img-$(MARIADB)
#	docker run -d -p 3306:3306 --name $(MARIADB) img-$(MARIADB)

nginx: network
	docker build -t img-$(NGINX) srcs/requirements/nginx/
	docker run -d -p 443:443 --network $(NETWORK) --name $(NGINX) img-$(NGINX)
#	docker run -d -p 443:443 --name $(NGINX) img-$(NGINX)

wordpress: network
	docker build -t img-$(WORDPRESS) srcs/requirements/wordpress/
	docker run -d -p 9000:9000 --network $(NETWORK) --name $(WORDPRESS) img-$(WORDPRESS)
#	docker run -d -p 9000:9000 --name $(WORDPRESS) img-$(WORDPRESS)

stop: 
	docker stop $(MARIADB) $(NGINX) $(WORDPRESS) 2>/dev/null || true

clean: stop
	docker rm -f $(MARIADB) $(NGINX) $(WORDPRESS) 2>/dev/null || true
	docker rmi -f img-$(MARIADB) img-$(NGINX) img-$(WORDPRESS) 2>/dev/null || true
	docker network rm -f $(NETWORK) 2>/dev/null || true

re: stop clean all