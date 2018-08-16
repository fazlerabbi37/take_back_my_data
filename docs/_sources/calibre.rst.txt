Calibre
=======
This document describes the process of installing `calibre <https://calibre-ebook.com/>`_ in Ubuntu 16.04 LTS. Change the words with ``$`` like ``$username`` to your preference.

This document is based on or takes help from the following source(s):

- `The calibre Content server <https://manual.calibre-ebook.com/server.html>`_
- `How To Create a Calibre Ebook Server on Ubuntu 14.04 <https://www.digitalocean.com/community/tutorials/how-to-create-a-calibre-ebook-server-on-ubuntu-14-04>`_
- `Download for Linux <https://calibre-ebook.com/download_linux>`_
- `calibre-server <https://manual.calibre-ebook.com/generated/en/calibre-server.html>`_




..
    Install the necessary packages
    ------------------------------
    Using the following command install the necessary packages. ::

       sudo apt update

       sudo apt -y upgrade

       sudo apt install -y xdg-utils wget xz-utils python

Build Status
------------
.. image:: https://img.shields.io/badge/Last%20Build-passing-brightgreen.svg
.. .. image:: https://img.shields.io/badge/Last%20Build-failed-red.svg

Download calibre
----------------
Using the following command we can install calibre::

    sudo -v && wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sudo sh /dev/stdin

This should download the ``linux-installing.sh`` and execute it and after installation it should give the following output with::

    Setting up desktop integration...
    Run "calibre" to start calibre 

.. note:: before this it may give some warinings as well. If it gaves ``ImportError: libGL.so.1: cannot open shared object file: No such file or directory`` we need to install ``libgl1-mesa-glx`` using ``sudo apt install libgl1-mesa-glx``

Run the server
--------------
To run the calibre server we need to use the following command::

    calibre-server --port $port_number
