FROM debian:jessie
MAINTAINER Matthew O'N.S Jordan <matthewjordannm@gmail.com>

# System varibles
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL en_US.UTF-8
ENV LANG $LC_ALL
ENV LANGUAGE $LC_ALL
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Mysql variables
ENV MYSQL_MAJOR 5.7
ENV MYSQL_VERSION 5.7.6-m16
ENV MSDATA /var/lib/mysql
ENV MYSQL_HOME /etc/mysql
ENV DBMS_USER mysql

RUN rm -rf /var/lib/apt/* \
		&& apt-get clean \
		&& apt-get update

RUN echo "deb http://ftp.us.debian.org/debian/ jessie main contrib non-free" \
		> /etc/apt/sources.list
RUN apt-get update

#Install and setup locales
RUN apt-get install -y \
		locales \
		&& apt-get clean
RUN sed -i "s/# $LANG/$LANG/gI" /etc/locale.gen && \
		locale-gen

# Install additional utilities
RUN apt-get install -y \
		curl \
		gawk \
		sed \
		wget \
		&& apt-get clean

RUN echo \
		"deb http://repo.mysql.com/apt/debian/ wheezy mysql-${MYSQL_MAJOR}-dmr" > \
		/etc/apt/sources.list.d/mysql.list

ENV key A4A9406876FCBD3C456770C88C718D3B5072E1F5
RUN apt-key adv \
		--keyserver pool.sks-keyservers.net \
		--recv-keys $key \
		|| apt-key adv \
		--keyserver pgp.mit.edu \
		--recv-keys $key

RUN apt-get update

RUN adduser --disabled-password --gecos "" $DBMS_USER

RUN { \
		echo mysql-community-server mysql-community-server/data-dir select ''; \
		echo mysql-community-server mysql-community-server/root-pass password ''; \
		echo mysql-community-server mysql-community-server/re-root-pass password ''; \
		echo mysql-community-server mysql-community-server/remove-test-db select false; \
		} | debconf-set-selections

RUN apt-get install -y \
		mysql-server="${MYSQL_VERSION}"* \
		perl \
		&& apt-get clean \
		&& rm -rf /var/lib/mysql

RUN mkdir --parents $MSDATA

COPY mysql_bootstrap.sh /usr/local/bin/
RUN chown mysql /usr/local/bin/mysql_bootstrap.sh
RUN chmod ug+x /usr/local/bin/mysql_bootstrap.sh

COPY mysql_start.sh /usr/local/bin/
RUN chown mysql /usr/local/bin/mysql_start.sh
RUN chmod ug+x /usr/local/bin/mysql_start.sh

RUN chown --recursive $DBMS_USER:mysql $MYSQL_HOME $MSDATA /var/run/mysqld
RUN chmod --recursive ug+rw $MYSQL_HOME $MSDATA /var/run/mysqld

USER $DBMS_USER
RUN sed -i -r \
		-e 's/^log/#&/' $MYSQL_HOME/my.cnf
RUN sed -i -r \
		-e 's/^skip-networking/#&/' $MYSQL_HOME/my.cnf
RUN sed -i -r \
		-e 's/^(bind-address[[:space:]]+=)[[:space:]]+.+/\1 0.0.0.0/' $MYSQL_HOME/my.cnf
RUN sed -i -r \
		-e "s|^(basedir[[:space:]]+=)[[:space:]]+.+|\1 $MYSQL_HOME|" $MYSQL_HOME/my.cnf
RUN sed -i -r \
		-e "s|^(datadir[[:space:]]+=)[[:space:]]+.+|\1 $MSDATA|" $MYSQL_HOME/my.cnf

RUN mysqld --initialize-insecure --datadir=$MSDATA

# EXPOSE 3306
# VOLUME /var/lib/mysql
