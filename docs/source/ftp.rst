FTP Server
==========
This document discribes the process of installing FTP server with ``vsftpd`` in Ubuntu 16.04 LTS. Change the variable starting with ``$`` like ``$user`` to requirement to make the process work.

This document is based on or takes help from the following source(s):

- `How To Set Up vsftpd for a User's Directory on Ubuntu 16.04 <https://www.digitalocean.com/community/tutorials/how-to-set-up-vsftpd-for-a-user-s-directory-on-ubuntu-16-04>`_

Installing vsftpd
-----------------
We'll start by updating our package list and installing the ``vsftpd`` daemon::

    sudo -v

    sudo apt update

    sudo apt install -y vsftpd

When the installation is complete, we'll copy the configuration file so we can start with a blank configuration, saving the original as a backup. ::

    sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.backup

Now we are done with the installation. Lets proceed with the configuration.

Configuration
-------------

.. note:: add firewall opening refer to a firewall configuration doc and say which ports need to be open.

We need to create a user for our FTP. If we do not allow anonymous users than this user's ``username`` and ``password`` will be shared among all FTP users::

    sudo adduser $user

Fill up the information to create a new user. FTP is generally more secure when users are restricted to a specific directory. ``vsftpd`` accomplishes this with ``chroot`` jails. When ``chroot`` is enabled for local users, they are restricted to their home directory by default. However, because of the way ``vsftpd`` secures the directory, it must not be writable by the user.

In this example, rather than removing write privileges from the home directory, we're will create an ``ftp`` directory to serve as the ``chroot`` and a writable ``files`` directory to hold the actual files.

Create the ftp folder, set its ownership, and be sure to remove write permissions with the following commands::

    sudo mkdir /home/$user/ftp
    sudo chown nobody:nogroup /home/$user/ftp
    sudo chmod a-w /home/$user/ftp

Let's verify the permissions::

    sudo ls -la /home/$user/ftp

Output::

    total 8
    4 dr-xr-xr-x  2 nobody nogroup 4096 Aug 24 21:29 .
    4 drwxr-xr-x 3 $user  $user   4096 Aug 24 21:29 ..

Next, we'll create the directory where files can be uploaded and assign ownership to the user::

    sudo mkdir /home/$user/ftp/files
    sudo chown $user:$user /home/$user/ftp/files

A permissions check on the ``files`` directory should return the following::

    sudo ls -la /home/$user/ftp

Output::
    
    total 12
    dr-xr-xr-x 3 nobody nogroup 4096 Aug 26 14:01 .
    drwxr-xr-x 3 $user  $user   4096 Aug 26 13:59 ..
    drwxr-xr-x 2 $user  $user   4096 Aug 26 14:01 files

We'll add a test.txt file to use when we test later on::

    echo "vsftpd test file" | sudo tee /home/$user/ftp/files/test.txt

Now we will change the ``/etc/vsftpd.conf`` file. Lets open the file with our choice of editor. Here I am using ``vim`` ::

    sudo vim /etc/vsftpd.conf

We will change some values in the configuration file. They are the following.

    1. Allowing or denying anonymous users can be done using ``anonymous_enable`` variable. Set ``anonymous_enable`` to ``YES`` to allow anonymous user login and ``NO`` to deny.

    2. Allowing or denying local users can be done using ``local_enable`` variable. Set ``local_enable`` to ``YES`` to allow local user login and ``NO`` to deny.

    3. Allowing or denying uploading file by users can be done using ``write_enable`` variable. Set ``write_enable`` to ``YES`` to allow uploading by user and ``NO`` to deny.

    4. Allowing or denying FTP-connected user from accessing any files or commands outside the directory tree can be done using ``chroot_local_user`` variable. Set ``chroot_local_user`` to ``YES`` to deny FTP-connected user from accessing any files or commands outside the directory tree and ``NO`` to allow.

    5. Now we will add some addition variables at the end of ``/etc/vsftpd.conf`` file with their values::

        user_sub_token=$USER
        local_root=/home/$USER/ftp
        userlist_enable=YES
        userlist_file=/etc/vsftpd.userlist
        userlist_deny=NO

    First 2 line makes a ``local_root`` for local users and next 3 lines enables a user lint with a ``userlist_deny`` variable that can be toggled to ``YES`` to deny access and ``NO`` to allow access. Now we are done with ``/etc/vsftpd.conf`` and can save and exit the editor.

We created a user list where we need to allow our user. Lets do it now::

    echo "$user" | sudo tee -a /etc/vsftpd.userlist

Double-check that it was added as you expected::

    cat /etc/vsftpd.userlist

Output::

    $user

Restart the daemon to load the configuration changes::

    sudo systemctl restart vsftpd

The server can be tested using the ``ftp`` command or by using the GUI tool `Filezilla <https://filezilla-project.org>`_. 


Disabling Deletion of files
---------------------------
.. tip:: NO need to do it if you have set ``write_enable`` to ``NO`` in ``/etc/vsftpd.conf`` file at `Configuration <ftp.html#configuration>`_ par part.

Login as ``$user`` using the following command::

    su $user

Now we need to open ``.bash_aliases`` with editor::

    vim ~/.bash_aliases

Now paste the following ``bash`` script ::

    ftp_no_delete() {
    for file in $@
    do
        echo "You are not allowed to delete any file."
    done
    }
    
    alias rm='ftp_no_delete'

Now save and exit ``.bash_aliases`` file and run this final command::

    . ~/.basrc

Now if we try deleting file we will be given the message ``You are not allowed to delete any file.``

Disabling Shell Access
----------------------
First, open a file called ftponly in the bin directory::

    sudo nano /bin/ftponly

We'll add a message telling the user why they are unable to log in. Paste in the following::

    #!/bin/sh
    echo "This account is limited to FTP access only."

Change the permissions to make the file executable::

    sudo chmod a+x /bin/ftponly

Now we need to add it to the list of valid shells. Open the list of valid shells, I will be using ``vim`` as before::

    sudo vim /etc/shells

At the bottom, add ``/bin/ftponly`` then save and exit the ``/etc/shells`` file. Then update the user's shell with the following command::

    sudo usermod $user -s /bin/ftponly

Now try logging in as ``$user``::

    ssh $user:$ftp_server_ip

We should see something like::

    This account is limited to FTP access only.
    Connection to $ftp_server_ip closed.

This confirms that the user can no longer ssh to the server and is limited to FTP access only.



