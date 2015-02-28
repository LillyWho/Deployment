#!/bin/bash

# SSH Security Script used to harden Linux Ubuntu 14.04 LTS servers.
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

# Change SSH default port
echo "Changing SSH port number to $1"
sed -i "/Port 22/c\Port $1" /etc/ssh/sshd_config

# Do not allow root login via ssh
echo "Disabling root logins via SSH"
sed -i '/PermitRootLogin yes/c\PermitRootLogin no' /etc/ssh/sshd_config

# Activate SSH banner
echo "Activating SSH banner"
sed -i '/#Banner \/etc\/issue.net/c\Banner \/etc\/issue.net' /etc/ssh/sshd_config
echo $2 > /etc/issue.net

# Disable Password Authentication
echo "Disabling password authentication"
sed -i '/#PasswordAuthentication yes/c\PasswordAuthentication no' /etc/ssh/sshd_config

# Create lower LoginGraceTime
echo "Lowering LoginGraceTime"
sed -i "/LoginGraceTime/c\LoginGraceTime $3" /etc/ssh/sshd_config

# Append AllowGroups clause to the end of the file
echo "Only allowing the sudo group to login via ssh"
echo "AllowGroups sudo" >> /etc/ssh/sshd_config

# Append automatic idle client kicker to the end of the file
echo "ClientAliveInterval  300" >> /etc/ssh/sshd_config
echo "ClientAliveCountMax 0" >> /etc/ssh/sshd_config

# Restart SSH daemon when complete
echo "SSH Configuration complete. Restarting."
service ssh restart
