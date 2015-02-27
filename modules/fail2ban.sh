#!/bin/bash

# Fail2Ban installer used to harden Linux Ubuntu 14.04 LTS servers.
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

# Installs the fail2ban dynamic firewall modifier and configures it properly.
function fail2ban_setup () {
    # Fail2ban configuration
    fail2ban_bantime=2592000
    fail2ban_destemail="admin@localhost"
    fail2ban_action="action_mwl"
    fail2ban_install_dependencies=true

    # Passed via argument
    ssh_port_number = $1

    # Installs fail2ban
    apt-get --assume-yes install fail2ban

    # Copys configuration file over
    cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

    # Lengthening bantime to user specified value.
    echo "Setting bantime to $fail2ban_bantime seconds"
    sed -i "/bantime  = 600/c\bantime  = $fail2ban_bantime" /etc/fail2ban/jail.local

    # changing destemail to all sudo-enabled admins
    echo "Changing the destination email for warnings to $fail2ban_destemail"
    sed -i "/destemail = root@localhost/c\destemail = $fail2ban_destemail" /etc/fail2ban/jail.local

    # Allows detailed mail reports to be emailed after banning
    echo "Changing action to include the mailing of logs"
    sed -i "/action = %(action_)s/c\action = %($fail2ban_action)s" /etc/fail2ban/jail.local

    # Changes so that port number for SSH is set to non-default port
    echo "Setting SSH port number on Fail2ban to the non default port"
    # Note that this sed uses " " because doublequtoes expand variables
    sed -i "/port     = ssh/c\port     = $ssh_port_number"

    # Installs all the rest of the parts and pieces
    if [[ $fail2ban_install_dependencies=true ]]; then
        echo "Installing sendmail and iptables-persistent before restarting service"
        apt-get --assume-yes install sendmail iptables-persistent
    fi

    # Restarting fail2ban service
    service fail2ban stop
    service fail2ban start
}

# Calls function. Note that there's no exit command - this script is meant to
# be used in conjunction with the rest of the bash setup system.
fail2ban_setup
