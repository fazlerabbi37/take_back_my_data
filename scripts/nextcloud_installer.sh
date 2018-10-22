#author: fazlerabbi37

#shell script name: nextcloud_installer.sh 

#the purpose of the shell script is to install Nextcloud

#!/bin/bash

#user input



#be sudo
sudo -v

#update
sudo apt update

#upgrade
sudo apt -y upgrade

#install some package
sudo apt install -y apache2 postgresql-9.5 libapache2-mod-php7.0 php7.0-gd php7.0-json php7.0-curl php7.0-mbstring php7.0-intl php7.0-mcrypt php-imagick php7.0-xml php7.0-zip php7.0-pgsql

#ask user for nextcloud version
echo "Enter the version of Nextcloud you want to install [x.y.z]:"
read nextcloud_version
echo ""

web_server_root=$(cat /etc/apache2/sites-available/000-default.conf | grep DocumentRoot | awk '{print $2}')
echo "The script found your web server root at $web_server_root."
read -p "If you want to change the web server root, at first change it at '/etc/apache2/sites-available/000-default.conf' file and press enter."
web_server_root=$(cat /etc/apache2/sites-available/000-default.conf | grep DocumentRoot | awk '{print $2}')
echo "Setting web server root as $web_server_root"
echo $web_server_root

#download nextcloud
sudo wget -O $web_server_root/nextcloud.tar.bz2 https://download.nextcloud.com/server/releases/nextcloud-$nextcloud_version.tar.bz2

#unzip nextcloud.tar.bz2 file
sudo tar -xjf $web_server_root/nextcloud.tar.bz2 -C $web_server_root


#change the owner of nextcloud directory to www-data
sudo chown -R www-data:www-data $web_server_root/nextcloud/

#delete teh nextcloud.tar.bz2 file
sudo rm -rf $web_server_root/nextcloud.tar.bz2

#database configuration
#ask for PostgreSQL database user
#read -p "Enter the name of PostgreSQL database user: " psql_username
#read -sp "Enter the password of PostgreSQL database user: " psql_password
psql_username=map_server
psql_password=pathaomap

#do psql staff
sudo -u postgres psql -c "CREATE USER $psql_username WITH PASSWORD '$psql_password';"
sudo -u postgres psql -c "CREATE DATABASE nextcloud TEMPLATE template0 ENCODING 'UNICODE';"
sudo -u postgres psql -c "ALTER DATABASE nextcloud OWNER TO $psql_username;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE nextcloud TO $psql_username;"

#make apache config
cat > nextcloud.conf <<EOL
alias /nextcloud "$web_server_root/nextcloud"
<Directory $web_server_root/nextcloud/>
  Options +FollowSymlinks
  AllowOverride All

 <IfModule mod_dav.c>
  Dav off
 </IfModule>

 SetEnv HOME $web_server_root/nextcloud
 SetEnv HTTP_HOME $web_server_root/nextcloud

</Directory>
EOL

#move config to 
sudo mv nextcloud.conf /etc/apache2/sites-available/nextcloud.conf

#enable nextcloud.conf
sudo a2ensite nextcloud.conf

#enable some modules
sudo a2enmod rewrite
sudo a2enmod headers
sudo a2enmod env
sudo a2enmod dir
sudo a2enmod mime

#restart Apache web server
sudo systemctl restart apache2.service

echo "Now head to your $server_ip/nextcloud address to finish installation."
