#!/bin/bash

wait
cd /home/ubuntu || exit
wait
sudo touch index.html
sudo chown ubuntu:ubuntu index.html
cat > index.html <<-EOF
<h1>Hello, World</h1>
<p>Instance AZ : ${az}</p>
<p>Serwer port: ${server_port}</p>
<p>Public ip: ${ip}</p>
EOF

nohup busybox httpd -f -p "${server_port}" &