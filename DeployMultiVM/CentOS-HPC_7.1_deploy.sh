#place holder for 7.1 script
yum install -y epel-release
yum install -y nmap sshpass
cd /home/azureuser/


runuser -l azureuser -c 'wget https://raw.githubusercontent.com/tanewill/utils/master/authMe.sh'
runuser -l azureuser -c 'mkdir -p /home/azureuser/.ssh'
runuser -l azureuser -c "echo -e  'y\n' | ssh-keygen -f .ssh/id_rsa -t rsa -N ''"
runuser -l azureuser -c 'chmod +x /home/azureuser/authMe.sh'
mkdir -p .ssh
echo 'Host *' >> .ssh/config
echo 'StrictHostKeyChecking no' >> .ssh/config
chmod 400 config
chown azureuser:azureuser /home/azureuser/.ssh/config
runuser -l azureuser -c 'bash /home/azureuser/authMe.sh'
