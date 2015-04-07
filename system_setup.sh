#!/usr/bin/env bash

groupadd docker
usermod -a -G docker vagrant

rm -rf /var/lib/apt/lists/* \
		&& apt-get clean \
		&& apt-get update

apt-get install -y \
				apt-transport-https \
				lsb-release \
		&& apt-get clean

read -r -d '' APT_URLS << EOF
deb http://ftp.us.debian.org/debian/ jessie main contrib non-free
deb http://ftp.us.debian.org/debian/ sid main contrib non-free
EOF

read -r -d '' APT_PREFERENCES << EOF
Package: *
Pin: release n=jessie
Pin-Priority: 800

Package: *
Pin: release n=sid
Pin-Priority: 600
EOF

echo "$APT_URLS" > /etc/apt/sources.list
echo "$APT_PREFERENCES" > /etc/apt/preferences.d/main.pref

apt-get update

# Install virtualization related packages
apt-get install -y \
				bridge-utils \
				debootstrap \
				docker.io \
				libvirt-bin \
				lxc \
		&& apt-get clean

# Install development support packages
apt-get install -y \
				build-essential \
				curl \
				g++ \
				git \
				make \
				mysql-client \
				python \
				python-software-properties \
				vim \
		&& apt-get clean

systemctl enable docker.service

# Install NodeJS
curl -sL https://deb.nodesource.com/setup | bash -
apt-get update

apt-get install -y \
				nodejs \
		&& apt-get clean

# Test NodeJS isntallation
curl -sL https://deb.nodesource.com/test | bash -

# Install SailsJS and other packages
n=1;
readonly attempts=10
until	npm install -g \
					phantomjs \
					sails \
				|| [ $n -gt $attempts ]
do
		echo "Attempt $n failed"
		n=$(( $n + 1 ))
		if [ $n -gt $attempts ]
		then
				false
		fi
done

read -r -d '' USER_CONFIG << 'EOF'
# set PATH to include $HOME bin directory
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

export TERM=xterm
export PS1='\n\[\e[1;34m\][\d:\t]:\[\e[m\]\w/]:->\n\[\e[0;32m\]\u@\H\[\e[m\]:\[\e[0;31m\]$\[\e[m\] '
EOF

echo "$USER_CONFIG" > /home/vagrant/.bashrc
