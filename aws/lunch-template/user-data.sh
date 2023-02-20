#!/bin/bash

wait
cd /home/ubuntu || exit
wait
sudo touch index.txt
sudo chown ubuntu:ubuntu index.txt
EC2_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
EC2_AVAIL_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
IP_ADDRESS=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
SECURITY_GROUPS=$(curl -s http://169.254.169.254/latest/meta-data/security-groups)
AMI_ID=$(curl -s http://169.254.169.254/latest/meta-data/ami-id)
LOCAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
INTERFACE=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/)
SUBNET_ID=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/${INTERFACE}/subnet-id)

echo '<center><h1>Hello, from test page!</center></h1>' > index.txt
# shellcheck disable=SC2129
echo '<h2>This instance is in the subnet wih ID: SUBNET_ID</h2>' >> index.txt
# shellcheck disable=SC2129
echo '<left><h2> The Instance <i>ID</i> of this Amazon EC2 instance is: EC2_ID </h2></left>' >> index.txt
echo '<left><h2> The Instance placement <i>AZ</i> is: EC2_AVAIL_ZONE </h2></left>' >> index.txt
echo '<left><h2> The Instance <i>ipv4</i> address is: IP_ADDRESS </h2></left>' >> index.txt
echo '<left><h2> The Instance <i>security groups</i> is: SECURITY_GROUPS </h2></left>' >> index.txt
echo '<left><h2> The Instance <i>AMI ID</i> is: AMI_ID </h2></left>' >> index.txt
echo '<left><h2> The Instance <i>Local IP</i> address is: LOCAL_IP </h2></left>' >> index.txt


sed -i "s/EC2_ID/$EC2_ID/" index.txt
sed "s/SUBNET_ID/$SUBNET_ID/" index.txt
sed -i "s/EC2_AVAIL_ZONE/$EC2_AVAIL_ZONE/" index.txt
sed -i "s/IP_ADDRESS/$IP_ADDRESS/" index.txt
sed -i "s/SECURITY_GROUPS/$SECURITY_GROUPS/" index.txt
sed -i "s/AMI_ID/$AMI_ID/" index.txt
sed -i "s/LOCAL_IP/$LOCAL_IP/" index.txt
sed -i "s/EC2_AVAIL_ZONE/$EC2_AVAIL_ZONE/" index.txt

cp index.txt index.html

 nohup busybox httpd -f -p 8080 &
