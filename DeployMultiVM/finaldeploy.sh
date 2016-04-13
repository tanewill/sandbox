#!/bin/bash
wget https://raw.githubusercontent.com/tanewill/sandbox/Ubuntu/DeployMultiVM/localDeploy.sh
chmod +x localDeploy.sh
runuser -l azureuser -c 'localDeploy.sh'
