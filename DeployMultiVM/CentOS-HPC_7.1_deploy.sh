#place holder for 7.1 script
yum install -y epel-release
yum install -y nmap sshpass
cd /home/azureuser/


runuser -l azureuser -c 'wget https://raw.githubusercontent.com/tanewill/utils/master/authMe2.sh'
runuser -l azureuser -c 'bash /home/azureuser/authMe2.sh'
