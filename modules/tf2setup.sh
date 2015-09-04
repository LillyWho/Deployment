#!/bin/bash

# TF2 Server Setup Script used on Linux Ubuntu 14.04 servers
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

# Start message
echo "Starting to install team fortress gameserver..."

# Installing dependencies
echo "Starting to install tf2 server dependencies"
apt-get --assume-yes install lib32gcc1 lib32z1 lib32ncurses5 lib32bz2-1.0

# Installs steamCMD to the tf2 user's home directory and extracts it
echo "Installing steamCMD to team fortress 2 user's home directory"
cd /home/teamfortress/
wget http://media.steampowered.com/installer/steamcmd_linux.tar.gz
tar zxf steamcmd_linux.tar.gz

# Creates steamcmd tf2_ds.txt script
echo "Creating steamcmd tf2_ds.txt script"
echo "login anonymous
force_install_dir ./tf2
app_update 232250
quit" > /home/teamfortress/tf2_ds.txt

# Creates an automatic updater script for TF2
echo "Creating tf.sh automatic updating script"
echo "#!/bin/sh
./steamcmd.sh +runscript tf2_ds.txt" > /home/teamfortress/update.sh
chmod 755 /home/teamfortress/update.sh

# Creates server startup script
echo "Creating server startup script with the following settings"
echo "#!/bin/sh
tf2/srcds_run -game tf +sv_pure 0 +randommap +maxplayers 24 -replay -steam_dir /home/teamfortress/ -steamcmd_script /home/teamfortress/tf2_ds.txt +sv_shutdown_timeout_minutes 360" > /home/teamfortress/tf.sh
cat /home/teamfortress/tf.sh
chmod 755 /home/teamfortress/tf.sh

# Downloads server files
echo "Downloading server files right now!"
chmod -R 777 /home/teamfortress/linux32
./update.sh

# Downloads server configuration files
echo "Cloning git configuration files from remote repository"
git clone https://github.com/Dirsec/Server.git /home/teamfortress/configuration

# Adds mapcycle
echo "Copying mapcycle.txt into proper location"
cp /home/teamfortress/configuration/cfg/mapcycle.txt /home/teamfortress/tf2/tf/cfg/mapcycle.txt

# Adds server configuration file
echo "Copying server configuration file into proper location"
cp /home/teamfortress/configuration/cfg/server.cfg /home/teamfortress/tf2/tf/cfg/server.cfg

# Adds replay configuration file
echo "Copying replay configuration file into proper location"
cp /home/teamfortress/configuration/cfg/replay.cfg /home/teamfortress/tf2/tf/cfg/replay.cfg

# Changes motd to something reputable
echo "Copying motd file into proper location"
cp /home/teamfortress/configuration/motd.txt /home/teamfortress/tf2/tf/motd.txt

# Adds addons folder
echo "Adding addons folder"
cp -r /home/teamfortress/configuration/addons /home/teamfortress/tf2/tf/addons

# Adds maps over by deleting all the other maps first
echo "Removing default maps"
rm -rf /home/teamfortress/tf2/tf/maps/*.bsp

# Changing fastDL directory
ipaddress=`dig +short myip.opendns.com @resolver1.opendns.com`
echo "Changing fastdl directory to local server instead of master"
sed -i "/sv_downloadurl \"http://www.dirsec.net/tf\"/c\sv_downloadurl $ipaddress\"\"" /home/teamfortress/tf2/tf/cfg/server.cfg

# Changing replay upload directory
echo "Changing replay upload directory to local server instead of master"
sed -i "/replay_local_fileserver_path/c\replay_local_fileserver_path \"/var/www/html/tf/replays\"" /home/teamfortress/tf2/tf/cfg/replay.cfg
sed -i "/replay_fileserver_host/c\replay_fileserver_host \"$ipaddress\"" /home/teamfortress/tf2/tf/cfg/replay.cfg

# Adds map over from fastdl and unzips everything
echo "Copying all maps from fastDL into map directory"
echo "WARNING: THIS WILL TAKE A LONG TIME"
echo "WARNING: THIS WILL TAKE A LONG TIME"
echo "WARNING: THIS WILL TAKE A LONG TIME"
echo "WARNING: THIS WILL TAKE A LONG TIME"
echo "WARNING: THIS WILL TAKE A LONG TIME"
echo "WARNING: THIS WILL TAKE A LONG TIME"
echo "Now you have to wait ;)"
cp -v /var/www/html/tf/maps/*.bsp.bz2 /home/teamfortress/tf2/tf/maps/

# Unzips compressed map files over.
echo "Unzipping bz2 map files in map repository"
echo "WARNING: THIS WILL TAKE A LONG TIME"
bzip2 -d --verbose /home/teamfortress/tf2/tf/maps/*.bsp.bz2

# Adds per-map configuration folder
echo "Adding per-map configuration folder into maps folder"
cp -r /home/teamfortress/configuration/maps/cfg /home/teamfortress/tf2/tf/maps/

# Changing recursively ownership back to teamfortress user
echo "Recursively changing ownership"
chown -R teamfortress:teamfortress /home/teamfortress/
chown -R teamfortress:teamfortress /var/www/html/tf/replays
