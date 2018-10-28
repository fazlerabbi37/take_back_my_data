Avro Pad
========
`AvroPad<https://avro.im/>`_ is a full featured Avro Phonetic application with dictionary support. AvroPad can be used as an alternatives to:

- Bijoy Bangla

Build Status
------------
.. image:: https://img.shields.io/badge/Last%20Build-passing-brightgreen.svg
.. .. image:: https://img.shields.io/badge/Last%20Build-failed-red.svg

Install
-------

1. Add ``nodejs`` repo to apt source::

    curl -sL https://deb.nodesource.com/setup_8.x -o /tmp/nodesource_setup.sh

    sudo bash /tmp/nodesource_setup.sh

2. Install necessary packages::

    sudo apt install -y nodejs apache2

3. Clone the repo and change directory to ``avro-pad`` directory::

    git clone https://github.com/omicronlab/avro-pad

    cd avro-pad

4. Install dependencies::

    npm install

    sudo npm install -g gulp

.. note:: confused about the order of the commends. running ``sudo npm install -g gulp`` before ``npm install`` gives error.

5. Give it a test run::

    gulp watch

Then go to to http://$server_ip:8080 check if it works

6. Build the site::

    gulp build

7. Now rename the ``index`` file::

    mv build/index-*.html build/index.html

8. Copy the build directory to web server root and estart the Apache Web Server::

    sudo cp -r build/ /path/to/web/server/root/avro_pad

    sudo systemctl restart apache2.service

9. Additionally, we can open a ``index.html`` file on a browser and keep using it as well.


Source
------

- `avro-pad <https://github.com/omicronlab/avro-pad>`_
- `Avro Pad GitHub issue <https://github.com/torifat/avro-pad/issues/23>`_
- `How To Install Node.js on Ubuntu 16.04 <https://www.digitalocean.com/community/tutorials/how-to-install-node-js-on-ubuntu-16-04>`_
