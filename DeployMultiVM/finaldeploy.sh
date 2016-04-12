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
    
setup_hpc_user()
{
    # disable selinux
    #sed -i 's/enforcing/disabled/g' /etc/selinux/config
    #setenforce permissive
    
    groupadd -g $HPC_GID $HPC_GROUP

    # Don't require password for HPC user sudo
    echo "$HPC_USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
    
    # Disable tty requirement for sudo
    sed -i 's/^Defaults[ ]*requiretty/# Defaults requiretty/g' /etc/sudoers

    
    useradd -c "HPC User" -g $HPC_GROUP -d $SHARE_HOME/$HPC_USER -s /bin/bash -u $HPC_UID $HPC_USER
    
}

#install_pkgs
#setup_shares
#setup_hpc_user
#setup_env
