Gitea installation
==================


Build Status
------------
.. image:: https://img.shields.io/badge/Last%20Build-passing-brightgreen.svg
.. .. image:: https://img.shields.io/badge/Last%20Build-failed-red.svg

Prepare environment
-------------------
Check that git is installed on the server::

    git --version

If it is not install it first::

    sudo apt install -y git

Create user to run Gitea (ex. `git`)::


    sudo adduser \
       --system \
       --shell /bin/bash \
       --gecos 'Git Version Control' \
       --group \
       --disabled-password \
       --home /home/git \
       git


Create required directory structure::

    sudo mkdir -p /var/lib/gitea/{custom,data,indexers,public,log}
    sudo chown git:git /var/lib/gitea/{data,indexers,log}
    sudo chmod 750 /var/lib/gitea/{data,indexers,log}
    sudo mkdir /etc/gitea
    sudo chown root:git /etc/gitea
    sudo chmod 770 /etc/gitea

.. note:: ``/etc/gitea`` is temporary set with write rights for user `git` so that Web installer could write configuration file. After installation is done it is recommended to set rights to read-only after installation.

Database installation
---------------------
We are going to use PostgreSQL for the database. If you do not have PostgreSQL installed, install with with the following commands::

    sudo apt update

    sudo apt install -y postgresql postgresql-contrib

If you don't have a PostgreSQL super user already create it using::

    sudo -u postgres createuser -slP $user_name

Now we will create a database::

    sudo -u postgres createdb -E UTF8 -O $psql_user gitea

Download Gitea
--------------
We need to open this `link <https://dl.gitea.io/gitea>`_ using a web browser. We will see directory with version numbers like `1.0.0`, `1.0.1`, `1.0.2` etc. Go to the directory of your chosen version. It is recommended to use the latest version. Now download the binary file matching your architecture. We need to download the file ``gitea-x.x.x-linux-arm64`` because we are using a Linux OS with arm64 architecture. Right click on the file and copy the link address. Download the file using ``wget``, replacing the link bellow with the one we just copied::

    wget -O gitea https://dl.gitea.io/gitea/x.x.x/gitea-x.x.x-linux-amd64

Copy ``gitea`` binary to global location::

    sudo cp gitea /usr/local/bin/gitea

Make the binary executable::

    sudo chmod +x /usr/local/bin/gitea


Create gitea service
--------------------
Download the example file with the following command::

    sudo wget -O /etc/systemd/system/gitea.service https://raw.githubusercontent.com/go-gitea/gitea/master/contrib/systemd/gitea.service

Open the file::

    sudo vim /etc/systemd/system/gitea.service

We should see something like this::

    [Unit]
    Description=Gitea (Git with a cup of tea)
    After=syslog.target
    After=network.target
    #After=mysqld.service
    #After=postgresql.service
    #After=memcached.service
    #After=redis.service

    [Service]
    # Modify these two values and uncomment them if you have
    # repos with lots of files and get an HTTP error 500 because
    # of that
    ###
    #LimitMEMLOCK=infinity
    #LimitNOFILE=65535
    RestartSec=2s
    Type=simple
    User=git
    Group=git
    WorkingDirectory=/var/lib/gitea/
    ExecStart=/usr/local/bin/gitea web -c /etc/gitea/app.ini
    Restart=always
    Environment=USER=git HOME=/home/git GITEA_WORK_DIR=/var/lib/gitea
    # If you want to bind Gitea to a port below 1024 uncomment
    # the two values below
    ###
    #CapabilityBoundingSet=CAP_NET_BIND_SERVICE
    #AmbientCapabilities=CAP_NET_BIND_SERVICE

    [Install]
    WantedBy=multi-user.target


Uncomment any service that needs to be enabled on this host, such as in our case PostgreSQL.

Change the user, home directory, and other required startup values. Change the PORT or remove the -p flag if default port is used.

Enable and start gitea at boot::

    sudo systemctl enable gitea
    sudo systemctl start gitea

Installation Wizard
-------------------
We can go to the installation wizard by using our preferred browser and typing http://$server_ip:3000 on the address bar. Successful pre-installation should show the Gitea home page. Now click ``Sign In``. It will redirect us to ``Initial Configuration`` page.

In the ``Database Settings``::

    Database Type = PostgreSQL
    Host          = 127.0.0.1:5432
    Username      = $psql_username
    Password      = $psql_password
    Database Name = gitea
    SSL           = Disable

In the ``General Settings``::

    Site Title             = $our_company_chosen_name
    Repository Root Path   =/home/git/gitea-repositories
    Git LFS Root Path      = /var/lib/gitea/data/lfs
    Run As Username        = git
    SSH Server Domain      = $server_ip_or_domain_name
    SSH Server Port        = 22
    Gitea HTTP Listen Port = $3000_or_port_of_our_choice
    Gitea Base URL         = http://$server_ip_or_domain_name:3000/
    Log Path               = /var/lib/gitea/log

In the ``Optional Settings`` we can set the ``Email Settings``, ``Server and Third-Party Service Settings`` and ``Administrator Account Settings``

In the ``Email Settings``::

    SMTP Host     = $smtp_host_address
    Send Email As = "$sender's_name" <$sender's_email_address>
    SMTP Username = $username
    SMTP Password = $password

Check ``Require Email Confirmation to Register`` if you want people to sign up which we will not be doing in our case and  ``Enable Email Notifications`` for email notification which we will do.

In the ``Server and Third-Party Service Settings``:

Check ``Enable Federated Avatars``, ``Disable Self-Registration``, ``Require Sign-In to View Pages``, ``Hide Email Addresses by Default``, ``Allow Creation of Organizations by Default`` and also check ``Enable Time Tracking by Default``.

In the ``Administrator Account Settings``::

    Administrator Username = $admin_username
                  Password = $admin_password
          Confirm Password = $admin_password_again
             Email Address = $email_address

Now click ``Install Gitea`` to finish installing ``Gitea``. After sometime, upon successful installation, we will be logged in as admin user.

Now we will change the permission of ``/etc/gitea`` directory using::

    sudo chmod 750 /etc/gitea
    sudo chmod 644 /etc/gitea/app.ini

Using Apache HTTPD with a Sub-path as a reverse proxy
-----------------------------------------------------
Install ``apache2`` if you don't have already, using the following command::

    sudo apt install -y apache2

Create a file ``gitea.conf`` in ``/etc/apache2/sites-available`` directory::

    sudo nano /etc/apache2/sites-available/gitea.conf

Now paste the following::

    <VirtualHost *:80>
        ProxyPreserveHost On
        ProxyRequests off
        <Proxy *>
             Order allow,deny
             Allow from all
        </Proxy>

        ProxyPass /$sub_dir_name http://localhost:$port
        ProxyPassReverse /$sub_dir_name http://localhost:$port
    </VirtualHost>

Enable the configuration::

    sudo a2ensite gitea.conf

I don't know why but at this point we need to disable the ``000-default.conf`` or else we will get 404 error. Let's do that now::

    sudo a2dissite 000-default.conf

Now open the config file::

    sudo vim /etc/gitea/app.ini

Find the ``[server]`` part where we need to change the `ROOT_URL``::

    ROOT_URL    =  http://$server_ip_or_domain_name/$sub_dir_name/

Restart ``gitea.service``::

    sudo systemctl restart gitea.service

Now enable ``proxy``, ``proxy_http`` mod of ``apache2``::

    sudo a2enmod proxy
    sudo a2enmod proxy_http

Finally we need to restart the Apache server::

    sudo systemctl restart apache2.service

Now visit ``http://$server_ip_or_domain_name/$sub_dir_name/`` where Gitea will be seen.

Apache Sub-path as HTTPS reverse proxy with Let's Encrypt
---------------------------------------------------------
After getting the SSL certificate from Let's Encrypt enable ``ssl`` mod::

    sudo a2enmod ssl

Open the ``gitea.conf`` file::

     sudo nano /etc/apache2/sites-available/gitea.conf

Change the file content to reflect this::

    SSLProxyEngine On
    ProxyPreserveHost On
    ProxyRequests off

    <Proxy *>
        Order allow,deny
        Allow from all
    </Proxy>

    ProxyPass /gitea http://localhost:3000
    ProxyPassReverse /gitea http://localhost:3000

Change the ``app.ini``::

    [server]
    PROTOCOL         = http
    SSH_DOMAIN       = your-domain.ltd
    DOMAIN           = your-domain.ltd
    HTTP_ADDR        = localhost
    HTTP_PORT        = 3000
    ROOT_URL         = https://your-domain.ltd/gitea/
    DISABLE_SSH      = false
    SSH_PORT         = 22

Now restart the ``gitea.service``::

    sudo systemctl restart gitea.service

Now restart the Apache server::

    sudo systemctl restart apache2.service

Gitea should be available at ``https://your-domain.ltd/gitea/`` address.


Source
------
- https://docs.gitea.io/en-us/install-from-binary/
- https://docs.gitea.io/en-us/linux-service/
- https://docs.gitea.io/en-us/reverse-proxies/
- https://github.com/go-gitea/gitea/issues/4537
