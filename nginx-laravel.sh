#!/bin/sh
#
# Setup server block for Laravel in Nginx
# with permission setup
#
# GitHub:   https://github.com/eatplaycode/lemp-stack
# Author:   EatPlayCode
# URL:      https://eatplaycode.com
#

# App details
DIRECTORY=
DOMAIN=
APP_PUBLIC=${DIRECTORY}/public

# Create Laravel App server block
echo -e "server {
  listen 80;

  server_name ${DOMAIN};

  root ${APP_PUBLIC};
  index index.php index.html index.htm;

  location / {
    try_files \$uri \$uri/ /index.php?\$query_string;
  }

  location ~ \\.php\$ {
    try_files \$uri /index.php =404;
	fastcgi_split_path_info ^(.+\.php)(/.+)$;
    fastcgi_pass unix:/var/run/php/php5.6-fpm.sock;
    fastcgi_index index.php;
    fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    include fastcgi_params;
  }

}" > /etc/nginx/sites-available/${DOMAIN}

# enable server block
ln -s /etc/nginx/sites-available/${DOMAIN} /etc/nginx/sites-enabled/${DOMAIN}

# Update app directory permissions
echo -e '\n[Setting up Permissions]'
echo
chown -R :www-data ${DIRECTORY}
chmod -R 755 ${DIRECTORY}/storage


exit 0