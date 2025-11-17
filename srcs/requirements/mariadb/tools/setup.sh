#!/bin/bash

set -e

MARIADB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
MARIADB_PASSWORD=$(cat /run/secrets/db_password)

if [ ! -d "/var/lib/mysql/${MARIADB_DATABASE}" ]; then
	echo "Initializing MariaDB..."

	if [ -z "$(ls -A /var/lib/mysql)" ]; then
		mariadb-install-db --user=mysql --datadir=/var/lib/mysql
	fi
	# temporary mariadbd in background for restricted authority
	mariadbd-safe --user=mysql --skip-networking &

	TIMEOUT=30
	COUNTER=0
	echo "Waiting tmp MariaDB to start..."
	until mariadb-admin ping --silent; do 
		COUNTER=$((COUNTER+1))
		if [ $COUNTER -gt $TIMEOUT ]; then
			echo "Error: MariaDB failed to start within $((TIMEOUT*2)) seconds"
			exit 1
		fi
		sleep 2
	done
	echo "tmp MariaDB is ready!"

	mariadb -u root <<-EOSQL
	ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';
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

echo "Starting Mariadb..."

exec "$@"
