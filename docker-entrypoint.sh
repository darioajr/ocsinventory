#!/bin/sh
## Database user and password must be included in the variables DB_USER, DB_PASS and DB_NAME

DB_HOSTNAME=`echo $DB_PORT | cut -f3 -d/ | cut -f1 -d:`
DB_PORT_INT=`echo $DB_PORT | cut -f3 -d:`
DB_NAME_INT=${DB_NAME:-"ocsweb"}
DB_USER_INT=${DB_USER:-"ocs"}
DB_PASS_INT=${DB_PASS:-"ocs"}
DB_EXISTS=`mysql -h $DB_HOSTNAME -u $DB_USER_INT -p$DB_PASS_INT --skip-column-names -e "SHOW DATABASES LIKE '$DB_NAME_INT'"`

# echo User: $DB_USER_INT Pass: $DB_PASS_INT DBName: $DB_NAME_INT
# Write a new config file
cat <<EOF >/usr/share/ocsinventory-reports/ocsreports/dbconfig.inc.php
<?php
define("DB_NAME", "$DB_NAME");
define("SERVER_READ", "$DB_HOSTNAME");
define("SERVER_WRITE", "$DB_HOSTNAME");
define("COMPTE_BASE", "$DB_USER_INT");
define("PSWD_BASE", "$DB_PASS_INT");?>
EOF

# Modify z-ocsinventory-server.conf also
sed -i "s/PerlSetEnv OCS_MODPERL_VERSION.*/PerlSetEnv OCS_MODPERL_VERSION 2/" /etc/apache2/conf-available/z-ocsinventory-server.conf
sed -i "s/PerlSetEnv OCS_DB_HOST.*/PerlSetEnv OCS_DB_HOST $DB_HOSTNAME/" /etc/apache2/conf-available/z-ocsinventory-server.conf
sed -i "s/PerlSetEnv OCS_DB_PORT.*/PerlSetEnv OCS_DB_PORT $DB_PORT_INT/" /etc/apache2/conf-available/z-ocsinventory-server.conf
sed -i "s/PerlSetEnv OCS_DB_NAME.*/PerlSetEnv OCS_DB_NAME $DB_NAME_INT/" /etc/apache2/conf-available/z-ocsinventory-server.conf
sed -i "s/PerlSetEnv OCS_DB_LOCAL.*/PerlSetEnv OCS_DB_LOCAL $DB_NAME_INT/" /etc/apache2/conf-available/z-ocsinventory-server.conf
sed -i "s/PerlSetEnv OCS_DB_USER.*/PerlSetEnv OCS_DB_USER $DB_USER_INT/" /etc/apache2/conf-available/z-ocsinventory-server.conf
sed -i "s/PerlSetVar OCS_DB_PWD.*/PerlSetVar OCS_DB_PWD $DB_PASS_INT/" /etc/apache2/conf-available/z-ocsinventory-server.conf

# Check if database exists
if [ "$DB_EXISTS" != "$DB_NAME_INT" ]; then
        echo "Database doesn't exist, creating..."
        mysql -h $DB_HOSTNAME -u root -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE $DB_NAME_INT; GRANT ALL PRIVILEGES ON $DB_NAME_INT.* TO '$DB_USER_INT'@'%' IDENTIFIED BY '$DB_PASS_INT';";
	if [ -f "/etc/ocsinventory-server/install.php" ]; then
		mv /etc/ocsinventory-server/install.php /usr/share/ocsinventory-reports/ocsreports/install.php
	fi
else
	if [ -f "/usr/share/ocsinventory-reports/ocsreports/install.php" ]; then
		mv /usr/share/ocsinventory-reports/ocsreports/install.php /etc/ocsinventory-server/
	fi
fi
/usr/sbin/apachectl -D FOREGROUND

