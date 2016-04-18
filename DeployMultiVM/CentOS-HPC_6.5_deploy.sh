#!/bin/bash
mkdir -p /home/azureuser/bin/
cd /home/azureuser/bin

wget https://raw.githubusercontent.com/tanewill/sandbox/Ubuntu/DeployMultiVM/localDeploy.sh
wget https://raw.githubusercontent.com/tanewill/utils/master/authMe.sh
wget https://raw.githubusercontent.com/tanewill/utils/master/myClusRun.sh
chmod +x *
runuser -l root -c '/home/azureuser/bin/localDeploy.sh'
yum -y install epel-release
yum install -y nfs-utils nfs-utils-lib sshpass

runuser -l azureuser -c 'mkdir -p ~/.ssh'
runuser -l azureuser -c "ssh-keygen -f .ssh/id_rsa -t rsa -N ''"
runuser -l azureuser -c 'bin/authMe.sh'
