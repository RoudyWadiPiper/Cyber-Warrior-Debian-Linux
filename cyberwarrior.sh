#!/bin/bash

echo Starting CyberWarrior!

#Create Backups of Settings Files

echo Creating Backups of Settings Files...
sudo cp /etc/login.defs /
mv /login.defs /Prevlogin.defs
sudo cp /etc/pam.d/common-password /
mv /common-password /Prevcommon-password
sudo cp /etc/pam.d/common-auth /
mv /common-auth /Prevcommon-auth
sudo cp /etc/ssh/sshd_config /
mv /sshd_config /Prevsshd_config
echo Backups Created!

#Fix Password Settings

echo Fixing Password Settings...
sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/g' /etc/login.defs
sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   5/g' /etc/login.defs
sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   7/g' /etc/login.defs
sed -i 's/^LOGIN_RETRIES.*/LOGIN_RETRIES   5/g' /etc/login.defs
sed -i 's/^LOGIN_TIMEOUT.*/LOGIN_TIMEOUT   300/g' /etc/login.defs
sed -i 's/^password [.*/password [success=2 default=ignore]	pam_unix.so obscure sha512 minlen=14/g' /etc/pam.d/common-password
sed -i 's/^auth [success=2.*/auth [success=2 default=ingore]	pam_unix.so/g' /etc/pam.d/common-auth
sed -i 's/^MaxAuthTries.*/MaxAuthTries 3/g' /etc/ssh/sshd_config
echo Password Settings Altered!

#Enable Programs to Secure System and Make CyberPatriot Competition Easier

read -p "Enable UFW? (Firewall) [y/n]" answer
if [ "$answer" = "y" ]
then
	sudo apt install -y ufw gufw
	sudo ufw default allow outgoing
	sudo ufw default deny incoming
	sudo ufw enable
	echo Enabled Uncomplicated Firewall!
else
	echo Not Enabling UFW!
fi

read -p "Enable auditd? (Audit Logging) [y/n]" answer
if [ "$answer" = "y" ]
then
	sudo apt install -y auditd
	sudo auditctl -e 1
	echo Enabled auditd!
	echo "Configure in File /etc/audit/auditd.conf"
else
	echo Not Enabling auditd!
fi

read -p "Enable chkservice? (Service Viewer) [y/n]" answer
if [ "$answer" = "y" ]
then
	sudo apt install -y chkservice
	echo Enabled chkservice!
else
	echo Not Enabling chkservice!
fi

read -p "Enable plocate? (Locate Command) [y/n]" answer
if [ "$answer" = "y" ]
then
	sudo apt install -y plocate
	echo Enabled plocate!
else
	echo Not Enabling plocate!
fi

read -p "Enable net-tools? (Network Tools) [y/n]" answer
if [ "$answer" = "y" ]
then
	sudo apt install -y net-tools
	echo Enabled net-tools!
else
	echo Not Enabling net-tools!
fi

read -p "Enable htop? (Process Viewer) [y/n]" answer
if [ "$answer" = "y" ]
then
	sudo apt install -y htop
	echo Enabled htop!
else
	echo Not Enabling htop!
fi

#Disable Insecure Services

echo Disabling Insecure Services...
read -p "Is Ftpd a Critical Service? [y/n]  " answer
if [ "$answer" = "n" ]
then
	sudo systemctl stop pure-ftpd
	sudo systemctl disable pure-ftpd
	echo Ftpd Service Disabled!
fi

read -p "Is openssh-server a Critical Service? [y/n]  " answer
if [ "$answer" = "n" ]
then
	sudo systemctl stop openssh-server
	sudo systemctl stop openssh-cient
	sudo systemctl disable openssh-server
	sudo systemctl disable openssh-cient
	sudo apt-get remove openssh-server openssh-client -y
	echo Openssh-server Service Disabled!
fi

read -p "Is Ngnix a Critical Service? [y/n]  " answer
if [ "$answer" = "n" ]
then
	sudo systemctl stop ngnix
	sudo systemctl disable ngnix
	echo Ngnix Service Disabled!
fi

read -p "Is Samba a Critical Service? [y/n]  " answer
if [ "$answer" = "n" ]
then
	sudo systemctl stop samba
	sudo systemctl disable samba
	echo Samba Service Disabled!
fi
echo Do Not Forget To Run Command To Check For Other Services: systemctl list-units --type=service --state=active
#Add Software

echo Adding Possible Required Software...
read -p "Download X2GO (Remote Access Tool)? [y/n]" answer
if [ "$answer" = "y" ]
then
	sudo apt-get install x2goserver
	echo X2GO Installed Via APT!
fi

#Remove Prohibited Software

echo Removing Prohibited Software...
read -p "Delete Wireshark? [y/n]" answer
if [ "$answer" = "y" ]
then
	sudo apt remove wireshark -y
	echo Wireshark Removed Via APT!
fi
read -p "Delete Ophcrack? [y/n]" answer
if [ "$answer" = "y" ]
then
	sudo apt remove ophcrack -y
	echo Ophcrack Removed Via APT!
fi
read -p "Delete Aisleriot? [y/n]" answer
if [ "$answer" = "y" ]
then
	sudo apt remove aisleriot -y
	echo Aisleriot Removed Via APT!
fi
read -p "Delete Nmap-Zenmap? [y/n]" answer
if [ "$answer" = "y" ]
then
	sudo apt-get remove zenmap nmap -y
	echo Zenmap-Nmap Removed Via APT!
fi
sudo apt autoremove -y

#Disable Root Login

read -p "Allow SSH Root Login? [y/n]" answer
if [ "$answer" = "n" ]
then
	sed -i 's/^PermitRootLogin yes.*/PermitRootLogin no/g' /etc/ssh/sshd_config
	echo SSH Root Login Disabled!
fi

#Add group

read -p "Do you need to add a new group? [y/n]" answer
while [ "$answer" = "y" ]
do
	read -p "Insert Group Name:" groupname
	groupadd $groupname
	echo Created Group $groupname!
	read -p "Add Another Group? [y/n]" answer
done

#Add Users

read -p "Do you need to add a new user? [y/n]" answer
while [ "$answer" = "y" ]
do
	read -p "Insert Username:" newname
	useradd $newname
	passwd $newname
	echo Created User $newname!
	read -p "Add to a group? [y/n]" groupbool
	if [ "$groupbool" = "y" ]
	then
		read -p "Insert Group Name:" groupname
		adduser $newname $groupname
		echo -e "User $newname added to $groupname group!"
	else
		echo -e "User $newname will not be added to any groups!"
	fi
	
	read -p "Should they be admin? [y/n]" sudobool
	if [ "$sudobool" = "y" ]
	then
		usermod -aG sudo $newname
		echo -e "User $newname added to administrator list!"
	else
		echo -e "User $newname will not be added to administrator list!"
	fi
	read -p "Add another user? [y/n]" answer
done

#Add users to groups

read -p "Do you need to add a user to a group? [y/n]" answer
while [ "$answer" = "y" ]
do
	read -p "Insert Username: " newname
	read -p "Insert Group Name:" groupname
	adduser $newname $groupname
	echo Added User $newname to Group $groupname!
	read -p "Add Another User To Group? [y/n]" answer
done

#Mp3 Finder

read -p "Find all files with a file extension? (Home Folder Only) [y/n] " answer
while [ "$answer" = "y" ]
do
	read -p "Insert file extension (NO DOT): " fileex
	sudo find /home -type f -name "*.$fileex" > $fileex.txt
	sudo chmod ugo+rwx $fileex.txt
	echo "All found files in $fileex.txt"
	read -p "Search for another file extention? [y/n] " answer
done

#Update Packages

read -p "Update all packages? [y/n]" answer
if [ "$answer" = "y" ]
then
	echo Updating All Packages...
	sudo apt update
	sudo apt upgrade -y
	echo Updating Completed!
else
	echo Not Updating All Packages!
fi

#End

echo CyberWarrior Has Completed!
