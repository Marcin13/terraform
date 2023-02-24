#!/bin/bash
# Update package lists
sudo apt-get update
# Install Nginx
sudo apt-get install nginx -y
# Start Nginx
sudo systemctl start nginx
# Enable Nginx to start at boot time
sudo systemctl enable nginx

cd /var/www/html || exit

sudo rm index index.txt index.html index.htm index.nginx-debian.html
sudo touch index.txt
sudo chown ubuntu:ubuntu index.txt
EC2_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
EC2_AVAIL_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
IP_ADDRESS=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
SECURITY_GROUPS=$(curl -s http://169.254.169.254/latest/meta-data/security-groups)
AMI_ID=$(curl -s http://169.254.169.254/latest/meta-data/ami-id)
LOCAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)



echo "<center><h1>Hello, from test page on port :${server_port} !!</center></h1>" > index.txt
# shellcheck disable=SC2129
echo '<left><h2> The Instance <i>ID</i> of this Amazon EC2 instance is: EC2_ID </h2></left>' >> index.txt
echo '<left><h2> The Instance placement <i>AZ</i> is: EC2_AVAIL_ZONE </h2></left>' >> index.txt
echo '<left><h2> The Instance <i>ipv4</i> address is: IP_ADDRESS </h2></left>' >> index.txt
echo '<left><h2> The Instance <i>security groups</i> is: SECURITY_GROUPS </h2></left>' >> index.txt
echo '<left><h2> The Instance <i>AMI ID</i> is: AMI_ID </h2></left>' >> index.txt
echo '<left><h2> The Instance <i>Private IP</i> address is: LOCAL_IP </h2></left>' >> index.txt


sed -i "s/EC2_ID/$EC2_ID/" index.txt
sed -i "s/EC2_AVAIL_ZONE/$EC2_AVAIL_ZONE/" index.txt
sed -i "s/IP_ADDRESS/$IP_ADDRESS/" index.txt
sed -i "s/SECURITY_GROUPS/$SECURITY_GROUPS/" index.txt
sed -i "s/AMI_ID/$AMI_ID/" index.txt
sed -i "s/LOCAL_IP/$LOCAL_IP/" index.txt
sed -i "s/EC2_AVAIL_ZONE/$EC2_AVAIL_ZONE/" index.txt

sudo rm index.html
cp index.txt index.html

sudo nginx -s reload
