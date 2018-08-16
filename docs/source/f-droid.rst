F-Droid
=======
This document describes the process of installing F-Droid server in Ubuntu 16.04 LTS. Change the words with ``$`` like ``$username`` to your preference.

This document is based on the following source:

- `Setup an F-Droid App Repo <https://f-droid.org/en/docs/Setup_an_F-Droid_App_Repo/>`_

Build Status
------------
.. .. image:: https://img.shields.io/badge/Last%20Build-passing-brightgreen.svg
.. image:: https://img.shields.io/badge/Last%20Build-failed-red.svg

Installation
------------
To install the following the packages::

    sudo apt install fdroidserver apache2 openjdk-9-jre-headless openjdk-9-jdk-headless

We also need to install Android SDK. As of now Android SDK can't be downloaded separately so we need to download Android Studio and download SDK. Android Studio installation is a long process which will be described in this document. Download Android Studio for Linux from this `link <https://developer.android.com/studio/index.html>`_ and see the installation instruction from this `link <https://developer.android.com/studio/install.html>`_. When you are done with you Android Studio installation set you Android SDK to you ``PATH`` variable or export it as ``ANDROID_HOME`` in ``.bashrc``.

Configuration
-------------
To configure F-Droid server go to a directory where you want to install F-Droid and make a directory name ``fdroid``. Now change directory to ``fdroid`` directory. ::

    mkdir fdroid
    cd fdroid

Now we will initialize the F-Droid server. ::

    fdroid init 

This command gives a long output where it creates a ``keystore.jks`` key file.

Now we need to copy some apks into the ``repo`` directory and update the server. ::

    cp $path/to/apks/*.apk /$path/to/fdroid/repo

    fdroid update -c
    fdroid update

This two command creates metadata for the apps in the ``metadata`` directory and a signed index. A listing of this directory will revile the same number of ``.txt`` as of apks we put on the ``repo`` directory. We need to edit this ``metadata`` texts to add ``catagory``. To do so we need to run::

    fdroid rewritemeta

Now we can go to ``metadata`` directory and add ``catagory`` of our choice. After adding the catagory(s) we need to update the F-Droid server with this command::

    fdroid update

We need to configure our webserver to serve the repo. We will make a directory for F-Droid inside our webserver's root directory so that the repos can be served. ::

    sudo mkdir $path/to/webserver/root/fdroid

Now we need to change some configuration of ``config.py``. We need to add ``serverwebroot`` in ``config.py`` ::

    serverwebroot = '$path/to/webserver/root/fdroid'

Now update the webserver ::

    sudo fdroid server update -v

Now restart the apache service to see the change in effect. ::

    sudo systemctl restart apache2.service

Now if we open the ``$f-droid_server_ip/fdroid/repo`` link in a browser we should see ``catagories.txt``, ``index.xml``, ``index.jar``, apks we put into ``repo`` directory and some icons directory. If everything is there we can now add this repo to our F-Droid android client by going to ``Settings`` > ``Repositories``.
