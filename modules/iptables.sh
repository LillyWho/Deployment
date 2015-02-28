#!/bin/bash

# Iptables setup script for Ubuntu 14.04 LTS server
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

# Starts configuring iptables and allows current connections
echo "Allowing all currently established connections"
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Opens SSH non-default port number
echo "Allowing non-default SSH port"
iptables -A INPUT -p tcp --dport $1 -j ACCEPT

# Opens webserver port 80
echo "Allowing default HTTP webserver port"
iptables -A INPUT -p tcp --dport 80 -j ACCEPT

# Opens Team Fortress 2 main connection port
echo "Allowing team fortress 2 main port"
iptables -A INPUT -p udp --dport 27015 -j ACCEPT

# Opens Team Fortress 2 rcon port
if [[ $2=true ]]; then
    echo "Allowing rcon team fortress 2 port"
    iptables -A INPUT -p tcp --dport 27015 -j ACCEPT
fi

# Allows loopback devices
echo "Allowing all loopback devices"
iptables -I INPUT 1 -i lo -j ACCEPT

# Sets default drop rule for INPUT chain
echo "Setting default drop policy for iptables"
iptables -P INPUT DROP

# Lists all rules
echo "Listing all iptables rules"
iptables -L --line-numbers

# Installing iptables persistant to save rules
echo "Installing persistent iptables to save rules"
apt-get --assume-yes install iptables-persistent
