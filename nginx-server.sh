#!/bin/bash
#
# Setup server block in Nginx
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

echo
echo -e "****************************************************************"
echo -e "*"
echo -e "* Setting up Nginx Server Block:"
echo -e "*   Domain: ${fontgreen}${bold}${DOMAIN}${normal}"
echo -e "*   Directory: ${fontgreen}${bold}${DIRECTORY}${normal}"
echo -e "*"
echo -e "****************************************************************"
echo

# Confirm setup
read -p "${bold}Do you want to Proceed? [y/N]${normal} " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo
  echo -e "Exiting..."
  echo
  echo
  exit 1
fi

# Create Laravel App server block
echo -e "server {
        listen 80;

        server_name ${DOMAIN};

        root ${DIRECTORY};
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

# DECLARE SERVER_BLOCK
SERVER_BLOCK="/etc/nginx/sites-available/${DOMAIN}"
ENABLE_SERVER_BLOCK="ln -s /etc/nginx/sites-available/${DOMAIN} /etc/nginx/sites-enabled/${DOMAIN}"

# Confirm setup
read -p "${bold}Do you want to enanble the site? [y/N]${normal} " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo
  echo -e "Server block created but not yet enabled."
  echo -e "\nTo edit type the following in the terminal:"
  echo -e "\n   nano ${SERVER_BLOCK}"
  echo -e "\n\nTo enable site, type the following command:"
  echo -e "\n   ${ENABLE_SERVER_BLOCK}"
  echo -e "\n   service nginx restart"
  echo
  exit 1
fi

# enable server block
ln -s /etc/nginx/sites-available/${DOMAIN} /etc/nginx/sites-enabled/${DOMAIN}

# Update app directory permissions
echo -e "\n${fontgreen}Site has been enabled!"
echo
echo

# restart nginx
echo -e "Restarting Nginx and PHP5.6-FPM.."
echo
service nginx restart
service php5.6-fpm restart
echo

# Show Success Message
echo
echo -e "${fontgreen}Setup Completed!!"
echo

exit 0
