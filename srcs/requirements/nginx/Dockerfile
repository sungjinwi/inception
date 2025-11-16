FROM debian:bookworm

RUN apt-get update && apt-get install -y \
	nginx \
	openssl

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/default.conf /etc/nginx/sites-available/default
COPY tools/setup.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 443

ENTRYPOINT [ "setup.sh" ]

CMD ["nginx", "-g", "daemon off;"]
