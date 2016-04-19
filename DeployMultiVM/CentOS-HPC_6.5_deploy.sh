#!/bin/bash
mkdir -p /home/azureuser/bin/
cd /home/azureuser/bin

wget https://raw.githubusercontent.com/tanewill/sandbox/Ubuntu/DeployMultiVM/localDeploy.sh
wget https://raw.githubusercontent.com/tanewill/utils/master/authMe.sh
wget https://raw.githubusercontent.com/tanewill/utils/master/myClusRun.sh
chmod +x *
runuser -l root -c '/home/azureuser/bin/localDeploy.sh'
yum -y install epel-release
yum install -y nfs-utils nfs-utils-lib sshpass arp-scan


#create nodelist
cd /home/azureuser
arp-scan -I eth0 10.0.0.0/24 | grep 10.0.0 | awk '{print $1}' | tail -n+2 > nodenames.txt
# ifconfig | grep 'inet addr:10.0.0.'|awk -F':' '{print $2}'|awk '{print $1}' >> nodenames.txt

#setup authentication
runuser -l azureuser -c 'mkdir -p ~/.ssh'
runuser -l azureuser -c "echo -e  'y\n' | ssh-keygen -f .ssh/id_rsa -t rsa -N ''"
runuser -l azureuser -c "bin/myClusRun.sh hostname | sed '1d;$d' > test.txt"
runuser -l azureuser -c 'mv -f test.txt nodenames.txt'
runuser -l azureuser -c "sed -i '$ d' nodenames.txt"
runuser -l azureuser -c 'bin/authMe.sh'

#test mpi
/opt/intel/impi/5.1.3.181/bin64/mpirun -hosts testsxfvcomp0,testsxfvcomp1,testsxfvcomp2 -ppn 1 -n 3 -env I_MPI_FABRICS=shm:dapl -env I_MPI_DAPL_PROVIDER=ofa-v2-ib0 -env I_MPI_DYNAMIC_CONNECTION=0 -env I_MPI_DEBUG 5 IMB-MPI1 pingpong
