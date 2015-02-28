#!/bin/bash

# Swap adding script used on Linux Ubuntu 14.04 servers
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

# Adds a swap file to improve server performance
function addswap () {
    # Adds the amount of swap specified by the argument
    fallocate -l $1G /swapfile

    # Changes permissions so only root can write to it
    chmod 600 /swapfile

    # Actually activates the swap
    mkswap /swapfile
    swapon /swapfile

    # Makes swapfile permanent
    echo "/swapfile   none    swap    sw    0   0" >> /etc/fstab

    # Tweaks swap settings to optimize performance for TF2 gameservers
    sysctl vm.vfs_cache_pressure=50

    # Makes cache pressure change permanent
    echo "vm.vfs_cache_pressure = 50" >> /etc/sysctl.conf

}

# Calls function. Note that there's no exit command - this script is meant to
# be used in conjunction with the rest of the bash setup system.
addswap
