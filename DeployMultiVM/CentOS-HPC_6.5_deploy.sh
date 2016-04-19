#!/bin/bash
basehost=`hostname | sed -e "s/^.*\(.\)$/\1/"`
MASTER_HOSTNAME=$1

# Shares
SHARE_HOME=/share/home
SHARE_DATA=/share/data


# Hpc User
HPC_USER=$2
HPC_UID=7007
HPC_GROUP=hpc
HPC_GID=7007


# Installs all required packages.
#
install_pkgs()
{
    pkgs="zlib zlib-devel bzip2 bzip2-devel bzip2-libs openssl openssl-devel openssl-libs gcc gcc-c++ nfs-utils rpcbind mdadm wget"
    yum -y install $pkgs
}


setup_shares()
{
    mkdir -p $SHARE_HOME
    mkdir -p $SHARE_DATA

   
        echo "$MASTER_HOSTNAME:$SHARE_HOME $SHARE_HOME    nfs4    rw,auto,_netdev 0 0" >> /etc/fstab
        echo "$MASTER_HOSTNAME:$SHARE_DATA $SHARE_DATA    nfs4    rw,auto,_netdev 0 0" >> /etc/fstab
        mount -a
        mount | grep "^$MASTER_HOSTNAME:$SHARE_HOME"
        mount | grep "^$MASTER_HOSTNAME:$SHARE_DATA"

}

# Adds a common HPC user to the node and configures public key SSh auth.
# The HPC user has a shared home directory (NFS share on master) and access
# to the data share.
#
setup_hpc_user()
{
    # disable selinux
    sed -i 's/enforcing/disabled/g' /etc/selinux/config
    setenforce permissive
    
    groupadd -g $HPC_GID $HPC_GROUP

    # Don't require password for HPC user sudo
    echo "$HPC_USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
    
    # Disable tty requirement for sudo
    sed -i 's/^Defaults[ ]*requiretty/# Defaults requiretty/g' /etc/sudoers

    
    useradd -c "HPC User" -g $HPC_GROUP -d $SHARE_HOME/$HPC_USER -s /bin/bash -u $HPC_UID $HPC_USER
    
}

# Sets all common environment variables and system parameters.
#
setup_env()
{
    # Set unlimited mem lock
    echo "$HPC_USER hard memlock unlimited" >> /etc/security/limits.conf
    echo "$HPC_USER soft memlock unlimited" >> /etc/security/limits.conf

    # Intel MPI config for IB
    echo "# IB Config for MPI" > /etc/profile.d/hpc.sh
    echo "export I_MPI_FABRICS=shm:dapl" >> /etc/profile.d/hpc.sh
    echo "export I_MPI_DAPL_PROVIDER=ofa-v2-ib0" >> /etc/profile.d/hpc.sh
    echo "export I_MPI_DYNAMIC_CONNECTION=0" >> /etc/profile.d/hpc.sh
}


first_setup()
{
  mkdir -p /home/azureuser/bin/
  cd /home/azureuser/bin
  
  wget https://raw.githubusercontent.com/tanewill/sandbox/Ubuntu/DeployMultiVM/localDeploy.sh
  wget https://raw.githubusercontent.com/tanewill/utils/master/authMe.sh
  wget https://raw.githubusercontent.com/tanewill/utils/master/myClusRun.sh
  chmod +x *
  chown azureuser:azureuser *
  yum install -y epel-release
  echo "############### INSTALL PACKAGES NEXT #######################"
  pwd
  whoami
  sleep 10
  yum install -y nfs-utils nfs-utils-lib sshpass arp-scan
  sleep 10
  
  #create nodelist
  cd /home/azureuser
  echo "############### GET NODE NAMES #######################"
  sleep 10
  arp-scan -I eth0 10.0.0.0/24 | grep 10.0.0 | awk '{print $1}' | tail -n+2
  arp-scan -I eth0 10.0.0.0/24 | grep 10.0.0 | awk '{print $1}' | tail -n+2 > nodenames.txt
  # ifconfig | grep 'inet addr:10.0.0.'|awk -F':' '{print $2}'|awk '{print $1}' >> nodenames.txt
  sleep 10
  #setup authentication
  echo "############### AUTHENTICATE ALL MACHINES #######################"
  runuser -l azureuser -c 'mkdir -p ~/.ssh'
  runuser -l azureuser -c "echo -e  'y\n' | ssh-keygen -f .ssh/id_rsa -t rsa -N ''"
  runuser -l azureuser -c "bin/myClusRun.sh hostname | sed '1d;$d' > test.txt"
  runuser -l azureuser -c 'cp -f nodenames.txt nodenames.bak.txt'
  runuser -l azureuser -c 'cp -f test.txt nodenames.txt'
  runuser -l azureuser -c "sed -i '$ d' nodenames.txt"
  runuser -l azureuser -c 'bin/authMe.sh'

  #test mpi
  /opt/intel/impi/5.1.3.181/bin64/mpirun -hosts testsxfvcomp0,testsxfvcomp1,testsxfvcomp2 -ppn 1 -n 3 -env I_MPI_FABRICS=shm:dapl -env I_MPI_DAPL_PROVIDER=ofa-v2-ib0 -env I_MPI_DYNAMIC_CONNECTION=0 -env I_MPI_DEBUG 5 IMB-MPI1 pingpong
}

  
#first_setup
install_pkgs
#setup_shares
setup_hpc_user
setup_env
