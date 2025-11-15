FROM alpine:3.21

RUN apk update && apk add --no-cache \
	mariadb \
	mariadb-client \
	bash

COPY conf/my.cnf /etc/my.cnf

COPY tools/setup.sh /usr/local/bin/setup.sh

RUN chmod +x /usr/local/bin/setup.sh

VOLUME /var/lib/mysql

EXPOSE 3306

ENTRYPOINT ["setup.sh"]

# parameter for ENTRYPOINT
CMD ["mariadbd-safe"]
