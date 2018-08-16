OpenProject
===========
This document discribes the process of installing OpenProject in Ubuntu 16.04 LTS.

This document is based on or takes help from the following source(s):

- `How to Install OpenProject on Ubuntu 16.04 <https://www.howtoforge.com/tutorial/ubuntu-openproject-installation//>`_

Installation
------------
- Import the PGP key used to sign our packages. Since we're using the `packager.io <http://packager.io>`_ platform to distribute our packages, both package source and signing key are tied to their service. ::
    wget -qO- https://dl.packager.io/srv/opf/openproject-ce/key | sudo apt-key add -


Install apt-transport-https
---------------------------
- Our repository requires apt to have https support. Install this transport method with ``sudo apt-get install apt-transport-https`` if you did not already.

- Add the OpenProject packager source ::

    sudo wget -O /etc/apt/sources.list.d/openproject-ce.list https://dl.packager.io/srv/opf/openproject-ce/stable/7/installer/ubuntu/16.04.repo

- Using the following commands, apt will check the new package source and install the package and all required dependencies. ::

    sudo apt update
    sudo apt install openproject

Configuration
-------------
Using the following command we will configure OpenProject ::
    
    sudo openproject configure



FAQ
---
see this `link <https://github.com/opf/openproject/blob/dev/docs/installation/packaged/4-faq.md/>`_ for FAQ
