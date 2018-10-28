Drone
=====
Drone is continues integration tool like Travis CI. In this document we will install Drone and integrate with Gitea.

Build Status
------------
.. image:: https://img.shields.io/badge/Last%20Build-passing-brightgreen.svg
.. .. image:: https://img.shields.io/badge/Last%20Build-failed-red.svg



Installation
------------
This part of the document describes the process of installing Drone in Ubuntu 16.04 LTS.

Install the necessary packages
``````````````````````````````
1. Let's first use the following commands to update and upgrade packages. ::

    sudo apt update

    sudo apt -y upgrade

2. We need to install ``docker-ce``.

- To start we will remove ``docker`` if it is already installed::

    sudo apt remove docker docker-engine docker.io

- Make sure you have the following package installed to move forward::

    sudo apt-get install apt-transport-https ca-certificates curl software-properties-common

- Add Docker’s official GPG key::

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

- Set up the stable docker repository::

    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

- Update the repo::

    sudo apt update

- Install the latest version of Docker CE::

    sudo apt-get install docker-ce

3. Now we will install ``docker-compose``

- Download the latest version of Docker Compose::

    sudo curl -L "https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

- Make it executable::

    sudo chmod +x /usr/local/bin/docker-compose

Pull the drone image
````````````````````
We will pull the drone docker image to our host machine.::

    sudo docker pull drone/drone:0.8

Configuration
-------------
Now we will create a ``docker-compose.yaml`` file with all the configuration to run drone. We will open ``docker-compose.yaml`` with our favourite editor::

    nano docker-compose.yaml

Now paste the following to create the basic configuration::

    version: '2'

    services:
      drone-server:
        image: drone/drone:0.8

        ports:
          - 8000
          - 9000
        volumes:
          - drone-server-data:/var/lib/drone/
        restart: always
        environment:
          - DRONE_OPEN=false
          - DRONE_HOST=${DRONE_HOST}
          - DRONE_SECRET=${DRONE_SECRET}

      drone-agent:
        image: drone/agent:0.8

        command: agent
        restart: always
        depends_on:
          - drone-server
        volumes:
          - /var/run/docker.sock:/var/run/docker.sock
        environment:
          - DRONE_SERVER=drone-server:9000
          - DRONE_SECRET=${DRONE_SECRET}

    volumes:
      drone-server-data:
    
We can do a lot more tweak in the ``docker-compose.ymal`` file which can be found in the `Drone Docs: Installation Overview <http://docs.drone.io/installation/>`_.

Thought Drone supports GitHub, GitLab, Gitea, Gogs, Bitbucket Cloud, Bitbucket Server and Coding but in this document we will configure Gitea to run with Drone. The configuration for other git web service can be found in the `Drone Docs: Integrations <http://docs.drone.io/installation/>`_. For Gitea integration we simply need to add two ``environment`` variable bellow ``DRONE_HOST`` variable.::

    - DRONE_GITEA=true
    - DRONE_GITEA_URL=http://gitea_url.ltd:port


Customization
-------------
We can customize the drone to use it only in private mode and set Drone admin user.

Gitea private mode
``````````````````
If Gitea installation is running in private mode we can run our Drone in private mode as welli by adding the following bellow ``DRONE_GITEA_URL`` variable::

    - DRONE_GITEA_PRIVATE_MODE=true

Gitea admin
```````````
We can define Gitea admin user(s). Only those who are added as Gitea admin can login into Drone. To add Drone admin add ``DRONE_ADMIN`` variable under ``DRONE_GITEA_URL`` as well::

    - DRONE_ADMIN=$user_name


Source
------
- `Get Docker CE for Ubuntu <https://docs.docker.com/install/linux/docker-ce/ubuntu/>`_
- `Install Docker Compose <https://docs.docker.com/compose/install/>`_
- `Installation Overview <http://docs.drone.io/installation/>`_
