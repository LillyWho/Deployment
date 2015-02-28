#!/bin/bash

# user setup system used to harden Linux Ubuntu 14.04 LTS servers.
# Copyright (C) 2015 Shen Zhou Hong - GNU GPL v 3

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# First checks if the script itself is ran as root by calling check_root module
./modules/checkroot.sh

# Creates and configures users
function user_setup () {

    # Adds a list of users defined in $users to the system. The argument should
    # be taking $linux_users from the master script.
    for i in admin teamfortress; do

        # Uses useradd with args for home directory creation, shell, and group
        echo "Adding $i user to system..."
        useradd $i -s /bin/bash -m -U

        # Asks for the password of the users, and changes it via chpasswd
        echo -n "Enter $i's password: "
        read -s password
        echo "Changing $i password..."
        echo "$i:$password" | chpasswd
    done

    # We are using the adduser command here instead of usermod or useradd.
    echo "Adding admin user to sudo group..."
    adduser admin sudo

}

# Installs SSH keys (vastly more secure type of authentication) to the server
function sshkeys_setup () {
    # Creates SSH folders and authorized_keys
    echo "Starting ssh-keys setup"

    # Creates the SSH dotfolder in the user's home directory.
    echo "Creating .ssh folder for admin..."
    mkdir /home/admin/.ssh/

    # Adding SSH key instructions
    echo "# Please paste in your SSH key for the admin user below" > /home/admin/.ssh/authorized_keys
    echo "# Make sure it is your PUBLIC KEY (id_rsa.pub)!!!" >> /home/admin/.ssh/authorized_keys
    echo "# Once you are done, save and quit. Ctrl + X, Y, and Enter" >> /home/admin/.ssh/authorized_keys

    # Opens nano and allows user to install SSH keys
    nano /home/admin/.ssh/authorized_keys

    # Changes file permissions so SSH works with it
    chmod -R 700 /home/admin/.ssh/
    chown -R admin:admin
}

# Calls function. Note that there's no exit command - this script is meant to
# be used in conjunction with the rest of the bash setup system.
user_setup
sshkeys_setup
