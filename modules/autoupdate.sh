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

# Automatically updates the server if needed
function update () {
    # update configuration
    linux_server_update=true
    linux_server_upgrade=true

    # Updates server package lists
    if [[ $linux_server_update=true ]]; then
        echo "Updating package lists..."
        apt-get --assume-yes update
    fi

    # Upgrades server with new packages
    if [[ $linux_server_upgrade=true ]]; then
        echo "Performing automatic server update..."
        apt-get --assume-yes upgrade
    fi
}

# Calls function. Note that there's no exit command - this script is meant to
# be used in conjunction with the rest of the bash setup system.
update
