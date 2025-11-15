FROM debian:bullseye

RUN apt-get update && apt-get install -y \
	php-fpm \
	php-mysql \
	mariadb-client \
	wget \
	&& rm -rf /var/lib/apt/lists/*

# Increase PHP memory limit for WP-CLI
RUN sed -i 's/memory_limit = .*/memory_limit = 256M/' /etc/php/7.4/fpm/php.ini

# Download and install WP-CLI
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x wp-cli.phar && \
	mv wp-cli.phar /usr/local/bin/wp

# Copy PHP-FPM configuration
COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

# Copy setup script
COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

# Create WordPress directory
RUN mkdir -p /var/www/html /run/php && \
	chown -R www-data:www-data /var/www/html

WORKDIR /var/www/html

VOLUME /var/www/html

EXPOSE 9000

ENTRYPOINT ["setup.sh"]

CMD ["php-fpm7.4", "-F"]
