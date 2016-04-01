#!/bin/bash

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
test_deploy()
{
    cd ~
    touch hello
    touch `date +"%Y%m%d@%H:%M:%S"`
}

install_of()
{
        
    yum -y groupinstall 'Development Tools' 
    yum -y install openmpi openmpi-devel zlib-devel gstreamer-plugins-base-devel \
    libXext-devel libGLU-devel libXt-devel libXrender-devel libXinerama-devel libpng-devel \
    libXrandr-devel libXi-devel libXft-devel libjpeg-turbo-devel libXcursor-devel \
    readline-devel ncurses-devel python python-devel cmake qt-devel qt-assistant \
    mpfr-devel gmp-devel
     
    #This one is useful, but not crucial
    yum -y upgrade
    
    rpm -Uvh http://download.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
 
    #disable the EPEL repository from being turned on by default
    sed -i -e 's/enabled=1/enabled=0/' /etc/yum.repos.d/epel.repo
     
    #now install the packages we need from EPEL
    yum -y install --enablerepo=epel qtwebkit-devel
    su azureuser
    
    cd ~
    mkdir OpenFOAM
    cd OpenFOAM
    wget "http://downloads.sourceforge.net/foam/OpenFOAM-3.0.0.tgz?use_mirror=mesh" -O OpenFOAM-3.0.0.tgz
    wget "http://downloads.sourceforge.net/foam/ThirdParty-3.0.0.tgz?use_mirror=mesh" -O ThirdParty-3.0.0.tgz
     
    tar -xzf OpenFOAM-3.0.0.tgz 
    tar -xzf ThirdParty-3.0.0.tgz
    
    sed -i -e 's=boost-system=boost_1_55_0=' OpenFOAM-3.0.0/etc/config/CGAL.sh
    
    #forcefully load Open-MPI into the environment
    #the export command has been reported as needed due to the 
    #module not being available in a clean installation
    module load mpi/openmpi-x86_64 || export PATH=$PATH:/usr/lib64/openmpi/bin
    
    source $HOME/OpenFOAM/OpenFOAM-3.0.0/etc/bashrc
    source $HOME/OpenFOAM/OpenFOAM-3.0.0/etc/bashrc WM_LABEL_SIZE=64
    echo "alias of300='module load openmpi-x86_64; source $HOME/OpenFOAM/OpenFOAM-3.0.0/etc/bashrc $FOAM_SETTINGS'" >> $HOME/.bashrc
    
    of300
    
    cd $WM_THIRD_PARTY_DIR
    wget "https://raw.github.com/wyldckat/scripts4OpenFOAM3rdParty/master/getBoost"
    chmod +x get*
    sed -i -e 's=boost_1_54_0=boost_1_55_0=' getBoost
    ./getBoost
    sed -i -e 's=boost-system=boost_1_55_0=' makeCGAL
    
    # This next command will take a little while...
    ./makeCGAL > mkcgal.log 2>&1
     
    #update the shell environment
    wmSET $FOAM_SETTINGS
    
    cd $WM_PROJECT_DIR
    
    ./Allwmake -j 4 > make.log 2>&1
    
    ./Allwmake -j 4 > make.log 2>&1
    
    icoFoam -help
    
    cd $WM_THIRD_PARTY_DIR
    ./makeParaView4 -qmake $(which qmake-qt4) -mpi -python > log.makePV 2>&1
    
    cd $FOAM_UTILITIES/postProcessing/graphics/PV4Readers 
    wmSET $FOAM_SETTINGS
    ./Allwclean 
    ./Allwmake
    
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

install_pkgs
test_deploy
#setup_shares
#setup_hpc_user
#setup_env


