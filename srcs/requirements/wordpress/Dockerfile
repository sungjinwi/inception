FROM debian:bookworm

RUN apt-get update && apt-get install -y \
	php-fpm \
	php-mysql \
	iproute2 \
	&& rm -rf /var/lib/apt/lists/*

ADD https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar /usr/local/bin/wp
RUN chmod +x /usr/local/bin/wp

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

RUN mkdir -p /var/www/html /run/php && \
	chown -R www-data:www-data /var/www/html

WORKDIR /var/www/html

VOLUME /var/www/html

EXPOSE 9000

ENTRYPOINT ["setup.sh"]

CMD ["php-fpm8.2", "-F"]
