#!/bin/bash

cat > index.html <<EOF
<h1>Hello, World</h1>
<p>DB address: ${server_port}</p>
<p>availability_zone: ${az}</p>
EOF

nohup busybox httpd -f -p ${server_port} &