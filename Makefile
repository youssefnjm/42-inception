MARIADB=mariadb
NGINX=nginx
WORDPRESS=wordpress
NETWORK=inception-network

all: network wordpress nginx mariadb 

network:
	@echo "\e[1;33m---->  Create network \e[0m"
	docker network create $(NETWORK) 2>/dev/null || true

# images:
# 	docker build -t img-$(MARIADB) srcs/requirements/mariadb/ 2>/dev/null || true
# 	docker build -t img-$(NGINX) srcs/requirements/nginx/ 2>/dev/null || true
# 	docker build -t img-$(WORDPRESS) srcs/requirements/wordpress/ 2>/dev/null || true

mariadb: network
	@echo  "\e[1;33m---->  building mariadb... \e[0m"
	docker build -t img-$(MARIADB) srcs/requirements/mariadb/
	@echo  "\e[1;33m---->  running mariadb... \e[0m"
	docker run -d -p 3306:3306 --network $(NETWORK) --name $(MARIADB) img-$(MARIADB)
#	docker run -d -p 3306:3306 --name $(MARIADB) img-$(MARIADB)

nginx: network
	@echo  "\e[1;33m---->  building nginx... \e[0m"
	docker build -t img-$(NGINX) srcs/requirements/nginx/
	@echo  "\e[1;33m---->  running nginx... \e[0m"
	docker run -d -p 443:443 --network $(NETWORK) --name $(NGINX) img-$(NGINX)
#	docker run -d -p 443:443 --name $(NGINX) img-$(NGINX)

wordpress: network
	@echo  "\e[1;33m---->  building wordpress... \e[0m"
	docker build -t img-$(WORDPRESS) srcs/requirements/wordpress/
	@echo  "\e[1;33m---->  running wordpress... \e[0m"
	docker run -d -p 9000:9000 --network $(NETWORK) --name $(WORDPRESS) img-$(WORDPRESS)
#	docker run -d -p 9000:9000 --name $(WORDPRESS) img-$(WORDPRESS)

stop: 
	@echo  "\e[1;33m---->  stop runing containers... \e[0m"
	docker stop $(MARIADB) $(NGINX) $(WORDPRESS) 2>/dev/null || true

clean: stop
	@echo  "\e[1;33m---->  clear all images and containers... \e[0m"
	docker rm -f $(MARIADB) $(NGINX) $(WORDPRESS) 2>/dev/null || true
	docker rmi -f img-$(MARIADB) img-$(NGINX) img-$(WORDPRESS) 2>/dev/null || true
	docker network rm -f $(NETWORK) 2>/dev/null || true

re: stop clean all