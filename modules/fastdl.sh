#!/bin/bash

# Automatic update script used on Linux Ubuntu 14.04 servers
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
./checkroot.sh

# Installs apache and configures apache virtual hosts
function apache_setup () {
    # Installs apache from apt-get
    echo "Downloading and installing apache2 for apache virtual hosts"
    apt-get --assume-yes install apache2

    # Provisions maps from git onto website
    git clone https://github.com/Dirsec/Mapbase.git /var/www/html/tf/maps
    mkdir /var/www/html/tf/replays

    # Changing ownership of directories
    chown -R admin:admin /var/www/html/
    chown -R teamfortress:teamfortress /var/www/html/tf/replays

    # Restarting apache2 after setup is complete
    echo "Apache2 setup complete. Restarting..."
    service apache2 restart
}

# Calls function. Note that there's no exit command - this script is meant to
# be used in conjunction with the rest of the bash setup system.
apache_setup
