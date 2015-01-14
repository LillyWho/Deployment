#!/bin/bash

# Greets operator
echo "Starting Deployment - the automated Dirsec server provisioning system"

# Checks if provisioning is ran under "gameserver" user
# GAMESERVER="gameserver"
# echo "Checking to see if script is running under seperate user..."
# if [ $USER = $GAMESERVER ]
# then
#     echo "Success! Script is running under gameserver user."
# else
#     echo "Warning, script is not running under seperate gameserver user!"
#     echo "Shutting down for your own safety..."
#     exit
# fi

# Declares download URLs
SERVERURL="https://github.com/Dirsec/Server/archive/master.zip"
MAPURL="https://github.com/Dirsec/Mapbase/archive/master.zip"

# Attempting to install prerequisites
echo "Attempting to install zip and unzip tools via apt-get"
apt-get -q update
apt-get -q install zip unzip
echo "Success! zip and unzip installed!"

# Creates server directory
echo "Attempting to create directory tf2server @ ~/"
mkdir ~/tf2server
cd ~/tf2server
echo "Success! directory ~/tf2server created!"

# Downloads server files from github
echo "Attempting to download server files from github repository"
wget -q $SERVERURL
unzip -v *.zip
echo "Success! Download and unzip successful!"

# Changes to map directory before downloading maps
echo "Attempting to change directory to ~/tf2server/tf2/tf/maps/"
cd ~/tf2server/tf2/tf/maps/
echo "Success! Direcotry has been changed!"

# Attempts to download maps from mapserver at github
wget -q $MAPURL
unzip -v *.zip
echo "Success! Download and unzip successful!"

# Cleans up and hands back to user
cd ~/tf2server
echo "Server deployment complete."
echo "In order to run server, execute ./tf.sh while in ~/tf2server direcotry"
echo "In order to update server, execute ./update.sh instead"
echo "Have fun!"

exit
