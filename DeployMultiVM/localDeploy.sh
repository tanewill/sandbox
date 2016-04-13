#!/bin/bash

#install needed packages
DEBIAN_FRONTEND=noninteractive apt-get --yes --force-yes install arp-scan, sshpass, htop

#create nodelist
cd /home/azureuser
arp-scan -I eth0 10.0.0.0/24 | grep 10.0.0 | awk '{print $1}' | tail -n+2 > nodenames.txt
ifconfig | grep 'inet addr:10.0.0.'|awk -F':' '{print $2}'|awk '{print $1}' >> nodenames.txt

#setup authentication
runuser -l azureuser -c 'mkdir -p ~/.ssh'
runuser -l azureuser -c "ssh-keygen -f .ssh/id_rsa -t rsa -N ''"
runuser -l azureuser -c 'bin/authMe.sh'
runuser -l azureuser -c "bin/myClusRun.sh hostname | sed '1d;$d' > test.txt"
runuser -l azureuser -c 'mv -f test.txt nodenames.txt'
runuser -l azureuser -c 'bin/authMe.sh'

#install openFOAM
/bin/bash /home/azureuser/bin/myClusRun.sh 'echo "source /opt/openfoam30/etc/bashrc">>/home/azureuser/.bashrc'
runuser -l azureuser -c "bin/myClusRun.sh 'DEBIAN_FRONTEND=noninteractive sudo add-apt-repository http://www.openfoam.org/download/ubuntu'"
runuser -l azureuser -c "bin/myClusRun.sh 'DEBIAN_FRONTEND=noninteractive sudo apt-get update'"
runuser -l azureuser -c "bin/myClusRun.sh 'DEBIAN_FRONTEND=noninteractive sudo apt-get -qq --yes --force-yes install openfoam30'"
runuser -l azureuser -c "bin/myClusRun.sh 'DEBIAN_FRONTEND=noninteractive sudo apt-get -qq --yes --force-yes install paraviewopenfoam44'"

#configure OpenFOAM
runuser -l azureuser -c 'mkdir -p $FOAM_RUN'
runuser -l azureuser -c 'cp -r $FOAM_TUTORIALS $FOAM_RUN'

