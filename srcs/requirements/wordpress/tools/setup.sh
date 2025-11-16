#!/bin/bash

set -e

MARIADB_PASSWORD=$(cat /run/secrets/db_password)
WORDPRESS_ADMIN_USER=$(cat /run/secrets/wp_admin_user)
WORDPRESS_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WORDPRESS_ADMIN_EMAIL=$(cat /run/secrets/wp_admin_email)
WORDPRESS_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

# Check if WordPress is already installed
if [ ! -f /var/www/html/wp-config.php ]; then
	echo "Installing WordPress..."

	# Download WordPress
	wp core download --allow-root

	# Create wp-config.php
	wp config create \
		--dbname=${MARIADB_DATABASE} \
		--dbuser=${MARIADB_USER} \
		--dbpass=${MARIADB_PASSWORD} \
		--dbhost=${MARIADB_HOST}:3306 \
		--allow-root

	# Install WordPress
	wp core install \
		--url=https://${DOMAIN_NAME} \
		--title="${WORDPRESS_TITLE}" \
		--admin_user=${WORDPRESS_ADMIN_USER} \
		--admin_password=${WORDPRESS_ADMIN_PASSWORD} \
		--admin_email=${WORDPRESS_ADMIN_EMAIL} \
		--allow-root

	# Create additional user
	wp user create \
		${WORDPRESS_USER} \
		${WORDPRESS_USER_EMAIL} \
		--user_pass=${WORDPRESS_USER_PASSWORD} \
		--role=author \
		--allow-root

	echo "WordPress installation complete!"
else
	echo "WordPress is already installed."
fi

# Ensure proper permissions
chown -R www-data:www-data /var/www/html

# Execute CMD (php-fpm82 -F)
exec "$@"
