#!/bin/bash

# General TF2 Server Setup. Automated Edition by Shen Zhou Hong
# Created to democratcise the provisioning of Dirsec-styled servers
# Copyright GPLv2 2015.

# General Server-wide Configuration
server_name="Dirsec-Styled TF2 Server"

# Checks if the script is running as root
function checkroot () {
    # Checks if script is ran as root by checking user ID
    if [[ $EUID -ne 0 ]]; then
        # If the script is not ran as root, exit with error code 1
        echo "This script must be run as root - retry with 'su root' or 'sudo'"
        exit 1
    fi
}

# Automatically updates the server if needed
function update () {
    # update configuration
    linux_server_update=true
    linux_server_upgrade=true

    # Updates server package lists
    if [[ $linux_server_update=true ]]; then
        echo "Updating package lists..."
        apt-get --assume-yes update
    fi

    # Upgrades server with new packages
    if [[ $linux_server_upgrade=true ]]; then
        echo "Performing automatic server update..."
        apt-get --assume-yes upgrade
    fi
}

# Installs system-wide dependencies
function system_dependencies () {
    # system_dependencies configuration
    git_install=true

    # Upgrades server with new packages
    if [[ $git_install=true ]]; then
        echo "Installing git system-wide dependency..."
        apt-get --assume-yes install git
    fi
}

# Creates and configures users
function user_setup () {
    # user_setup configuration
    linux_users=(admin teamfortress)
    linux_sudo_users=(admin)

    # Adds a list of users defined in $users to the system
    for i in "${linux_users[@]}"; do

        # Uses useradd with args for home directory creation, shell, and group
        echo "Adding $i user to system..."
        useradd $i -s /bin/bash -m -U

        # Asks for the password of the users, and changes it via chpasswd
        echo -n "Enter $i's password: "
        read -s password
        echo "Changing $i password..."
        echo "$i:$password" | chpasswd
    done

    # This segment of the script that actually adds the users to each group.
    for i in "${linux_sudo_users[@]}"; do

        # We are using the adduser command here instead of usermod or useradd.
        echo "Adding $i user to sudo group..."
        adduser $i sudo

    done
}

# Installs SSH keys (vastly more secure type of authentication) to the server
function sshkeys_setup () {
    # Creates SSH folders and authorized_keys
    echo "Starting ssh-keys setup"
    for i in "${linux_sudo_users[@]}"; do

        # Creates the SSH dotfolder in the user's home directory.
        echo "Creating .ssh folder for $i..."
        mkdir /home/$i/.ssh/

        # Adding SSH key instructions
        echo "# Please paste in your SSH key for the $i user below" > /home/$i/.ssh/authorized_keys
        echo "# Make sure it is your PUBLIC KEY (id_rsa.pub)!!!" >> /home/$i/.ssh/authorized_keys
        echo "# Once you are done, save and quit. Ctrl + X, Y, and Enter" >> /home/$i/.ssh/authorized_keys

        # Opens nano and allows user to install SSH keys
        nano /home/$i/.ssh/authorized_keys

        # Changes file permissions so SSH works with it
        chmod -R 700 /home/$i/.ssh/
        chown -R $i:$i
    done
}

# Setups and configures the ssh daemon for a more secure SSH
function ssh_setup () {
    # ssh_setup configuration
    ssh_port_number=40
    ssh_root_login=false
    ssh_banner=true
    ssh_banner_msg="Welcome to $server_name SSH server. Authorized users only!"
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

# Iptables setup and configuration
function iptables_setup () {
    # iptables_setup configuration
    iptables_persistent=true

    # Starts configuring iptables and allows current connections
    echo "Allowing all currently established connections"
    iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

    # Opens SSH non-default port number
    echo "Allowing non-default SSH port"
    iptables -A INPUT -p tcp --dport $ssh_default_port_number -j ACCEPT

    # Opens webserver port 80
    echo "Allowing default HTTP webserver port"
    iptables -A INPUT -p tcp --dport 80 -j ACCEPT

    # Opens Team Fortress 2 main connection port
    echo "Allowing team fortress 2 main port"
    iptables -A INPUT -p udp --dport 27015 -j ACCEPT

    # Opens Team Fortress 2 rcon port
    echo "Allowing rcon team fortress 2 port"
    iptables -A INPUT -p tcp --dport 27015 -j ACCEPT

    # Allows loopback devices
    echo "Allowing all loopback devices"
    iptables -I INPUT 1 -i lo -j ACCEPT

    # Sets default drop rule for INPUT chain
    echo "Setting default drop policy for iptables"
    iptables -P INPUT DROP

    # Lists all rules
    echo "Listing all iptables rules"
    iptables -L --line-numbers

    # Installing iptables persistant to save rules
    if [[ $iptables_persistent=true ]]; then
        echo "Installing persistent iptables to save rules"
        apt-get --assume-yes install iptables-persistent
    fi
}

# Installs the fail2ban dynamic firewall modifier and configures it
function fail2ban_setup () {
    # Fail2ban configuration
    fail2ban_bantime=2592000
    fail2ban_destemail="admin@localhost"

    # Installs fail2ban
    apt-get --assume-yes install fail2ban

    # Copys configuration file over
    cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

    # Lengthening bantime to 30 days
    echo "Setting bantime to 30 days (2592000 seconds)"
    sed -i "/bantime  = 600/c\bantime  = $fail2ban_bantime" /etc/fail2ban/jail.local

    # changing destemail to all sudo-enabled admins
    echo "Changing destemail to include peterpacz1 and morgenman"
    sed -i "/destemail = root@localhost/c\destemail = $fail2ban_destemail" /etc/fail2ban/jail.local

    # Allows detailed mail reports to be emailed after banning
    echo "Changing action to include the mailing of logs"
    sed -i '/action = %(action_)s/c\action = %(action_mwl)s' /etc/fail2ban/jail.local

    # Changes so that port number for SSH is set to non-default port
    echo "Setting SSH port number on Fail2ban to the non default port"
    # Note that this sed uses " " because doublequtoes expand variables
    sed -i "/port     = ssh/c\port     = $ssh_port_number"

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
