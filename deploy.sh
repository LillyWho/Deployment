#!/bin/bash

# Initial Server Setup. Automated Edition by Shen Zhou Hong
# Created to democratcise the provisioning of Dirsec-styled servers
# Copyright GPLv2 2015.

# This is merely a simple welcome message that pronounces the start of the setup
# script. Over the course of this script, we aim to not only implement a sound
# security policy, but also setup apache2 virtual hosts, provision the website
# and fastDL server for team fortress, but also explore automated setup options
# using git for the team fortress 2 server configuration itself - not to mention
# creating the basic outlines for the future minecraft server
#
# We aim this script to not only be a vital install component of the Katyusha
# server, but also as documentation for our actions. Even if the server goes
# up in flame, we should be able to recover completely using only this script.
# That being said, the problem using this would be the fact taht this is no
# longer generalized enough to allow setting up other dirsec-styled servers -
# however, rest assured that we will fix that later with the release of a new
# script
echo "Starting Automated Initial Server Setup"

# Checks if the script is run as root, and other actions before commencement
# The first task of the script is to determine if it is ran as root. We will be
# changing some fundemental system configurations (such as the ssh daemon), not
# to mention installing various files and dependencies - therefore if we don't
# run this as root, there will be no way anything can proccede.
function preliminaries () {

    # Here, we start with an if/else block where we check using the user id to
    # see if the script is ran as root. The user id of the root user is 1 -
    # therefore if it is not ran as root, we exit the script.
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root - retry with 'su root' or 'sudo'"

        # Here, we call an exit code of 1 which terminates the script. In bash,
        # a regular exit condition would be simply exit - or exit 0. Bascially,
        # any non-zero exit condition signifies an problem with the script.
        # In this case, the problem is that we are not running this as root.
        exit 1
    fi

    # Before we begin, it is essential for the server to update itself. First
    # we hit the package lists using apt-get --assume-yes update. Note that sudo
    # is not required due to the fact that we are already running as root. Also,
    # we are passing apt-get the --assume-yes argument, to avoid the interactive
    # confirmation that typically comes with apt-get. Next, we simply upgrade
    # everything using apt-get --assume-yes upgrade. Note that this presents a
    # risk in itself, because automatic upgrades may fail - but we will take
    # this since we are assumming this is ran on a clean Ubuntu 14.04 LTS system
    apt-get --assume-yes update
    apt-get --assume-yes upgrade

    # Before we procced any further, git would be installed here since we would
    # be needing to use it in order to not only provision the content for the
    # website, but also to download essential configuration files.
    apt-get --assume-yes install git
}

# The first thing we must accomplish is to create the users. This is not only
# important for our security policy, but also essential to maintain the system
# as we will be disabling root login later on. By having seperate users running
# the team fortress 2 and minecraft servers, this not only improves process
# isolation - but also allows us to organise the files better.
function user_setup () {
    ›
    # Here is the list of users to add to the server. A brief summery below:
    #
    # +----------------------------------------------------------------+
    # | Username     | Function                                        |
    # +--------------+-------------------------------------------------+
    # | peterpacz1   | Main admin user. I'm the creator of the script! |
    # | morgenman    | Second admin user. Also has sudo access.        |
    # | teamfortress | Used to run the TF2 server. Unprivileged        |
    # | minecraft    | Used to run the minecraft server. Unprivileged  |
    # +--------------+-------------------------------------------------+
    #
    # Here the users are added using a for loop - by declaring $i as the
    # variable that holds the usernames (which are actually strings), we are not
    # only making the code far more concise - but also making it easier to add
    # more people to the users list.
    #
    for i in peterpacz1 morgenman teamfortress minecraft; do

        # The users are actually added using the Unix useradd command instead of
        # adduser. Adduser requires interactivity, which we can't support since
        # this is a bash script. Therefore, we are using the older varient.
        # However, with this there are some problems. We have to explicitly
        # give the shell as -s /bin/bash, but also tell it to add the user
        # into the same group as it's username, and create a home directory -
        # things that adduser does for us automatically already.
        echo "Adding $i user to system..."
        useradd $i -s /bin/bash -m -U

        # Here, we are setting a password for the users that we are adding.
        # First, the user is prompted for a password securely using the read -s
        # command, which does not echo output.
        # Next, the password is passed along with the username to chpasswd in
        # this syntax:
        #
        #      chpasswd username:password
        #
        # Without setting the passwords, it would be impossible to login through
        # SSH (not that we will do that, since we are going to disable SSH
        # login), but also impossible to su (changeuser) into them as well.
        echo -n "Enter $i's password: "
        read -s password
        echo "Changing $i password..."
        echo "$i:$password" | chpasswd

    # We are running all of this in a for loop, to not have to write these
    # commands more then once. Here, we are merely using the done keyword to
    # mark the end of the loop.
    done

    # Rather then allowing all users to login through SSH, we would be creating
    # a special group of users called ssh-users that would be allowed to login
    # to the server over SSH. This is important since it will disallow
    # unprivilleged users from SSH login. We could just allow all users in the
    # sudo group (admins) to login, but once a while we might want someone who
    # is not admin, but still needs login over SSH. Right now, we will have
    # these two groups:
    #
    # +------------+-----------------------+----------------------------------+
    # | Group Name |         Users         |            Function              |
    # +------------+-----------------------+----------------------------------+
    # | sudo       | peterpacz1, morgenman | Allowed to use the sudo command. |
    # | ssh-users  | peterpacz1, morgenman | Allowed to login via ssh         |
    # +------------+-----------------------+----------------------------------+
    #
    # Here we are first adding the ssh-users group. The sudo group already
    # exists by default.
    groupadd ssh-users

    # This segment of the script that actually adds the users to each group.
    # Once again, using loops.
    for i in peterpacz1 morgenman; do

        # We are using the adduser command here instead of usermod or useradd.
        # This is because despite it's interactivity, adduser supports directly
        # adding a user to a group without interactive keypresses.
        # Adds the specified user to the sudo group
        echo "Adding $i user to sudo group..."
        adduser $i sudo

        # Adds the specified user to the sudo group
        echo "Adding $i user to ssh-users group..."
        adduser $i ssh-users
    done
}

# The function is used to setup the SSH daemon and configure it's main
# configuration file located at /etc/ssh/sshd_config. It's important to have a
# sound SSH policy in order to secure one's server - SSH is the first attack
# vector that the majority of hackers would use, since it allows one to easily
# gain direct control of the server if impropery configured.
function ssh_setup () {
    # Change SSH default port
    echo "Change SSH port number to:"
    read portnumber
    sed -i "/Port 22/c\Port $portnumber" /etc/ssh/sshd_config

    # Do not allow root login via ssh
    echo "Disabling root logins via SSH"
    sed -i '/PermitRootLogin yes/c\PermitRootLogin no' /etc/ssh/sshd_config

    # Activate SSH banner
    echo "Activating SSH banner"
    sed -i '/#Banner \/etc\/issue.net/c\Banner \/etc\/issue.net' /etc/ssh/sshd_config
    echo "######################################
Welcome to Dirsec.net ssh server.

All connections are actively monitored
and logged, with login attempts and IP
sent to the server administrator.

This service is RESTRICTED and limited
to AUTHORIZED users only. Unauthorized
access will be PROSECUTED.

######################################
DISCONNECT IMMEDIATELY IF YOU ARE NOT
AN AUTHORIZED USER!!!
######################################" > /etc/issue.net

    # Disable Password Authentication
    echo "Disabling password authentication"
    sed -i '/#PasswordAuthentication yes/c\PasswordAuthentication no' /etc/ssh/sshd_config

    # Create lower LoginGraceTime
    echo "Lowering LoginGraceTime"
    sed -i '/LoginGraceTime/c\LoginGraceTime 20' /etc/ssh/sshd_config

    # Append AllowGroups clause to the end of the file
    echo "AllowGroups ssh-users" >> /etc/ssh/sshd_config

    # Append automatic idle client kicker to the end of the file
    echo "ClientAliveInterval 300" >> /etc/ssh/sshd_config
    echo "ClientAliveCountMax 0" >> /etc/ssh/sshd_config

    # Restart SSH daemon when complete
    echo "SSH Configuration complete. Restarting."
    service ssh restart
}

# SSH keys are superior over password logins due to the fact that they are not
# only vastly longer, but also offers a cryptographically sane form of
# authentication. We will be adding the SSH-keys of the client computers to each
# newly-created admin user in order to let them login.
function sshkeys_setup () {
    # Creates SSH folders and authorized_keys
    echo "Starting ssh-keys setup"
    for i in peterpacz1 morgenman; do

        # Creates the SSH dotfolder in the user's home directory.
        echo "Creating .ssh folder for $i..."
        mkdir /home/$i/.ssh/

        # Case switch statement to add ssh keys (different key depending on the)
        # username of the admin.
        case "$i" in
            peterpacz1)
                echo "Adding $i's public key..."
                echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDn8BmfYaLLmKmvbrd0IrhWJ4HZ2Mka2iVmRsAHqn/z6BYKsn+rMLdmo4sOF/SI3Cnn31GVSY2CGYunSnQyNX6yDcDVqXuPs2Z93Q/93ioRBPlzeOs1glh+3RJAtzH/YY85o1AJoGGPmjA5lxBSOUxTmyPdl1JHA5uZ3w5TOrxYgBe+higDNA3y8jWqJJWcEg6o8hrQsfgoYXxfO7/p+LJYqEMbvHE2FyqMj36p4hNtVKdQMnf7SgLK4B2hWHNQ1T6y2AC9hDQsX7AOwsTW3mINolp4Epi0LfAB5F6jzgnr/WH7mPUZIL23BW7sxUdg5YzlbwDXbcEBLqIt2KrdKI/R peterpacz1@bogon" >> /home/$i/.ssh/authorized_keys
                ;;
            morgenman)
                echo "Adding $i's public key..."
                echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDuRWU4BD7pYImfdC00BsO33/GeZ3AJt197jEFUtpC6T4w8QRua25W1vZHcAw7mHfRHuymbGzJbuLBKXEKSJwpOqahDEcA2SpsyYNDiKurcKsNU8QQsYsGHG7UYwdP42bUIRrOWpvKeLMqSqFD6F3MdtRIPq/QxUQ0WohUHO9qlJ6Aq4CFv5ZiiXtXeTTRP+hhuXzH0NkBGORq8F3EQ3d9Jns0V4g41LXHRRM6T08cI5El0RUNA7K88A0H6lCfVE80OBOXccmRPlvkEiu2mgWsofhnnnGpaLLEke2i3XtyHbL5FmkBQvS86w8YgTxjA4hgVU0mOdVU6Xfg2HJGXqYLF koru@koru-700Z3C-700Z5C" >> /home/$i/.ssh/authorized_keys
                ;;
            *)
                echo "An error has occurred with the number of users and ssh keys"
                exit 1
                ;;
        esac

    done
}

# Configures basic iptables settings and installs persistant iptables as well.
# It is important to configure a set of sane iptables rules because it is often
# the first line of defense against a network intrusion. In our iptables setup,
# we only open the ports that we need and have a default deny rule for all of
# the other ports.
function iptables_setup () {
    # Starts configuring iptables and allows current connections
    echo "Allowing all currently established connections"
    iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

    # Opens SSH non-default port number
    echo "Allowing non-default SSH port"
    iptables -A INPUT -p tcp --dport $portnumber -j ACCEPT

    # Opens webserver port 80
    echo "Allowing default HTTP webserver port"
    iptables -A INPUT -p tcp --dport 80 -j ACCEPT

    # Opens minecraft server port 25565
    echo "Allowing default minecraft server port"
    iptables -A INPUT -p tcp --dport 25565 -j ACCEPT

    # Opens Team Fortress 2 main connection port
    echo "Allowing team fortress 2 main port"
    iptables -A INPUT -p udp --dport 27015 -j ACCEPT

    # Opens Team Fortress 2 rcon port
    echo "Allowing rcon team fortress 2 port"
    iptables -A INPUT -p tcp --dport 27015 -j ACCEPT

    # Allows loopback devices
    echo "Allowingall loopback devices"
    iptables -I INPUT 1 -i lo -j ACCEPT

    # Sets default drop rule for INPUT chain
    echo "Setting default drop policy for iptables"
    iptables -P INPUT DROP

    # Lists all rules
    echo "Listing all iptables rules"
    iptables -L --line-numbers

    # Installing iptables persistant to save rules
    apt-get --assume-yes install iptables-persistent
}

# Installs the fail2ban dynamic firewall modifier and configures it
function fail2ban_setup () {
    # Installs fail2ban
    apt-get --assume-yes install fail2ban

    # Copys configuration file over
    cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

    # Lengthening bantime to 30 days
    echo "Setting bantime to 30 days (2592000 seconds)"
    sed -i '/bantime  = 600/c\bantime  = 2592000' /etc/fail2ban/jail.local

    # changing destemail to all sudo-enabled admins
    echo "Changing destemail to include peterpacz1 and morgenman"
    sed -i '/destemail = root@localhost/c\destemail = peterpacz@localhost, morgenman@localhost' /etc/fail2ban/jail.local

    # Allows detailed mail reports to be emailed after banning
    echo "Changing action to include the mailing of logs"
    sed -i '/action = %(action_)s/c\action = %(action_mwl)s' /etc/fail2ban/jail.local


    # Changes so that port number for SSH is set to non-default port
    echo "Setting SSH port number on Fail2ban to the non default port"
    # Note that this sed uses " " because doublequtoes expand variables

    # Installs all the rest of the parts and pieces
    echo "Installing sendmail and iptables-persistent before restarting service"
    apt-get --assume-yes install sendmail iptables-persistent

    # Restarting fail2ban service
    service fail2ban stop
    service fail2ban start
}

# Installs rkhunter and automatically configures it based on known-good values
function rkhunter_setup () {

    # Gets the latest rkhunter files from upstream and installs it
    echo "Downloading rkhunter files from upstream"
    wget http://sourceforge.net/projects/rkhunter/files/latest/download?source=files

    echo "Unzipping downloaded files"
    tar xzvf download*

    echo "Cleaning up after download"
    rm download*

    echo "Starting rkhunter installation"
    cd rkhunter*
    ./installer.sh --layout /usr --install

    echo "Downloading rkhunter dependencies"
    apt-get --assume-yes install binutils libreadline5 libruby ruby ssl-cert unhide.rb mailutils

    # Begins configuration with an initial test run
    echo "Starting rkhunter initial test runs"
    rkhunter --versioncheck
    rkhunter --update
    rkhunter --propupd

    echo "Starting test run now"
    sudo sudo rkhunter -c --enable all --disable none --rwo --cronjob

    # Start editing rkhunter configuration files to agree with Ubuntu.
    echo "Editing rkhunter configuration options"
    sed -i '/MAIL-ON-WARNING=/c\MAIL-ON-WARNING="peterpacz1@localhost morgenman@localhost"' /etc/rkhunter.conf

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

    echo "Allow other hidden files in dev" >> /etc/rkhunter.conf
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
}

# Creates and populates essential root cronjobs for apt-get and rkhunter
function cronjob_setup () {

    # Automatic refresh of package list every day at 1 AM in the morning
    crontab -l | { cat; echo "* 1 * * * apt-get update"; } | crontab -


    # Automatic run of rkhunter and updates every day at 2 AM in the morning
    crontab -l | { cat; echo "* 2 * * * rkhunter --cronjob --update --quiet"; } | crontab -
}

# Installs apache and configures apache virtual hosts
function apache_setup () {
    # Installs apache from apt-get
    echo "Downloading and installing apache2 for apache virtual hosts"
    apt-get --assume-yes install apache2

    # Creates directories for each domain
    for i in dirsec.net hong.io morgenman.me; do

        # Makes web directory
        echo "Making web directory for $i"
        mkdir -p /var/www/$i

        # Makes subdomains if needed
        case "$i" in
            dirsec.net)

                # Adding subdomains
                echo "Adding subdomains in apache for $i..."
                # Subdomains list
                for i in public_html; do

                    # Creates the folder for the specified subdomain
                    echo "Adding subdomain $i right now..."
                    mkdir -p /var/www/dirsec.net/$i

                    # Adds content automatically to each subdomain, either from
                    # template or via checking out a github repository
                    case "$i" in
                        public_html)
                            echo "Provisoning content for $i..."

                            # Adds default placeholder index.html file
                            # echo "<!DOCTYPE html>
                            # <html>
                            #     <head>
                            #         <meta charset="UTF-8">
                            #         <title>$i</title>
                            #     </head>
                            #     <body>
                            #         <h1> $i </h1>
                            #         <p> Congratulations, apache virtualhosts is working <p>
                            #         <p> Please make sure to replace this template later <p>
                            #     </body>
                            # </html>" > /var/www/dirsec.net/$i/index.html

                            # Takes website content from git
                            git clone https://github.com/Dirsec/Frontpage.git /var/www/dirsec.net/$i

                            # Provisions maps from git onto website
                            git clone https://github.com/Dirsec/Mapbase.git /var/www/dirsec.net/$i/tf/maps


                        ;;

                        *)
                            echo "Error - file provisioning broke"
                            exit 1
                        ;;
                    esac

                    # Starts copying virtualhost files for each subdomain
                    case "$i" in
                        public_html)
                            # Copys the virtualhost file master template for this domain/subdomain
                            cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/dirsec.net.conf

                            # Starts configuring the virtualhost file
                            echo "Starting to configure virtualhost file"
                            sed -i '/ServerAdmin webmaster@localhost/c\ServerAdmin hong.shenzhou@gmail.com' /etc/apache2/sites-available/dirsec.net.conf
                            sed -i '/DocumentRoot \/var\/www\/html/c\DocumentRoot \/var\/www\/dirsec.net\/public_html' /etc/apache2/sites-available/dirsec.net.conf
                            sed -i '/#ServerName www.example.com/c\ServerName dirsec.net' /etc/apache2/sites-available/dirsec.net.conf
                            sed -i '10iServerAlias www.dirsec.net' /etc/apache2/sites-available/dirsec.net.conf

                            # Enabling configuration file
                            a2ensite dirsec.net.conf
                        ;;

                        *)
                            # If everything breaks
                            echo "Error - virtualhost file setup broke"
                            exit 1
                        ;;
                    esac
                done

                # Changing ownership of directories
                chown -R peterpacz1:peterpacz1 /var/www/dirsec.net/
                ;;

            hong.io)
                echo "Adding subdomains in apache for $i..."
                # Subdomains list
                for i in public_html shenzhou news; do

                    # Creates the folder for the specified subdomain
                    echo "Adding subdomain $i right now..."
                    mkdir -p /var/www/hong.io/$i

                    # Adds content automatically to each subdomain, either from
                    # template or via checking out a github repository
                    case "$i" in
                        public_html)
                            echo "Provisoning content for $i..."
                            echo "<!DOCTYPE html>
                            <html>
                                <head>
                                    <meta charset="UTF-8">
                                    <title>$i</title>
                                </head>
                                <body>
                                    <h1> $i </h1>
                                    <p> Congratulations, apache virtualhosts is working <p>
                                    <p> Please make sure to replace this template later <p>
                                </body>
                            </html>" > /var/www/hong.io/$i/index.html
                        ;;

                        shenzhou)
                            echo "Provisoning content for $i..."
                            echo "<!DOCTYPE html>
                            <html>
                                <head>
                                    <meta charset="UTF-8">
                                    <title>$i</title>
                                </head>
                                <body>
                                    <h1> $i </h1>
                                    <p> Congratulations, apache virtualhosts is working <p>
                                    <p> Please make sure to replace this template later <p>
                                </body>
                            </html>" > /var/www/hong.io/$i/index.html
                        ;;

                        news)
                            echo "Provisoning content for $i..."
                            echo "<!DOCTYPE html>
                            <html>
                                <head>
                                    <meta charset="UTF-8">
                                    <title>$i</title>
                                </head>
                                <body>
                                    <h1> $i </h1>
                                    <p> Congratulations, apache virtualhosts is working <p>
                                    <p> Please make sure to replace this template later <p>
                                </body>
                            </html>" > /var/www/hong.io/$i/index.html
                        ;;

                        *)
                            echo "Error - file provisoning broke"
                            exit 1
                        ;;
                    esac

                    # Starts copying virtualhost files for each subdomain
                    case "$i" in
                        public_html)
                            # Copys the virtualhost file master template for this domain/subdomain
                            cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/hong.io.conf

                            # Starts configuring the virtualhost file
                            echo "Starting to configure virtualhost file"
                            sed -i '/ServerAdmin webmaster@localhost/c\ServerAdmin hong.shenzhou@gmail.com' /etc/apache2/sites-available/hong.io.conf
                            sed -i '/DocumentRoot \/var\/www\/html/c\DocumentRoot \/var\/www\/hong.io\/public_html' /etc/apache2/sites-available/hong.io.conf
                            sed -i "/#ServerName www.example.com/c\ServerName $i.hong.io" /etc/apache2/sites-available/hong.io.conf
                            sed -i '10iServerAlias www.hong.io' /etc/apache2/sites-available/hong.io.conf

                            # Enabling configuration file
                            a2ensite hong.io.conf
                        ;;

                        shenzhou)
                            # Copys the virtualhost file master template for this domain/subdomain
                            cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/$i.hong.io.conf

                            # Starts configuring the virtualhost file
                            echo "Starting to configure virtualhost file"
                            sed -i '/ServerAdmin webmaster@localhost/c\ServerAdmin hong.shenzhou@gmail.com' /etc/apache2/sites-available/$i.hong.io.conf
                            sed -i "/DocumentRoot \/var\/www\/html/c\DocumentRoot \/var\/www\/hong.io\/$i" /etc/apache2/sites-available/$i.hong.io.conf
                            sed -i "/#ServerName www.example.com/c\ServerName $i.hong.io" /etc/apache2/sites-available/$i.hong.io.conf
                            # sed -i '10iServerAlias www.hong.io' /etc/apache2/sites-available/$i.hong.io.conf

                            # Enabling configuration file
                            a2ensite $i.hong.io.conf
                        ;;

                        news)
                            # Copys the virtualhost file master template for this domain/subdomain
                            cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/$i.hong.io.conf

                            # Starts configuring the virtualhost file
                            echo "Starting to configure virtualhost file"
                            sed -i '/ServerAdmin webmaster@localhost/c\ServerAdmin hong.shenzhou@gmail.com' /etc/apache2/sites-available/$i.hong.io.conf
                            sed -i "/DocumentRoot \/var\/www\/html/c\DocumentRoot \/var\/www\/hong.io\/$i" /etc/apache2/sites-available/$i.hong.io.conf
                            sed -i "/#ServerName www.example.com/c\ServerName $i.hong.io" /etc/apache2/sites-available/$i.hong.io.conf
                            # sed -i '10iServerAlias www.hong.io' /etc/apache2/sites-available/$i.hong.io.conf

                            # Enabling configuration file
                            a2ensite $i.hong.io.conf
                        ;;

                        *)
                            # If everything breaks
                            echo "Error - virtualhost file setup broke"
                            exit 1
                        ;;
                    esac
                done

                # Changing ownership of directories
                chown -R peterpacz1:peterpacz1 /var/www/hong.io/
                ;;

            morgenman.me)
                echo "Adding subdomains in apache for $i..."
                # Subdoomains list
                for i in public_html; do

                    # Creates the folder for the specified subdomain
                    echo "Adding subdomain $i right now..."
                    mkdir -p /var/www/morgenman.me/$i

                    # Adds content automatically to each subdomain, either from
                    # template or via checking out a github repository
                    case "$i" in
                        public_html)
                            echo "Provisoning content for $i..."
                            echo "<!DOCTYPE html>
                            <html>
                                <head>
                                    <meta charset="UTF-8">
                                    <title>$i</title>
                                </head>
                                <body>
                                    <h1> $i </h1>
                                    <p> Congratulations, apache virtualhosts is working <p>
                                    <p> Please make sure to replace this template later <p>
                                </body>
                            </html>" > /var/www/morgenman.me/$i/index.html
                        ;;

                        *)
                            echo "Error - file provisioning broke"
                            exit 1
                        ;;
                    esac

                    # Starts copying virtualhost files for each subdomain
                    case "$i" in
                        public_html)
                            # Copys the virtualhost file master template for this domain/subdomain
                            cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/morgenman.me.conf

                            # Starts configuring the virtualhost file
                            echo "Starting to configure virtualhost file"
                            sed -i '/ServerAdmin webmaster@localhost/c\ServerAdmin morgenman@gmail.com' /etc/apache2/sites-available/morgenman.me.conf
                            sed -i "/DocumentRoot \/var\/www\/html/c\DocumentRoot \/var\/www\/morgenman.me\/$i" /etc/apache2/sites-available/morgenman.me.conf
                            sed -i "/#ServerName www.example.com/c\ServerName morgenman.me" /etc/apache2/sites-available/morgenman.me.conf
                            sed -i '10iServerAlias www.morgenman.me' /etc/apache2/sites-available/morgenman.me.conf

                            # Enabling configuration file
                            a2ensite morgenman.me.conf
                        ;;

                        *)
                            # If everything breaks
                            echo "Error - virtualhost file setup broke"
                            exit 1
                        ;;
                    esac
                done

                # Changing ownership of directories
                chown -R morgenman:morgenman /var/www/morgenman.me/
                ;;

            *)
                # Something screwed up
                echo "An error has occured with adding domains."
                exit 1
                ;;
        esac

        # Restarting apache2 after setup is complete
        echo "Apache2 setup complete. Restarting..."
        service apache2 restart
    done
}

# Automatically installs java, and configures a vanilla minecraft server
function minecraft_setup () {
    # Start message
    echo "Starting to install minecraft gameserver..."

    # Installing java
    apt-get --assume-yes install default-jdk

    # Installs screen
    apt-get --assume-yes install screen

    # Installs minecraft server
    cd /home/minecraft/
    wget -o minecraft.jar https://s3.amazonaws.com/Minecraft.Download/versions/1.8.3/minecraft_server.1.8.3.jar

    # Changing ownership of the files back to minecraft
    chown -R minecraft:minecraft /home/minecraft/

    echo "Run the server using this command inside a screen instance"
    echo "java -Xmx1024M -Xms1024M -jar minecraft.jar nogui"

}

# Automatically installs the base team fortress 2 server using SteamPIPE
function tf2_setup () {
    # Start message
    echo "Starting to install team fortress gameserver..."

    # Installing dependencies
    echo "Starting to install tf2 server dependencies"
    apt-get --assume-yes install lib32gcc1 lib32z1 lib32ncurses5 lib32bz2-1.0


    # Installs steamCMD to the tf2 user's home directory and extracts it
    cd /home/teamfortress/
    wget http://media.steampowered.com/installer/steamcmd_linux.tar.gz
    tar zxf steamcmd_linux.tar.gz

    # Creates steamcmd tf2_ds.txt script
    echo "login anonymous
force_install_dir ./tf2
app_update 232250
quit" > /home/teamfortress/tf2_ds.txt

    # Creates an automatic updater script for TF2
    echo "#!/bin/sh
./steamcmd.sh +runscript tf2_ds.txt" > /home/teamfortress/update.sh
    chmod 755 /home/teamfortress/update.sh

    # Creates server startup script
    echo "#!/bin/sh
tf2/srcds_run -game tf +sv_pure 0 +randommap +maxplayers 24 -replay -steam_dir ~/ -steam_script ~/tf2_ds.txt +sv_shutdown_timeout_minutes 360 -autoupdate" > /home/teamfortress/tf.sh
    chmod 755 /home/teamfortress/tf.sh

    # Downloads server files
    chmod -R 777 /home/teamfortress/linux32
    ./update.sh

    # Downloads server configuration files
    git clone https://github.com/Dirsec/Server.git /home/teamfortress/configuration

    # Adds mapcycle
    cp /home/teamfortress/configuration/cfg/mapcycle.txt /home/teamfortress/tf2/tf/cfg/mapcycle.txt

    # Adds server configuration file
    cp /home/teamfortress/configuration/cfg/server.cfg /home/teamfortress/tf2/tf/cfg/server.cfg

    # Changes motd to something reputable
    cp /home/teamfortress/configuration/motd.txt /home/teamfortress/tf2/tf/motd.txt

    # Adds addons folder
    cp -r /home/teamfortress/configuration/addons /home/teamfortress/tf2/tf/addons

    # Changing recursively ownership back to teamfortress user
    chown -R teamfortress:teamfortress /home/teamfortress/
}

# Automatically executes all the functions
function autoexec () {
    preliminaries
    user_setup
    ssh_setup
    sshkeys_setup
    iptables_setup
    fail2ban_setup
    rkhunter_setup
    cronjob_setup
    apache_setup
    minecraft_setup
    tf2_setup
}

autoexec
