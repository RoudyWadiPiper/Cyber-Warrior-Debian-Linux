#!/bin/bash

echo Starting CyberWarrior!

#Create Backups of Settings Files

echo Creating Backups of Settings Files...
sudo cp /etc/login.defs /
mv /login.defs /BACKUPlogin.defs
sudo cp /etc/pam.d/common-password /
mv /common-password /BACKUPcommon-password
sudo cp /etc/pam.d/common-auth /
mv /common-auth /BACKUPcommon-auth
sudo cp /etc/ssh/sshd_config /
mv /sshd_config /BACKUPsshd_config
echo Backups Created!

#Fix Password Settings

echo Fixing Password Settings...
sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/g' /etc/login.defs
sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   3/g' /etc/login.defs
sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   7/g' /etc/login.defs
sed -i 's/^LOGIN_RETRIES.*/LOGIN_RETRIES   5/g' /etc/login.defs
sed -i 's/^LOGIN_TIMEOUT.*/LOGIN_TIMEOUT   60/g' /etc/login.defs
sed -i 's/^password [success=2 default=ignore]pam_unix.so.*/password [success=2 default=ignore] pam_unix.so obscure sha512 minlen=8/g' /etc/pam.d/common-password
sed -i 's/^auth [success=2 default=ingore]pam_unix.so nullok.*/auth [success=2 default=ingore]pam_unix.so/g' /etc/pam.d/common-auth
echo Password Settings Altered!

#Enable Firewall

read -p "Enable UFW? [y/n]" answer
if [ "$answer" = "y" ]
then
	sudo apt install -y mlocate ufw gufw net-tools htop
	sudo ufw default allow outgoing
	sudo ufw default deny incoming
	sudo ufw enable
	echo Enabled Uncomplicated Firewall!
else
	echo Not Enabling UFW!
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

echo Adding Required Software...
read -p "Download X2GO? [y/n]" answer
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
read -p "Delete Zenmap-Nmap? [y/n]" answer
if [ "$answer" = "y" ]
then
	sudo apt-get remove zenmap nmap -y
	echo Zenmap-Nmap Removed Via APT!
fi
sudo apt autoremove -y

#Disable Root Login

read -p "Allow Root Login? [y/n]" answer
if [ "$answer" = "n" ]
then
	sed -i 's/^PermitRootLogin no.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
	echo Root Login Disabled!
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

#Update Packages

echo Updating All Packages...
sudo apt update
sudo apt upgrade -y
echo Updating Completed!

#End

echo CyberWarrior Has Completed!
