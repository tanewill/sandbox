#!/bin/bash
wget https://raw.githubusercontent.com/tanewill/tanewill/sandbox/DeployMultiVM/localDeploy.sh
chmod +x localDeploy.sh
runuser -l azureuser -c 'localDeploy.sh'
