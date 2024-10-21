echo Creating Backups of Settings Files...
sudo cp /etc/login.defs /
mv /login.defs /BACKUPlogin.defs
sudo cp /etc/pam.d/common-password /
mv /common-password /BACKUPcommon-password
sudo cp /etc/pam.d/common-auth /
mv /common-auth /BACKUPcommon-auth
sudo cp /etc/ssh/sshd_config /
mv /sshd_config /BACKUPsshd_config

#Fix Password Settings

echo Fixing Password Settings...
sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/g' /etc/login.defs
sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   3/g' /etc/login.defs
sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   7/g' /etc/login.defs
sed -i 's/^LOGIN_RETRIES.*/LOGIN_RETRIES   5/g' /etc/login.defs
sed -i 's/^LOGIN_TIMEOUT.*/LOGIN_TIMEOUT   60/g' /etc/login.defs
sed -i 's/^password [success=2 default=ignore]pam_unix.so.*/password [success=2 default=ignore] pam_unix.so obscure sha512 minlen=8/g' /etc/pam.d/common-password
sed -i 's/^auth [success=2 default=ingore]pam_unix.so nullok.*/auth [success=2 default=ingore]pam_unix.so/g' /etc/pam.d/common-auth

#Enable Firewall

echo Enabling Uncomplicated Firewall...
sudo apt install -y mlocate ufw gufw net-tools htop
sudo ufw default allow outgoing
sudo ufw default deny incoming
sudo ufw enable

#Disable Insecure Services

echo Disabling Insecure Services...
read -p "Is ftpd a Critical Service? [y/n]  " answer

if [ "$answer" = "n" ]
then
	sudo systemctl stop pure-ftpd
	sudo systemctl disable pure-ftpd
fi

read -p "Is ngnix a Critical Service? [y/n]  " answer

if [ "$answer" = "n" ]
then
	sudo systemctl stop ngnix
	sudo systemctl disable ngnix
fi

read -p "Is samba a Critical Service? [y/n]  " answer

if [ "$answer" = "n" ]
then
	sudo systemctl stop samba
	sudo systemctl disable samba
fi

#Remove Prohibited Software

echo Removing Prohibited Software...
sudo apt-get remove zenmap nmap -y
sudo apt remove aisleriot -y
sudo apt remove wireshark -y
sudo apt remove ophcrack -y
sudo apt autoremove -y

#Disable Root Login

read -p "Allow Root Login? [y/n]" answer

if [ "$answer" = "n" ]
then
	sed -i 's/^PermitRootLogin no.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
fi

#Add Users

read -p "Do you need to add a new user? [y/n]" answer

while [ "$answer" = "y" ]

do
	read -p "Username: " newname
	useradd $newname
	passwd $newname
	
	read -p "Add to a group? [y/n]" groupbool
	
	if [ "$groupbool" = "y" ]
	then
		read -p "Insert Group Name" groupname
		usermod -aG $groupname $newname
		echo -e "User $newname added to $groupname group"
	else
		echo -e "User $newname will not be added to any groups"
	fi
	
	read -p "Should they be admin? [y/n]" sudobool
	
	if [ "$sudobool" = "y" ]
	then
		usermod -aG sudo $newname
		echo -e "User $newname added to administrator list"
	else
		echo -e "User $newname will not be added to administrator list"
	fi
	
	read -p "Add another user? [y/n]" answer
done

#Update Packages

echo Updating All Packages...
sudo apt update
sudo apt upgrade -y
echo CyberWarrior Has Completed!
