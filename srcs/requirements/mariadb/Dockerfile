FROM debian:bookworm

RUN apt-get update && apt-get install -y \
	mariadb-server \
	&& rm -rf /var/lib/apt/lists/*

COPY conf/my.cnf /etc/mysql/mariadb.conf.d/99-custom.cnf

COPY tools/setup.sh /usr/local/bin/setup.sh

RUN chmod +x /usr/local/bin/setup.sh

VOLUME /var/lib/mysql

EXPOSE 3306

ENTRYPOINT ["setup.sh"]

CMD ["mariadbd-safe", "--user=mysql"]
