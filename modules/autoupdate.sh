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
./modules/checkroot.sh

# Automatically updates the linux server if needed.
function update () {
    # Updates server package lists
    # First variable should be the $server_update value. If set to true, it will
    # automatically hit the package lists and refresh the package cache.
    echo "Updating package lists..."

    # Uses --assume-yes to avoid the interactive prompts - does everything
    # without any user input.
    apt-get --assume-yes update

    # Upgrades server with new packages
    # Second variable should be set to $server_upgrade. If true, server will
    # also download and install new packages.
    echo "Performing automatic server update..."

    # Uses --assume-yes to avoid the interactive prompts - does everything
    # without any user input.
    apt-get --assume-yes upgrade
}

# Calls function. Note that there's no exit command - this script is meant to
# be used in conjunction with the rest of the bash setup system.
update
