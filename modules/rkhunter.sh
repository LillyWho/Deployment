#!/bin/bash

# rkhunter setup script used on Linux Ubuntu 14.04 servers
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

# Gets the latest rkhunter files from upstream and installs it
echo "Downloading rkhunter files from upstream"
wget http://sourceforge.net/projects/rkhunter/files/latest/download?source=files

# Unzips newly downloaded files
echo "Unzipping downloaded files"
tar xzvf download*

# Deletes zipped version
echo "Cleaning up after download"
rm download*

# Starts isntallation
echo "Starting rkhunter installation"
cd rkhunter*
./installer.sh --layout /usr --install

# Installs dependencies if required
echo "Downloading rkhunter dependencies"
apt-get --assume-yes install binutils libreadline5 libruby ruby ssl-cert unhide.rb mailutils

# Begins configuration
echo "Starting configuration for rkhunter"
rkhunter --versioncheck
rkhunter --update
rkhunter --propupd

# Start editing rkhunter configuration files to agree with Ubuntu.
echo "Editing rkhunter configuration options"
sed -i "/MAIL-ON-WARNING=/c\MAIL-ON-WARNING=\"$1\"" /etc/rkhunter.conf

# Scriptwhitelists
echo "Starting to whitelist scripts via appending SCRIPTWHITELIST clause"
echo 'SCRIPTWHITELIST="/usr/sbin/adduser"' >> /etc/rkhunter.conf
echo 'SCRIPTWHITELIST="/usr/bin/ldd"' >> /etc/rkhunter.conf
echo 'SCRIPTWHITELIST="/usr/bin/unhide.rb"' >> /etc/rkhunter.conf
echo 'SCRIPTWHITELIST="/bin/which"' >> /etc/rkhunter.conf

# Dev file allowances
echo "Starting to whitelist files in the /dev directory"
echo 'ALLOWDEVFILE="/dev/.udev/rules.d/root.rules"' >> /etc/rkhunter.conf

echo "Allow hidden directory in dev"
echo 'ALLOWHIDDENDIR="/dev/.udev"' >> /etc/rkhunter.conf

echo "Allow other hidden files in dev"
echo 'ALLOWHIDDENFILE="/dev/.blkid.tab"' >> /etc/rkhunter.conf
echo 'ALLOWHIDDENFILE="/dev/.blkid.tab.old"' >> /etc/rkhunter.conf
echo 'ALLOWHIDDENFILE="/dev/.initramfs"' >> /etc/rkhunter.conf

# Explicitly disallow SSH root login
echo "Explicitly disallow SSH root login"
echo 'ALLOW_SSH_ROOT_USER=no' >> /etc/rkhunter.conf

# Checks configuration against itself and updates signatures
echo "Rkhunter configuration complete. Checking configuration..."
rkhunter -C
rkhunter --propupd

# Redoing test run
echo "Starting next test run"
sudo sudo rkhunter -c --enable all --disable none --rwo --cronjob
echo "Rkhunter configuration complete. Successfully installed."

# add cronjob
crontab -l | { cat; echo "* 2 * * * rkhunter --cronjob --update --quiet"; } | crontab -
