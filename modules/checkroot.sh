#!/bin/bash

# Rootchecker - checks if the bash script is ran as root under linux.
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

# Checks if the script is running as root
function checkroot () {
    # Checks if script is ran as root by checking user ID. Root user would
    # typically have  a user ID of zero on all Debian-based operating systems
    # and the script is meant to be run on Ubuntu 14.04 LTS.
    if [[ $EUID -ne 0 ]]; then

        # Prints scary warning message when not run as root.
        echo "WARNING WARNING WARNING WARNING WARNING WARNING"
        echo "This script must be run as the root user under"
        echo "linux. Please try again with either 'sudo' in"
        echo "fornt of it, or first change into the root user"
        echo "WARNING WARNING WARNING WARNING WARNING WARNING"

        # If the script is not ran as root, exit with error code 1
        exit 1
    fi
    # Otherwise, if the script is running as root - continue on.
}

# Calls function. Note that there's no exit command - this script is meant to
# be used in conjunction with the rest of the bash setup system.
checkroot
