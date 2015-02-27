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

server_update=true
server_upgrade=true
install_git=true
linux_users=(admin teamfortress)
linux_sudo_users=(admin)
ssh_port_number=40
ssh_root_login=false
ssh_banner=true
ssh_banner_msg="Welcome to our SSH server. Authorized users only!"
ssh_password_auth=false
ssh_default_login_grace_time=false
ssh_login_grace_time=20
ssh_limit_login_to_sudo=true
ssh_kick_idle_clients=true
iptables_allow_http=true
iptables_allow_tf2=true
iptables_allow_tf2_rcon=true
iptables_persistent=true
fail2ban_bantime=2592000
fail2ban_destemail="admin@localhost"
fail2ban_action="action_mwl"
fail2ban_install_dependencies=true
rkhunter_install_dependencies=true
rkhunter_destemail="admin@localhost"
rkhunter_disallow_root_ssh=true
rkhunter_addcron=true

./modules/checkroot.sh

./modules/autoupdate.sh $server_update $server_upgrade

./modules/dependencies.sh $install_git

./modules/usersetup.sh $linux_users $linux_sudo_users

./modules/ssh_setup.sh $ssh_port_number $ssh_root_login $ssh_banner $ssh_banner_msg $ssh_password_auth $ssh_default_login_grace_time $ssh_login_grace_time $ssh_limit_login_to_sudo $ssh_kick_idle_clients

./modules/iptables.sh $ssh_port_number $iptables_allow_http $iptables_allow_tf2 $iptables_allow_tf2_rcon $iptables_persistent

./modules/fail2ban.sh $ssh_port_number $fail2ban_bantime $fail2ban_destemail $fail2ban_action $fail2ban_install_dependencies

./modules/rkhunter.sh $rkhunter_install_dependencies $rkhunter_destemail $rkhunter_disallow_root_ssh $rkhunter_addcron
