#!/bin/bash
mkdir -p /home/azureuser/bin/
cd /home/azureuser/bin

wget https://raw.githubusercontent.com/tanewill/sandbox/Ubuntu/DeployMultiVM/localDeploy.sh
wget https://raw.githubusercontent.com/tanewill/utils/master/authMe.sh
wget https://raw.githubusercontent.com/tanewill/utils/master/myClusRun.sh
chmod +x *
runuser -l root -c '/home/azureuser/bin/localDeploy.sh'
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm 
rpm -Uvh epel-release-latest-7.noarch.rpm
yum install -y nfs-utils nfs-utils-lib sshpass

rpm -Uvh epel-release-latest-7.noarch.rpm
runuser -l azureuser -c 'mkdir -p ~/.ssh'
runuser -l azureuser -c "ssh-keygen -f .ssh/id_rsa -t rsa -N ''"
runuser -l azureuser -c 'bin/authMe.sh'
