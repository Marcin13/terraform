#!/bin/bash

cat > index.html <<EOF
<h1>Hello, World</h1>
<p>Server port: ${server_port}</p>
<p><i>Thank you</i></p>
EOF

nohup busybox httpd -f -p ${server_port} &