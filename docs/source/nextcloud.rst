Nextcloud
=========

Nextcloud is a Google Drive alternative. Through out this documentation we will see some variables starting with ``$``. We will change those variables to suit our preference.

Build Status
------------
.. image:: https://img.shields.io/badge/Last%20Build-passing-brightgreen.svg
.. .. image:: https://img.shields.io/badge/Last%20Build-failed-red.svg

Basic Installation
------------------
This part document describes the process of installing Nextcloud in Ubuntu 16.04 LTS.


Install the necessary packages
``````````````````````````````
Using the following command we will install the necessary packages. ::

   sudo apt update

   sudo apt -y upgrade

   sudo apt install -y apache2 postgresql-9.5 libapache2-mod-php7.0 php7.0-gd php7.0-json php7.0-curl php7.0-mbstring php7.0-intl php7.0-mcrypt php-imagick php7.0-xml php7.0-zip php7.0-pgsql

Download Nextcloud
``````````````````
Following this steps we can download Nextcloud to our web server

1. We need to go to this `Nextcloud Download <https://nextcloud.com/install/>`_ link with our preferred browser and click on ``Download`` button bellow ``Get Nextcloud Server`` section. A screen would pop up with a big ``Download Nextcloud`` button. Bellow that button we will see ``Details and Download options`` button. We need to click on that ``Details and Download options`` that will reviles 3 steps.

2. Next we need to right click on ``.tar.bz2`` and copy link address of first step the ``1. Download the .tar.bz2 or .zip archive`` which gives us the download link of latest and stable version of Nextcloud.

3. Now using ``wget`` download the ``nextcloud.tar.bz2`` to your preferred location. ::

    wget -O nextcloud.tar.bz2 $copied_link

We can see while we are writing this documentation we have 13.0.1 of Nextcloud as latest and stable version.

4. Then we need to decompress the ``.tar.bz2`` archive. We can do that by using this command. ::

    tar -xjf nextcloud.tar.bz2

5. To move Nextcloud to you web server document root use this command. ::

    sudo cp -r nextcloud /$path/to/webserver/document-root

6. Change the owner of ``nextcloud`` directory to ``www-data`` ::

    sudo chown -R www-data:www-data /$path/to/webserver/document-root/nextcloud/

Database configuration
``````````````````````
We are going to use PostgreSQL for our Nextcloud database. For other database configuration refer to `Nextcloud Database Configuration <https://docs.nextcloud.com/server/13/admin_manual/configuration_database/linux_database_configuration.html#postgresql-database/>`_ document.

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

Now we will enable the site with the following command::

    sudo a2ensite nextcloud.conf

Additionally we need to run this commands to enable some modules::

    sudo a2enmod rewrite
    sudo a2enmod headers
    sudo a2enmod env
    sudo a2enmod dir
    sudo a2enmod mime

To see the changed configuration on effect we need to restart the Apache Web Server::

    sudo systemctl restart apache2.service


Installation Wizard
```````````````````
We can go to the installation wizard by using our preferred browser and typing ``http://$server_ip/nextcloud`` on the address bar. On successful installation we should see the Nextcloud Installation Wizard. We need to follow this steps to finish installation.

1. At the top of the page we will be asked for user name and password for creating an admin account. Enter a good user name and strong password.

2. Next we have ``Data Folder`` which we can keep the default to ``$path/to/webserver/document-root/nextcloud/data`` to change to some other directory.

3. Next comes the database configuration. We need to give the user name, password and database from the `Database configuration`_.

.. todo:: link Database configuration on Installation Wizard to Database configuration above

4. Now click ``Finish setup`` and wait for some time to finish Nextcloud setup. After finishing the setup you will be redirected to the home page of Nextcloud.



Pretty URLs
-----------
Pretty URLs remove the ``index.php``-part in all Nextcloud URLs, for example in sharing links like ``https://example.org/nextcloud/index.php/s/Sv1b7krAUqmF8QQ``, making URLs shorter and thus prettier.

``mod_env`` and ``mod_rewrite`` must be installed on your webserver and the ``.htaccess`` must be writable by the HTTP user. Then you can set  two variables in the ``config.php``. If your setup is available on ``https://example.org/nextcloud`` do the following::

    'overwrite.cli.url' => 'https://example.org/nextcloud',
    'htaccess.RewriteBase' => '/nextcloud',

If it isn’t installed in a subfolder.::

    'overwrite.cli.url' => 'https://example.org',
    'htaccess.RewriteBase' => '/',

Finally run this occ-command to update your .htaccess file::

    sudo -u www-data php /var/www/nextcloud/occ maintenance:update:htaccess

After each update, these changes are automatically applied to the .htaccess-file



Enabling SSL
------------
To enable SSL run the following commands for Apache::

    sudo a2enmod ssl
    sudo a2ensite default-ssl
    sudo systemctl restart apache2.service



Backup
------
To backup an Nextcloud installation there are four main things we need to retain:

1. The config folder
2. The data folder
3. The theme folder
4. The database


Turn on maintenance mode
````````````````````````
``maintenance:mode`` locks the sessions of logged-in users and prevents new logins in order to prevent inconsistencies of data. We must run ``occ`` as the HTTP user, like this example::

    sudo -u www-data php $path/to/webserver/document-root/nextcloud/occ maintenance:mode --on

Make a backup directory
```````````````````````
We will make a temporery backup directory where we will story the backup files and directorys until we make a single ``.tar`` archive from them.::

    mkdir $path/of/backup/nextcloud_`date +"%d-%b-%Y"`

Backup folders
``````````````
Simply copy config, data and theme folders (or even our whole Nextcloud install and data folder) to a place outside of our Nextcloud environment. We can use this command::

    sudo rsync -Aax $path/to/webserver/document-root/nextcloud/ $path/of/backup/nextcloud_`date +"%d-%b-%Y"`/nextcloud_directory_backup_`date +"%d-%b-%Y"`/

Now compress the directory backup and make a ``.tar`` file::

    tar -zcvf $path/of/backup/nextcloud_`date +"%d-%b-%Y"`/nextcloud_directory_backup_`date +"%d-%b-%Y"`.tar.gz $path/of/backup/nextcloud_`date +"%d-%b-%Y"`/nextcloud_directory_backup_`date +"%d-%b-%Y"`/

After the archiving is successfully complete we can delete the ``nextcloud_directory_backup_`date +"%d-%b-%Y"`/`` directory::

    rm -rf $path/of/backup/nextcloud_`date +"%d-%b-%Y"`/nextcloud_directory_backup_`date +"%d-%b-%Y"`/

Backup database
```````````````
Now we will backup the PostgreSQL database::

    PGPASSWORD="$password" pg_dump nextcloud -h localhost -U $username -f $path/of/backup/nextcloud_`date +"%d-%b-%Y"`/nextcloud_databese_backup_`date +"%d-%b-%Y"`.dump

Compress full backup
````````````````````
Finally, we will bundle the directory backup archive with the database backup and make it a single ``.tar`` file::

    tar -zcvf $path/of/backup/nextcloud_`date +"%d-%b-%Y"`.tar.gz $path/of/backup/nextcloud_`date +"%d-%b-%Y"`/

And we are done with backup!


Restore
-------
To restore a Nextcloud installation there are four main things you need to restore:

1. The config folder
2. The data folder
3. The theme folder
4. The database

.. note:: You must have both the database and data directory. You cannot complete restoration unless you have both of these.

Decompress backup (if you have any)
```````````````````````````````````
Assuming we have a made a compressed backup archive following `Compress backup`_ and want to restore that, we need to Decompress the backup archive.::

    tar -xvzf $path/of/backup/nextcloud_$month-date-year.tar.gz

At this step, we should see one archive named ``nextcloud_directory_backup_$month-date-year.tar.gz`` and a database dump named ``nextcloud_databese_backup``.

Restore folders
```````````````
If we found the archive named ``nextcloud_directory_backup_$month-date-year.tar.gz`` containng Nextcloud config, data and theme dir. We need to decompress this directory::

    tar -xvzf $path/of/backup/nextcloud_directory_backup_$month-date-year.tar.gz

Then, we copy the decompressed directory to webserver root::

    sudo rsync -Aax nextcloud_directory_backup_$month-date-year/ $path/to/webserver/document-root/nextcloud/

Restore database
````````````````
To restore database we need to delete the old database and create a new one where the backup one will be restored.::

    PGPASSWORD="$password" psql -h localhost -U $username -d nextcloud -c "DROP DATABASE \"nextcloud\";"
    PGPASSWORD="$password" psql -h localhost -U $username -d nextcloud -c "CREATE DATABASE \"nextcloud\";"

Now we use the following command to restore the database::

    PGPASSWORD="$password" pg_restore -c -d nextcloud -h localhost -U $username $path/of/backup/nextcloud_$month-date-year/nextcloud_databese_backup_$month-date-year.dump



Email configuration
-------------------
Nextcloud is capable of sending password reset emails, notifying users of new file shares, changes in files, and activity notifications. Users configure which notifications they want to receive on their Personal pages.

We will be configuring a Gmail account as SMTP mail server. Navigate to ``Settings`` > ``Administration`` > ``Additional settings``. On top we will see ``Email server`` section. Put the following information:

* In ``Sent mode`` we will select ``SMTP``
* In ``Encryption`` we will  select ``SSL/TLS``
* In ``From address`` we will enter Gmail username in ``mail`` before the ``@`` sign and ``gmail.com`` in ``example.com`` after the ``@`` sign.  
* In ``Authentication`` we will select ``Login`` and Put check mark on 'Authentication required'
* In ``Server address`` we will enter ``smtp.gmail.com:465``
* In ``Credentials`` we have two parts ``SMTP Username`` and ``SMTP Password``
    - In ``SMTP Username`` we will put our Gmail username
    - In ``SMTP Password`` we will put our Gmail password [If the Gmail account has 2FA enable see this `link <https://support.google.com/accounts/answer/185833?hl=en>`_ to make an app password]. 

Now click on ``Store credentials`` and click on ``Send email`` to sent a test mail. 



Source
------

This document is based on or takes help from the following source(s):

- `How To Install Nextcloud In Ubuntu 16.04 LTS <https://www.ostechnix.com/install-nextcloud-ubuntu-16-04-lts>`_
- `Nextcloud Installation on Linux <https://docs.nextcloud.com/server/13/admin_manual/installation/source_installation.html>`_
- `Nextcloud Database Configuration <https://docs.nextcloud.com/server/13/admin_manual/configuration_database/linux_database_configuration.html>`_
- `Nextcloud Installation Wizard <https://docs.nextcloud.com/server/13/admin_manual/installation/installation_wizard.html>`_
- `Nextcloud Community answer <https://help.nextcloud.com/t/postgresql-nextcloud/1083/7>`_
- `Backing up Nextcloud <https://docs.nextcloud.com/server/13/admin_manual/maintenance/backup.html>`_
- `Restoring backup <https://docs.nextcloud.com/server/13/admin_manual/maintenance/restore.html>`_
- `Email configuration <https://docs.nextcloud.com/server/13/admin_manual/configuration_server/email_configuration.html>`_
