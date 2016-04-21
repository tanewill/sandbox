#place holder for 7.1 script
yum install -y epel-release
yum install -y nmap sshpass
cd /home/azureuser/
nmap -sn 10.0.0.* | grep 10.0.0. | awk '{print $5}' > nodenames.txt
runuser -l azureuser -c 'wget https://raw.githubusercontent.com/tanewill/utils/master/authMe.sh'
runuser -l azureuser -c 'mkdir -p /home/azureuser/.ssh'
runuser -l azureuser -c "echo -e  'y\n' | ssh-keygen -f .ssh/id_rsa -t rsa -N ''"
runuser -l azureuser -c 'chmod +x /home/azureuser/authMe.sh'
runuser -l azureuser -c 'bash /home/azureuser/authMe.sh'
