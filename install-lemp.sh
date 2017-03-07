#!/bin/bash
#
# [Quick LEMP Stack Installation Script]
#
# GitHub:   https://github.com/eatplaycode/lemp-stack
# Author:   EatPlayCode
# URL:      https://eatplaycode.com
#
bold=$(tput bold)
normal=$(tput sgr0)
serverIP=$(hostname -I | cut -f1 -d' ')
cat <<!

# Delete package expect when script is done
# 0 - No.
# 1 - Yes.
PURGE_EXPECT_WHEN_DONE=0

${bold}LEMP Stack Installation${normal}

Installs Nginx, MariaDB, PHP5.6 on Ubuntu14.04 and deploys a sample
phpinfo() page to test configuration.
GitHub repo: ${bold}https://github.com/eatplaycode/lemp-stack${normal}

!
read -p "${bold}Do you want to continue?[y/N]${normal} " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo 'Exiting...'
  exit 1
fi

echo
echo
echo 'Checking distribution ...'
if [ ! -x  /usr/bin/lsb_release ]; then
  echo 'You do not appear to be running Ubuntu.'
  echo 'Exiting...'
  exit 1
fi
echo "$(lsb_release -a)"
echo
dis="$(lsb_release -is)"
rel="$(lsb_release -rs)"
if [[ "${dis}" != "Ubuntu" ]]; then
  echo "${dis}: You do not appear to be running Ubuntu"
  echo 'Exiting...'
  exit 1
elif [[ ! "${rel}" =~ ("14.04") ]]; then #
  echo "${bold}${rel}:${normal} You do not appear to be running a supported Ubuntu release."
  echo 'Exiting...'
  exit 1
fi
echo 'Checking permissions...'
echo
if [[ $EUID -ne 0 ]]; then
  echo 'This script must be run with root privileges.' 1>&2
  echo 'Exiting...'
  exit 1
fi

# Update packages and add MariaDB repository
echo -e '\n[Package Updates]'
apt-get install software-properties-common
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
add-apt-repository 'deb http://ftp.kaist.ac.kr/mariadb/repo/10.0/ubuntu trusty main'
add-apt-repository ppa:nginx/stable
add-apt-repository ppa:ondrej/php
apt-get update
apt-get -y upgrade

# Depencies and pip
echo -e '\n[Dependencies]'
apt-get -y install build-essential debconf-utils python-dev libpcre3-dev libssl-dev python-pip curl

# Install Nginx
echo -e '\n[Nginx]'
apt-get -y install nginx

# Create Default Nginx Server Block
echo -e "server {
  listen 80 default_server;
  listen [::]:80 default_server ipv6only=on;

  server_name ${serverIP};

  root /srv/www/default/public;
  index index.php index.html index.htm;

  charset utf-8;

  error_page 404 /404.html;

  location / {
    try_files \$uri \$uri/ /index.php?\$query_string;
  }

  location ~ \\.php\$ {
    try_files \$uri =404;
	fastcgi_split_path_info ^(.+\.php)(/.+)$;
    fastcgi_pass unix:/var/run/php/php5.6-fpm.sock;
    fastcgi_index index.php;
    fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    include fastcgi_params;
  }

}" > /etc/nginx/sites-available/default

mkdir -p /srv/www/default/public
ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# Install PHP and its modules
echo -e '\n[PHP-FPM]'
apt-get -y install php5.6 php5.6-fpm php5.6-common php5.6-mysql php5.6-curl php5.6-gd php5.6-cli php-pear php5.6-dev php5.6-imap php5.6-mbstring php5.6-mcrypt php5.6-xml
sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini
echo '<?php phpinfo(); ?>' > /srv/www/default/public/checkinfo.php

# Update Permissions
echo -e '\n[Adjusting Permissions]'
chgrp -R www-data /srv/www/*
chmod -R g+rw /srv/www/*
sh -c 'find /srv/www/* -type d -print0 | sudo xargs -0 chmod g+s'

# Install MariaDB
echo -e '\n[MariaDB]'
export DEBIAN_FRONTEND=noninteractive

if [ -n "${1}" -a -z "${2}" ]; then
  # Setup mysql root password
  CURRENT_MYSQL_PASSWORD=''
  NEW_MYSQL_PASSWORD="${1}"
else
  echo -e "Usage:\n"
  echo -e "   Run the script: ${0} 'your_new_root_password'"
    exit 1
fi

# Set MariaDB root password
debconf-set-selections <<< "mariadb-server mariadb-server/root_password password ''"
debconf-set-selections <<< "mariadb-server mariadb-server/root_password_again password ''"
apt-get -y install mariadb-server

#
# Check is expect package installed
#
if [ $(dpkg-query -W -f='${Status}' expect 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
  echo "Can't find expect. Trying install it..."
  apt-get -y install expect
fi

SECURE_MYSQL=$(expect -c "

set timeout 3
spawn mysql_secure_installation

expect \"Enter current password for root (enter for none):\"
send \"$CURRENT_MYSQL_PASSWORD\r\"

expect \"root password?\"
send \"y\r\"

expect \"New password:\"
send \"$NEW_MYSQL_PASSWORD\r\"

expect \"Re-enter new password:\"
send \"$NEW_MYSQL_PASSWORD\r\"

expect \"Remove anonymous users?\"
send \"y\r\"

expect \"Disallow root login remotely?\"
send \"y\r\"

expect \"Remove test database and access to it?\"
send \"y\r\"

expect \"Reload privilege tables now?\"
send \"y\r\"

expect eof
")

#
# Execution mysql_secure_installation
#
echo "${SECURE_MYSQL}"

if [ "${PURGE_EXPECT_WHEN_DONE}" -eq 1 ]; then
  # Uninstalling expect package
  apt-get -y purge expect
fi

# Start
echo
service nginx restart
service php5.6-fpm restart
service mysql stop
service mysql start
echo

echo 'LEMP Stack Installation Complete'

exit 0