#!/usr/bin/env bash

systemctl start docker.service

docker pull 'debian:jessie'
docker build --tag 'database/mysql' '/vagrant/mysql'

export DBMS_IP=163.108.53.10
sysctl -w net.ipv4.ip_forward=1
ip link add dbms_server type dummy
ip addr add $DBMS_IP/8 dev dbms_server

docker run \
			 --name 'mysql_data' \
			 --volume '/var/lib/mysql' \
			 --volume '/etc/mysql' \
			 'database/mysql' \
			 true

docker run \
			 --detach \
			 --name 'mysql_bootstrap' \
			 --volumes-from 'mysql_data' \
			 --env root_pass=password \
			 --env user=application \
			 --env pass=password \
			 'database/mysql' \
			 'mysql_bootstrap.sh'

docker wait 'mysql_bootstrap'

docker run \
			 --detach \
			 --name 'mysql_server' \
			 --volumes-from 'mysql_data' \
			 --publish $DBMS_IP:3306:3306 \
			 'database/mysql' \
			 'mysql_start.sh'
