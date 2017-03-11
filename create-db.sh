#!/bin/sh
#
# Creates a MySQL DB, user and grants privileges
#
# GitHub:   https://github.com/eatplaycode/lemp-stack
# Author:   EatPlayCode
# URL:      https://eatplaycode.com
#

# Enter the MySQL Details
MYSQL_USERNAME=
MYSQL_PASSWORD=

# Enter the Database Details
# to be created
NEW_DB_NAME=
NEW_DB_USERNAME=
NEW_DB_PASSWORD=

# Execute commands
mysql -u ${MYSQL_USERNAME} --password="${MYSQL_PASSWORD}" <<ENDOFSQL 
-- Create the database
CREATE DATABASE ${NEW_DB_NAME};
--
-- grant permission to login from localhost
GRANT USAGE ON *.* TO '${NEW_DB_USERNAME}'@'localhost' IDENTIFIED BY '${NEW_DB_PASSWORD}';
--
-- Grant all privileges to the wp user on the wp database
GRANT ALL PRIVILEGES ON ${NEW_DB_NAME}.* TO '${NEW_DB_USERNAME}'@'localhost';

--
-- grant permission to login from 127.0.0.1
grant usage on *.* to '${NEW_DB_USERNAME}'@'127.0.0.1' IDENTIFIED BY '${NEW_DB_PASSWORD}';
--
-- Grant all privileges to the wp user on the wp database
GRANT ALL PRIVILEGES ON ${NEW_DB_NAME}.* TO '${NEW_DB_USERNAME}'@'127.0.0.1';
--
-- flush the privileges to disk
FLUSH PRIVILEGES;
--
exit
ENDOFSQL
