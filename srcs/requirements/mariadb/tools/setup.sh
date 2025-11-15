#!/bin/bash

set -e

# Check if database is not initialized (no wp database)
if [ ! -d "/var/lib/mysql/${MARIADB_DATABASE}" ]; then
	echo "Initializing MariaDB for the first time..."

	# If directory is empty, install db
	if [ -z "$(ls -A /var/lib/mysql 2>/dev/null)" ]; then
		mariadb-install-db --user=mysql --datadir=/var/lib/mysql
	fi

	# temporary mariadbd in backgroud for settings
	mariadbd-safe --user=mysql --skip-networking &

	# Wait for MariaDB to start
	until mariadb-admin ping --silent; do 
		sleep 2
	done

	# heredoc with ignore tab
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

	# terminate temporary mariadb
	mariadb-admin -u root -p"${MARIADB_ROOT_PASSWORD}" shutdown

	echo "MariaDB initialization complete"

fi

# execute argument (mariadbd-safe)
exec "$@"
