sudo cp /etc/login.defs /
mv /login.defs /BACKUPlogin.defs
sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/g' /etc/login.defs
sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   3/g' /etc/login.defs
sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   7/g' /etc/login.defs
sed -i 's/^LOGIN_RETRIES.*/LOGIN_RETRIES   5/g' /etc/login.defs
sed -i 's/^LOGIN_TIMEOUT.*/LOGIN_TIMEOUT   60/g' /etc/login.defs
echo CyberWarrior Has Completed!
