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

# Setups and configures the ssh daemon for a more secure SSH
function ssh_setup () {
    # ssh_setup configuration
    ssh_port_number=40
    ssh_root_login=false
    ssh_banner=true
    ssh_banner_msg="Welcome to $1 SSH server. Authorized users only!"
    ssh_password_auth=false
    ssh_default_login_grace_time=false
    ssh_login_grace_time=20
    ssh_limit_login_to_sudo=true
    ssh_kick_idle_clients=true
    ssh_kick_idle_interval=300


    # Change SSH default port
    echo "Changing SSH port number to $ssh_port_number"
    sed -i "/Port 22/c\Port $ssh_port_number" /etc/ssh/sshd_config

    # Do not allow root login via ssh
    if [[ $ssh_root_login=false ]]; then
        echo "Disabling root logins via SSH"
        sed -i '/PermitRootLogin yes/c\PermitRootLogin no' /etc/ssh/sshd_config
    fi

    # Activate SSH banner
    if [[ $ssh_banner=true ]]; then
        echo "Activating SSH banner"
        sed -i '/#Banner \/etc\/issue.net/c\Banner \/etc\/issue.net' /etc/ssh/sshd_config
        echo ssh_banner_msg > /etc/issue.net
    fi

    # Disable Password Authentication
    if [[ $ssh_password_auth=false ]]; then
        echo "Disabling password authentication"
        sed -i '/#PasswordAuthentication yes/c\PasswordAuthentication no' /etc/ssh/sshd_config
    fi

    # Create lower LoginGraceTime
    if [[ $ssh_password_auth=false ]]; then
        echo "Lowering LoginGraceTime"
        sed -i "/LoginGraceTime/c\LoginGraceTime $ssh_login_grace_time" /etc/ssh/sshd_config
    fi

    # Append AllowGroups clause to the end of the file
    if [[ $ssh_limit_login_to_sudo=true ]]; then
        echo "Only allowing the sudo group to login via ssh"
        echo "AllowGroups sudo" >> /etc/ssh/sshd_config
    fi

    # Append automatic idle client kicker to the end of the file
    if [[ $ssh_kick_idle_clients=true ]]; then
        echo "ClientAliveInterval  $ssh_kick_idle_interval" >> /etc/ssh/sshd_config
        echo "ClientAliveCountMax 0" >> /etc/ssh/sshd_config
    fi

    # Restart SSH daemon when complete
    echo "SSH Configuration complete. Restarting."
    service ssh restart
}

# Calls function. Note that there's no exit command - this script is meant to
# be used in conjunction with the rest of the bash setup system.
ssh_setup
