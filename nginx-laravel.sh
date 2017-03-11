#!/bin/bash
#
# Setup server block for Laravel in Nginx
# with permission setup
#
# GitHub:   https://github.com/eatplaycode/lemp-stack
# Author:   EatPlayCode
# URL:      https://eatplaycode.com
#

# Styling
bold=$(tput bold)
normal=$(tput sgr0)
fontwhite="\033[1;37m"
fontgreen="\033[0;32m"

# App details
DIRECTORY=
DOMAIN=
APP_PUBLIC=${DIRECTORY}/public

echo
echo -e "****************************************************************"
echo -e "*"
echo -e "* Setting up Laravel on Nginx Server:"
echo -e "*   Domain: ${fontgreen}${bold}${DOMAIN}${normal}"
echo -e "*   Directory: ${fontgreen}${bold}${DIRECTORY}${normal}"
echo -e "*"
echo -e "****************************************************************"
echo

# Confirm setup
read -p "${bold}Do you want to Proceed? [y/N]${normal} " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo -e "Exiting...\n\n\n"
  exit 1
fi

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

# restart nginx
echo
service nginx restart
service php5.6-fpm restart
echo

# Show Success Message
echo
echo -e '${fontgreen}Setup Completed!!'
echo

exit 0
