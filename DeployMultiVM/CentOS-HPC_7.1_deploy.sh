#place holder for 7.1 script
yum install -y epel-release
yum install -y nmap sshpass
nmap -sn 10.0.0.* | grep 10.0.0. | awk '{print $5}' > nodenames.txt

cd /home/azureuser/
runuser -l azureuser -c 'wget https://raw.githubusercontent.com/tanewill/utils/master/authMe.sh'
runuser -l azureuser -c 'mkdir -p /home/azureuser/.ssh'
runuser -l azureuser -c "echo -e  'y\n' | ssh-keygen -f .ssh/id_rsa -t rsa -N ''"
runuser -l azureuser -c 'chmod +x authMe.sh'
runuser -l azureuser -c 'authMe.sh'
