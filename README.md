# Deployment ~ 
Automated deployment mechanism to setup Dirsec servers. 

## What is this?
This is a series of bash scripts that are used to deploy a Dirsec-styled Team Fortress 2 server on an Ubuntu 14.04 LTS machine. Essentially, it contains code and scripts that will automatically setup the server itself, secure and optimize it, install SteamCMD and the TF2 server software. Beyond that, it will automatically download custom configuration from github.com/Dirsec, and the custom map collection.

## How do I use this?
In order to setup a dirsec-styled server, you first need to purchase a server machine. Note the difference in terminology - the server I mention here is a physical piece of hardware on a rack, not the TF2 server. 

## Brief walkthrough
Usually, buying a server outright on a rack is very expensive. You need datacenter space to pay for the cooling, connection, and security. 

That's why Dirsec runs on a DigitalOcean VPS. It's called a VPS because it's a Virtual Private Server. Typically, you rent one of these, and pay a certain amount of money per month. Usually, VPS'es are weak in CPU, and do not make good gameserver hosts. That's why you can only run one instance of Dirsec on a server. We've aggressively optimized aspects of Dirsec to make it easy to run on cheap hosts.

Once you have a server, you need to install a clean copy of Ubuntu. Specifically, you need Ubuntu 14.04 LTS, which is a recent long term support edition of Ubuntu. Ubuntu is a linux distribution, otherwise known as distro. We'll get more into this later. Afterthat, you must download this repository, and run it as root. At first, the script will secure and lock down the server, and implement most recommanded security guidelines. Afterwards, it will contact github and download the custom map files, process them, and create the fastDL and replay servers.

This will take a long time. Once it's done, Dirsec would be yours again.

# Installation Guide
(To be written)
