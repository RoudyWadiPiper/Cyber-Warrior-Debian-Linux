echo Creating Backups of Settings Files...
sudo cp /etc/login.defs /
mv /login.defs /BACKUPlogin.defs
sudo cp /etc/pam.d/common-password /
mv /common-password /BACKUPcommon-password
sudo cp /etc/pam.d/common-auth /
mv /common-auth /BACKUPcommon-auth
sudo cp /etc/ssh/sshd_config /
mv /sshd_config /BACKUPsshd_config
echo Fixing Password Settings...
sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/g' /etc/login.defs
sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   3/g' /etc/login.defs
sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   7/g' /etc/login.defs
sed -i 's/^LOGIN_RETRIES.*/LOGIN_RETRIES   5/g' /etc/login.defs
sed -i 's/^LOGIN_TIMEOUT.*/LOGIN_TIMEOUT   60/g' /etc/login.defs
sed -i 's/^password [success=2 default=ignore]pam_unix.so.*/password [success=2 default=ignore] pam_unix.so obscure sha512 minlen=8/g' /etc/pam.d/common-password
sed -i 's/^auth [success=2 default=ingore]pam_unix.so nullok.*/auth [success=2 default=ingore]pam_unix.so/g' /etc/pam.d/common-auth
echo Enabling Uncomplicated Firewall...
sudo ufw enable
echo Disabling Unsecure Services...
sudo systemctl stop pure-ftpd
sudo systemctl disable pure-ftpd
sudo systemctl stop ngnix
sudo systemctl disable ngnix
sudo systemctl stop samba
sudo systemctl disable samba
echo Removing Prohibited Software...
sudo apt-get remove zenmap nmap -y
sudo apt remove aisleriot -y
sudo apt remove wireshark -y
sudo apt remove ophcrack -y
sudo apt autoremove -y
echo Disabling Root Login...
sed -i 's/^PermitRootLogin no.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
echo Updating All Packages...
sudo apt update
sudo apt upgrade -y
echo CyberWarrior Has Completed!
