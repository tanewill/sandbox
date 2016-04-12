#!/bin/bash

mkdir -p /home/azureuser/bin/
cd /home/azureuser/bin
wget https://raw.githubusercontent.com/tanewill/utils/master/authMe.sh
wget https://raw.githubusercontent.com/tanewill/utils/master/myClusRun.sh
chmod +x *
DEBIAN_FRONTEND=noninteractive apt-get --yes --force-yes install arp-scan
DEBIAN_FRONTEND=noninteractive apt-get --yes --force-yes install sshpass
DEBIAN_FRONTEND=noninteractive apt-get --yes --force-yes install htop

cd /home/azureuser
arp-scan -I eth0 10.0.0.0/24 | grep 10.0 | awk '{print $1}'|tail -n+2 > nodenames.txt
ifconfig | grep 'inet addr:10.0.0.'|awk -F':' '{print $2}'|awk '{print $1}' >> nodenames.txt
runuser -l azureuser -c 'mkdir -p ~/.ssh'
runuser -l azureuser -c "ssh-keygen -f .ssh/id_rsa -t rsa -N ''"
runuser -l azureuser -c 'bin/authMe.sh'

runuser -l azureuser -c "bin/myClusRun.sh 'DEBIAN_FRONTEND=noninteractive sudo add-apt-repository http://www.openfoam.org/download/ubuntu'"
runuser -l azureuser -c "bin/myClusRun.sh 'sudo apt-get update'"
runuser -l azureuser -c "bin/myClusRun.sh 'sudo apt-get -qq --yes --force-yes install openfoam30'"
runuser -l azureuser -c "bin/myClusRun.sh 'sudo apt-get -qq --yes --force-yes install paraviewopenfoam44'"
bin/myClusRun.sh 'echo "source /opt/openfoam30/etc/bashrc">>/home/azureuser/.bashrc'
bin/myClusRun.sh 'echo "source /opt/openfoam30/etc/bashrc">>~/.bashrc'
