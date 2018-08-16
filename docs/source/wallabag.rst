Wllabag
=======
This document describes the process of installing `Wallabag <https://www.wallabag.it/>`_ in Ubuntu 16.04 LTS. Change the words with ``$`` like ``$username`` to your preference.

This document is based on or takes help from the following source(s):

- `Install Wallabag on Ubuntu 16.04 Server with LAMP or LEMP <https://www.linuxbabe.com/ubuntu/install-wallabag-ubuntu-16-04>`_
- `Wallabag Installtion Documentation <https://doc.wallabag.org/en/admin/installation/readme.html>`_
- `Could not create database for connection named “ged” could not find driver <https://stackoverflow.com/questions/25063908/could-not-create-database-for-connection-named-ged-could-not-find-driver>`_
- `Apache shows php code instead of executing <https://stackoverflow.com/questions/12142172/apache-shows-php-code-instead-of-executing/43686765#43686765>`_

Install the necessary packages
------------------------------
Using the following command install the necessary packages. ::

   sudo -v

   sudo apt update

   sudo apt -y upgrade

   sudo apt install -y build-essential curl git postgresql postgresql-contrib php7.0-cli php7.0-curl php7.0-gd php7.0-xml php7.0-common php7.0-mbstring php7.0-bcmath php7.0-zip php7.0-pgsql libapache2-mod-php

We also need to install ``composer`` using this command::

    curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer


Make database
-------------
We are going to use PostgreSQL for our database. At first we need to create a user for PostgreSQL::

    sudo -u postgres createuser -dlsP --interactive $username

Use this commands to configure PostgreSQL for Wallabag::

    sudo -u postgres psql

Then a ``postgres=#`` prompt will appear. Now enter the following lines and confirm them with the enter key::

    CREATE DATABASE wallabag TEMPLATE template0 ENCODING 'UNICODE';
    ALTER DATABASE wallabag OWNER TO $username;
    GRANT ALL PRIVILEGES ON DATABASE wallabag TO $username;

You can quit the prompt by entering::

    \q

Install wallabag
----------------
We need to change directory to webserver root clone wallabag::

    cd /path/to/webserver/root
    sudo git clone https://github.com/wallabag/wallabag.git
    cd wallabag


Run ``sudo make install``. Change this parameter value and accept others with default::

    database_driver: pdo_pgsql
    database_port: 5432
    database_user: $username
    database_password: $password
    database_charset: utf8
    domain_name: '$protocole://ip_or_domain'
    secret: $some_suggeted_value

After taking this inputs wallabag database will be created and after it we will be asked to create a user and upon supplying user name, password and email it will create a admin user.

Now run the following command to change wallabag directory ownership to ``www-data`` user::

    sudo chown -R www-data:www-data /web/server/root/wallabag

Configure webserver
-------------------
To configure the webserver first we need run the following commands to enable ``rewrite`` mod::

    sudo a2enmod rewrite

    sudo systemctl reload apache2
    
Then we need to create a ``conf`` file for wallabag::

    sudo nano /etc/apache2/sites-available/wallabag.conf

Paste the following content into the file::

    <VirtualHost *:80>
        ServerName $ip_or_domain
        ServerAlias $ip_or_domain

        DocumentRoot /path/to/webserver/root/wallabag/web
        <Directory /path/to/webserver/root/wallabag/web>
            AllowOverride None
            Order Allow,Deny
            Allow from All

            <IfModule mod_rewrite.c>
                Options -MultiViews
                RewriteEngine On
                RewriteCond %{REQUEST_FILENAME} !-f
                RewriteRule ^(.*)$ app.php [QSA,L]
            </IfModule>
        </Directory>

        # uncomment the following lines if you install assets as symlinks
        # or run into problems when compiling LESS/Sass/CoffeScript assets
        # <Directory /path/to/webserver/root/wallabag>
        #     Options FollowSymlinks
        # </Directory>

        # optionally disable the RewriteEngine for the asset directories
        # which will allow apache to simply reply with a 404 when files are
        # not found instead of passing the request into the full symfony stack
        <Directory /path/to/webserver/root/wallabag/web/bundles>
            <IfModule mod_rewrite.c>
                RewriteEngine Off
            </IfModule>
        </Directory>
        ErrorLog /var/log/apache2/wallabag_error.log
        CustomLog /var/log/apache2/wallabag_access.log combined
    </VirtualHost>

Finally we need to enable the ``wallabag.conf`` and restart the ``apache2`` server.::

    sudo a2ensite wallabag.conf

    sudo systemctl restart apache2.service



TODO
----
- can we keep the main wallabag folder on some other place and symlink it to web server root?
- can we change the ``wallabag.conf`` to add alias like ``$ip/wallabag``?
