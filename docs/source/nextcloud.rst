Nextcloud
=========

This document is about Nextcloud a Google Drive alternative. Change the words with ``$`` like ``$username`` to your preference.


Installation
------------
This part document describes the process of installing Nextcloud.


Install the necessary packages
``````````````````````````````
Using the following command install the necessary packages. ::

   sudo apt update

   sudo apt -y upgrade

   sudo apt install -y apache2 postgresql-9.5 libapache2-mod-php7.0 php7.0-gd php7.0-json php7.0-curl php7.0-mbstring php7.0-intl php7.0-mcrypt php-imagick php7.0-xml php7.0-zip php7.0-pgsql

Download Nextcloud
``````````````````
Following this steps we can download Nextcloud to our web server

1. We need to go to this `Nextcloud Download <https://nextcloud.com/install/>`_ link with our preferred browser and click on ``Download`` button bellow ``Get Nextcloud Server`` section. A screen would pop up with a big ``Download Nextcloud`` button. Bellow that button we will see ``Details and Download options`` button. We need to click on that ``Details and Download options`` that will reviles 3 steps.

2. Next we need to right click on ``.tar.bz2`` and copy link address of first step the ``1. Download the .tar.bz2 or .zip archive`` which gives us the download link of latest and stable version of Nextcloud.

3. Now using ``wget`` download the ``nextcloud.tar.bz2`` to your preferred location. ::

    wget -O nextcloud.tar.bz2 https://download.nextcloud.com/server/releases/nextcloud-13.0.1.tar.bz2

We can see while we are writing this documentation we have 13.0.1 of Nextcloud as latest and stable version.

4. Then we need to decompress the ``.tar.bz2`` archive. We can do that by using this command. ::

    tar -xjf nextcloud.tar.bz2

5. To move Nextcloud to you web server document root use this command. ::

    sudo cp -r nextcloud /$path/to/webserver/document-root

6. Change the owner of ``nextcloud`` directory to ``www-data`` ::

    sudo chown -R www-data:www-data /$path/to/webserver/document-root/nextcloud/

Database configuration
``````````````````````
We are going to use PostgreSQL for our Nextcloud database. For other database configuration refer to this `Database Configuration <https://docs.nextcloud.com/server/13/admin_manual/configuration_database/linux_database_configuration.html#postgresql-database/>`_ document.

Use this commands to configure PostgreSQL for Nextcloud::

    sudo -u postgres psql

Then a ``postgres=#`` prompt will appear. Now enter the following lines and confirm them with the enter key::

    CREATE USER $username WITH PASSWORD '$password';
    CREATE DATABASE nextcloud TEMPLATE template0 ENCODING 'UNICODE';
    ALTER DATABASE nextcloud OWNER TO $username;
    GRANT ALL PRIVILEGES ON DATABASE nextcloud TO $username;

You can quit the prompt by entering::

    \q

Apache Web Server Configuration
```````````````````````````````
Now we need to configure Apache Web Server. We will need to create a conf file for Nextcloud. ::

    sudo nano /etc/apache2/sites-available/nextcloud.conf

Now paste the following on that file::

    Alias /nextcloud "/$path/to/webserver/document-root/nextcloud"

    <Directory /$path/to/webserver/document-root/nextcloud/>
      Options +FollowSymlinks
      AllowOverride All

     <IfModule mod_dav.c>
      Dav off
     </IfModule>

     SetEnv HOME /$path/to/webserver/document-root/nextcloud
     SetEnv HTTP_HOME /$path/to/webserver/document-root/nextcloud

    </Directory>

Now create a ``symlink`` to ``/etc/apache2/sites-enabled`` ::

    sudo ln -s /etc/apache2/sites-available/nextcloud.conf /etc/apache2/sites-enabled/nextcloud.conf

This can also be done with the following command::

    sudo a2ensite nextcloud.conf

Additionally run this commands to enable some modules::

    sudo a2enmod rewrite
    sudo a2enmod headers
    sudo a2enmod env
    sudo a2enmod dir
    sudo a2enmod mime

To see the changed configuration on effect we need to restart the Apache Web Server::

    sudo systemctl restart apache2.service

OR ::

    sudo service apache2 restart


Enabling SSL
````````````
To enable SSL run the following commands for Apache::

    a2enmod ssl
    a2ensite default-ssl
    service apache2 reload

Now restart restart the Apache Web Server::

    sudo systemctl restart apache2.service

OR ::

     sudo service apache2 restart

Installation Wizard
```````````````````
We can go to the installation wizard by using our preferred browser and typing ``http://$server_ip/nextcloud`` on the address bar. On successful installation we should see the Nextcloud Installation Wizard. We need to follow this steps to finish installation.

1. At the top of the page we will be asked for user name and password for creating an admin account. Enter a good user name and strong password.

2. Next we have ``Data Folder`` which we can keep the default to ``$path/to/webserver/document-root/nextcloud/data`` to change to some other directory.

3. Next comes the database configuration. We need to give the user name, password and database from the Database configuration.

.. todo:: link Database configuration on Installation Wizard to Database configuration above

4. Now click ``Finish setup`` and wait for some time to finish Nextcloud setup. After finishing the setup you will be redirected to the home page of Nextcloud.



Source
------

This document is based on or takes help from the following source(s):

- `How To Install Nextcloud In Ubuntu 16.04 LTS <https://www.ostechnix.com/install-nextcloud-ubuntu-16-04-lts/>`_
- `Nextcloud Installation on Linux <https://docs.nextcloud.com/server/12/admin_manual/installation/source_installation.html/>`_
- `Nextcloud Database Configuration <https://docs.nextcloud.com/server/9/admin_manual/configuration_database/linux_database_configuration.html/>`_
- `Nextcloud Installation Wizard <https://docs.nextcloud.com/server/12/admin_manual/installation/installation_wizard.html/>`_ 
- `Nextcloud Community answer <https://help.nextcloud.com/t/postgresql-nextcloud/1083/7/>`_


