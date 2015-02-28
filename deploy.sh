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

#############################################################################
# WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING   #
#############################################################################
#                                                                           #
# DEFAULT CONFIGURATION VALUES ARE SANE AND SHOULD NEVER BE MODIFIED        #
# IF YOU DON'T KNOW THE DIFFERENCE BETWEEN SSH and RSA, OR CHMOD AND CHROOT #
# FOR THE LOVE OF GOD DO NOT CHANGE THE DEFAULT CONFIGURATION VALUES        #
# SERIOUSLY. THINGS WILL GET SCREWED UP IF YOU CHANGE THE DEFAULT VALUES!!  #
#                                                                           #
#############################################################################
# WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING   #
#############################################################################

# Configuration for autoupdate.sh
# server_update determines whenever if the linux server should update the
# package list and hit all of the repositories. Default value is true since this
# is a sane and reasonable setting.
server_update=true

# server_upgrade determines if the server should actually download the new
# updates, if there are any - and installs them automatically. This presents
# a very very minor risk - since the update may fail 1 times out of 1000 - and
# this would cause the script to break. However, the advantages of having an
# up to date security system outweighs this, and the default value is a sane
# one - so don't change it.
server_upgrade=true

# Configuration for dependencies.sh
# install_git determines if the dependencie git should be installed on the
# the server. Without git, most of the script would fail since it needs to use
# git to automatically download the maps and server configuration files form
# github. This represents a small risk as 1 out of a 1000 updates could fail
# but it's very minor and this value should not be changed.
install_git=true

# Configuration for usersetup.sh
# linux_users is a list of the usernames of users that are going to be added.
# By default, only the admin user and teamfortress user will be used - admin
# for full sudo access in administrating the server, and teamfortress as the
# unprivilleged user that is actually running the server. Don't REMOVE the
# users or else the script will break. If you must, you can add additional
# users to the list here - write them seperated by a space ' ' without quotes
# as seen below. However, DO NOT remove any users from the list - or the script
# will break.
linux_users=(admin teamfortress)

# determines which users should get full sudo access. For the love of god, don't
# add more users here then you will need to - only keep 1 or 2 sudo users if
# you must, and never put the teamfortress user here.
linux_sudo_users=(admin)

# Configuration for the sshsetup.sh
# The default ssh port number. Your server becomes a tiny bit more secure if you
# use a SSH number that's non standard (not 22), under 1024. Make sure it does
# not conflict with existing ports that are reserved. Usually 40 is a good
# choice - it's under 1024, and it's not assigned.
ssh_port_number=40

# Disables root login. This is important, as the root account should never be
# accessible over ssh. You don't need to change it. Actually, please don't
# change it - as it helps a bit with security.
ssh_root_login=false

# Allows a scary message to be displayed when a user tries to connect. There's
# no real need to disable it.
ssh_banner=true

# The actual scary message. Feel free to change it - but make sure it's not
# more then one line. If you want it to be multiple lines, open up the
# /etc/issue.net file using the command 'sudo nano /etc/issue.net' after you
# have finished the script - and change it manually yourselve.
ssh_banner_msg="Welcome to our SSH server. Authorized users only!"

# Disables password authentication on the server. THIS IS THE MOST IMPORTANT
# security measure that you will take, since you'd be using SSH keys. For the
# love of god, don't change this value.
ssh_password_auth=false

# Sets a lowered login grace time. There's not much point leaving the default
# value of 120 seconds since we'll be using ssh keys - so we'd be specifying a
# custom value instead - it improves security /slightly/. No need to change this
ssh_default_login_grace_time=false

# This is the custom value for login grace time. Once again, 20 seconds is more
# then enough, even if you have a hilariously slow connection. The value is
# extremely conservative. - I'd usually go for 10 seconds, but you might have
# a slow internet.
ssh_login_grace_time=20

# Only lets sudo users to log in. There's no need to change this, as it improves
# security at no cost at all. Once you login as the sudo user, simply do
# 'su teamfortress' to change to the other account.
ssh_limit_login_to_sudo=true

# Kicks idle SSH clients. If there's no activity on your part for 5 minutes, it
# automatically disconnects you. Another sane security measure - in case you
# accidently let your SSH logged on in the library or soemthing. No need to
# change this value as well.
ssh_kick_idle_clients=true

# iptables.sh configuration.
# Allows the firewall to let port 80 open. If you close this, you'd be screwing
# everyone over since that's the port the fastdl server uses. No need to change
# this, unless you really know what you are doing.
iptables_allow_http=true

# Turning this off would prevent players from connecting to the team fortress 2
# server. There's no need to change this to false either - since you need
# it to be open.
iptables_allow_tf2=true

# It's best to not use rcon, actually. So you really should not leave this on
# unless you really need it - as it presents a security risk.
iptables_allow_tf2_rcon=false

# Makes the iptable rules persistent after a restart. THIS IS IMPORTANT. If
# your server reboots without this, then all the firewalls would be wiped and
# before you know it you'd be getting a visit from the datacenter officials
# saying you're sending letters from the Nigerian prince and before you know
# it you'd be in a whole world of hurt. Leave it to true.
iptables_persistent=true

# fail2ban.sh configuration
# I'm tired at typing this out so just leave all of them as what they are
# and don't change it.
fail2ban_bantime=2592000
fail2ban_destemail="admin@localhost"
fail2ban_action="action_mwl"
fail2ban_install_dependencies=true

# Keep all of this to what they are and don't change it either, mister.
rkhunter_install_dependencies=true
rkhunter_destemail="admin@localhost"
rkhunter_disallow_root_ssh=true
rkhunter_addcron=true

# Definitely don't change these. What are you thinking, modifying my script? :P
./modules/checkroot.sh

./modules/autoupdate.sh $server_update $server_upgrade

./modules/dependencies.sh $install_git

./modules/usersetup.sh $linux_users $linux_sudo_users

./modules/ssh_setup.sh $ssh_port_number $ssh_root_login $ssh_banner $ssh_banner_msg $ssh_password_auth $ssh_default_login_grace_time $ssh_login_grace_time $ssh_limit_login_to_sudo $ssh_kick_idle_clients

./modules/iptables.sh $ssh_port_number $iptables_allow_http $iptables_allow_tf2 $iptables_allow_tf2_rcon $iptables_persistent

./modules/fail2ban.sh $ssh_port_number $fail2ban_bantime $fail2ban_destemail $fail2ban_action $fail2ban_install_dependencies

./modules/rkhunter.sh $rkhunter_install_dependencies $rkhunter_destemail $rkhunter_disallow_root_ssh $rkhunter_addcron

./modules/fastdl.sh
