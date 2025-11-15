#!/bin/bash

set -e

MARIADB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
MARIADB_DATABASE=$(cat /run/secrets/db_name)
MARIADB_USER=$(cat /run/secrets/db_user)
MARIADB_PASSWORD=$(cat /run/secrets/db_password)

if [ ! -d "/var/lib/mysql/${MARIADB_DATABASE}" ]; then
	echo "Initializing MariaDB..."

	if [ -z "$(ls -A /var/lib/mysql)" ]; then
		mariadb-install-db --user=mysql --datadir=/var/lib/mysql
	fi
	# temporary mariadbd in background for restricted authority
	mariadbd-safe --user=mysql --skip-networking &

	until mariadb-admin ping --silent; do 
		sleep 2
	done

	mariadb -u root <<-EOSQL
	ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';
	DELETE FROM mysql.user WHERE User='';
	DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
	FLUSH PRIVILEGES;

	CREATE DATABASE IF NOT EXISTS ${MARIADB_DATABASE};
	CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';
	GRANT ALL PRIVILEGES ON ${MARIADB_DATABASE}.* TO '${MARIADB_USER}'@'%';
	FLUSH PRIVILEGES;
	EOSQL

	mariadb-admin -u root -p"${MARIADB_ROOT_PASSWORD}" shutdown
	echo "MariaDB initialization complete"
fi

exec "$@"
