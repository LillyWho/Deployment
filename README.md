# Deployment ~ 
Automated deployment mechanism to setup Dirsec servers. 

## What is this?
This is a series of bash scripts that are used to deploy a Dirsec-styled Team Fortress 2 server on an Ubuntu 14.04 LTS machine. Essentially, it contains code and scripts that will automatically setup the server itself, secure and optimize it, install SteamCMD and the TF2 server software. Beyond that, it will automatically download custom configuration from github.com/Dirsec, and the custom map collection.

### How do I use this?
In order to setup a dirsec-styled server, you first need to purchase a server machine. Note the difference in terminology - the server I mention here is a physical piece of hardware on a rack, not the TF2 server. 

### Brief walkthrough
Usually, buying a server outright on a rack is very expensive. You need datacenter space to pay for the cooling, connection, and security. 

That's why Dirsec runs on a DigitalOcean VPS. It's called a VPS because it's a Virtual Private Server. Typically, you rent one of these, and pay a certain amount of money per month. Usually, VPS'es are weak in CPU, and do not make good gameserver hosts. That's why you can only run one instance of Dirsec on a server. We've aggressively optimized aspects of Dirsec to make it easy to run on cheap hosts.

Once you have a server, you need to install a clean copy of Ubuntu. Specifically, you need Ubuntu 14.04 LTS, which is a recent long term support edition of Ubuntu. Ubuntu is a linux distribution, otherwise known as distro. We'll get more into this later. Afterthat, you must download this repository, and run it as root. At first, the script will secure and lock down the server, and implement most recommanded security guidelines. Afterwards, it will contact github and download the custom map files, process them, and create the fastDL and replay servers.

This will take a long time. Once it's done, Dirsec would be yours again.

# Installation Guide
Dirsec is designed to be very easy to use and setup. But you might be unfamiliar with basic aspects of system management and linux server administration. I was, as well. Therefore I'll give you a very detailed guide and walkthrough on how to do it. This tutorial is aimed at inexperienced computer users, so I'll be very pedantic throughout and explain everything very clearly. 

Experienced sysadmins, all you have to do is to spinup a blank Ubuntu 14.04 server, clone the repository, and run `deploy.sh` as root.

## Part 1: Creating a DigitalOcean VPS
You'll need a Linux Virtual Private Server. At Dirsec, we use a company called Digitalocean.com. They are very reputable, and offer cheap but high quality servers. 

###Visit Digitalocean.com
[Sign up for an account](https://cloud.digitalocean.com/registrations/new). You know what to do. Put your credit card in at the payment stage, and load 20 US Dollars into your account. Once that's done, you'll need to deploy a server.

###Create Droplet
VPS'es at Digitalocean are called Droplets. Click on the Create Droplet button at the upper left section of your control panel.

###Name Droplet
Once you do that, you'll be confronted with many settings. First, give your droplet a name. This name is the name of the machine, and usually you would want it to be short and sweet. I use [Tirosh'es Mnenomic List](http://web.archive.org/web/20091003023412/http://tothink.com/mnemonic/wordlist.txt
) as the naming convention, many other sysadmins do the same.

###Droplet Size
After that, you should select the size of the droplet. The code that powers Dirsec is aggressively optimized, so it performs well on the 10 dollars per month tier. Do not use the 5 dollars per month, as it offers too little disk space.

###Choose Region
Choose the region that's the closest to you. A closer region means less latency, or lower ping. Usually, since Dirsec is hosted in Europe, our server is in the Amsterdam region

###Select Image
This part is important. Dirsec is only tested on a Ubuntu 14.04 LTS x64 image. That means the base distro must be Ubuntu 14.04, and it has to be 64 bit. This should be selected via default already, but make sure it's right.

###Other Settings
Turn on private networking, but leave everything else (including IPv6) off for now. Once this is all done, doublecheck your settings and hit the Create Droplet button at the bottom.

## Part 2. Access Server
You will now have to SSH into the server. Digitalocean itself has a fantastic tutorial about this, as well about navigating the command line environment of Linux servers.

[Read about it here.](https://www.digitalocean.com/community/tutorials/how-to-connect-to-your-droplet-with-ssh)

The linux command line environment can be a strange and scary place. Therefore, it's recommanded to read this tutorial on Linux Fundementals first, also from Digitalocean.

[Read about it here.](https://www.digitalocean.com/community/tutorials/an-introduction-to-the-linux-terminal)

Basically, you would open your terminal and write
```
ssh root@your-ip-address
```

Of course, replace `your-ip-address` with the actual IP of your server. An IP address looks like `192.82.83.200`, or `93.20.81.100`

## Part 3. Run Deployment Script
Now that you are in the server, you have to run the deployment script. 

### Note on Server Security
Usually, this is the part where you'll take time to secure the server, change the password, add non-root users, and configure SSH. Server security is **very important**, as servers are high value targets for hackers. If your server is compromised, some **very bad things will happen**. Your IP address could be blacklisted for sending spam and mailware, and you could lose a valuable piece of IT infrastructure.

Therefore, server security is no joke. You definitely should read up about it on DigitalOcean. They have a fantastic set of tutorials for new sysadmins like you!

However, you probably don't know enough about it now. That's okay. Dirsec's Deployment script will automatically lock down and secure your server using reasonnable settings, and unless you do something exceptionally stupid, it will be fine.

### Running the Script
You should now be logged in as the root user. You need to run `deploy.sh` as root. **Warning:** Ensure you have a good and stable internet connection when you do this. If you run the script, and your connection gets cut off halfway, you need to wipe the server and to redo the installation process.

Type this:

`./deploy.sh`

Now sit back, and don't touch the keyboard. This script will take a long time, as it will do many things.

## Part 4. Post Setup Tasks
(to be written)

Somepoint, the script will tell you that it's done doing things. At this point, your copy of Dirsec is complete! All you need to do now is to run it.

Usually, you would do `./tf.sh` - and it would run automatically. If you need to update Dirsec, you would do `./update.sh`. However, if you run `./tf.sh` right now, it will use your current terminal screen. That means you can't log off. If you log off, your instance would be killed, and the server would stop.

Needless to say, this isn't optimal. That's why you should install `screen`, and use a virtual terminal to run dirsec. This will keep the thing running even when you are logged out of your server, and it will keep going effectively forever.

Install screen by doing
```
apt-get install screen
```

Say `yes`, and it will install it for you.

You will have to read a bit about how to use `screen`, but DigitalOcean has tutorials about it :)

Enjoy!
