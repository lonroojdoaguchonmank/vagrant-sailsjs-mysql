#! /usr/bin/env bash

# mysqld_safe --datadir=$MSDATA &
mysqld_safe &

echo "Executing Mysql DBMS configuration changes."
sleep 10

read -r -d '' ROOT_CONFIG << EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${root_pass}';
FLUSH PRIVILEGES;
EOF

mysql \
		--verbose \
		--skip-password \
		--user=root \
		--execute "${ROOT_CONFIG}"

read -r -d '' USER_CONFIG << EOF
CREATE USER '${user}'@'%' IDENTIFIED BY '${pass}';
GRANT ALL PRIVILEGES ON *.* TO '${user}'@'%';
FLUSH PRIVILEGES;
EOF

mysql \
		--verbose \
		--user=root \
		--password=${root_pass} \
		--execute "${USER_CONFIG}"

echo "Executing Mysql DBMS configuration changes complete."

mysqladmin \
		--verbose \
		--user=root \
		--password=${root_pass} \
		shutdown
