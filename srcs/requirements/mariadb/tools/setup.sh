#!/bin/bash

set -e

if [ -z "$(ls -A /var/lib/mysql)" ]; then
	echo "Initializing MariaDB for the first time..."

	# create system table in volume
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql

	# temporary mysqld in backgroud for settings
	mariadbd-safe --user=mysql --nowatch &

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

	# terminate temporary mysql
	mariadb-admin -u root -p"${MARIADB_ROOT_PASSWORD}" shutdown

	echo "MariaDB initialization complete"

fi

# execute argument (mariadbd_safe)
exec "$@"


