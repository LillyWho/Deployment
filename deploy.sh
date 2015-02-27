#!/bin/bash

# Dirsec-styled Team Fortress 2 automatic deployment system.
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

# Checks if script is ran as root
./modules/checkroot.sh

# Automatically updates server
./modules/autoupdate.sh

# Installs dependencies
./modules/dependencies.sh

# Setups users and ssh keys for each user
./modules/usersetup.sh

# Setups ssh to harden server further
./modules/ssh_setup.sh

# Starts to configure iptables
./modules/iptables.sh

# Setups fail2ban for additional security
./modules/fail2ban.sh

# rkhunter to check for rootkits
./modules/rkhunter.sh
