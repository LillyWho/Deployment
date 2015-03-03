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

# Begin declaring global variables.

# Adds swapspace measured in Gigabytes into the server. The default value is
# 4 GB - which should be good enough for the team fortress 2 gameserver.
# However, a bit less swap is alright - providing you are willing to sacrifice
# some performance. Swap is configured to be optimal for gamehosting.
swap_amount_gb=4

# Default port number is 40. It's usually better to change the ssh port number
# to a non standard one (other then 22) - which we have already done here for
# you. Using a port number lower then 1024 increases security slightly and stops
# the majority of automated brute-force attempts on ssh servers.
ssh_port=40

# Sets the banner message for the secure shell server. If you must change this,
# Please only set a 1 line message. If you want to have a multi-line message,
# directly edit the file in /etc/issue.net and add in your own custom message.
# This does not impact the security of the server - it's for fun :)
ssh_banner_msg="Welcome to our SSH server. Authorized users only!"

# Connection to the server will only be allowed via SSH keys. Therefore there
# is no need to have a higher login grace time, since ssh key authentication
# is almost instantanous. A conservative value of 30 is set in order to
# compensate for slower network connections.
ssh_login_grace_time=30

# Issues a directive to iptables to DISABLE the team fortress 2 rcon port.
# rcon presents a significant security issue with the server, and any possible
# attackers can take over a server (briefly) through rcon. Administration is
# directly done through Sourcemod - therefore it is not needed and should be off
tf2_allow_rcon=false

# Sets the amount of time fail2ban should ban offenders for. There's no real
# reason to make it any lower - the time is specified in seconds. Fail2Ban
# automatically detects bruteforce attack attempts on the SSH server and bans
# attackers according to amount of time below (30 days).
fail2ban_bantime=2592000


# Begin calling prerequisite modules to prepare server for installation.
./modules/checkroot.sh

./modules/autoupdate.sh

./modules/dependencies.sh

./modules/usersetup.sh

# Extra configuration for server stability 

./modules/timezone.sh

./modules/swapadd.sh $swap_amount_gb

# Begin setting up basic security infrastructure for linux server.
./modules/sshsetup.sh $ssh_port $ssh_banner_msg $ssh_login_grace_time

./modules/iptables.sh $ssh_port $tf2_allow_rcon

./modules/fail2ban.sh $ssh_port $fail2ban_bantime

./modules/rkhunter.sh $rkhunter_destemail

# Begin setting up Team Fortress 2 server.
./modules/fastdl.sh

./modules/tf2setup.sh

# Restarts SSH
service ssh restart

# All finished!
echo "Congratulations! Your Dirsec-Styled Team Fortress 2 server has been setup"
echo "In order to start the server, change user (su) into 'teamfortress'"
echo "and simply start a new screen session, followed by running './tf.sh'"
echo "Enjoy!"

# Exit with success
exit 0
