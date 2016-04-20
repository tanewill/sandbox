#place holder for 7.1 script
yum install -y epel-release
yum install -y nmap sshpass
nmap -sn 10.0.0.* | grep 10.0.0. | awk '{print $5}' > nodenames.txt
