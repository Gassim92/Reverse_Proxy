#!/bin/bash
sudo apt-get update
sudo apt-get -y install nginx
sudo ufw allow "Nginx Full"
sudo systemctl start nginx
sudo systemctl enable nginx
sudo unlink /etc/nginx/sites-enabled/default

# Retrieve VM private IP addresses from the Terraform output
vm_private_ips=$(terraform output -raw websrv_ip_addresses)

# Use the retrieved private IPs in the rest of the script
web_server_1_address="${vm_private_ips[0]}"
web_server_2_address="${vm_private_ips[1]}"

# Nginx configuration
sudo tee /etc/nginx/sites-available/webserver.conf > /dev/null << EOF
# Upstream configuration for load balancing
upstream backend {
    least_conn;
    server ${web_server_1_address};
    server ${web_server_2_address};
}

server {
    listen 80;
    server_name _;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name _;

    ssl_certificate /etc/nginx/ssl/nginx.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx.key;

    location / {
        proxy_set_header Host \$host;
        proxy_pass http://backend;
    }
}
EOF

# Create a symbolic link and restart Nginx
sudo ln -s /etc/nginx/sites-available/webserver.conf /etc/nginx/sites-enabled/webserver.conf
sudo systemctl restart nginx

# Create SSL certificate : 
sudo mkdir -p /etc/nginx/ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=FR/ST=Nord/L=Lille/O=Simplon/CN=mgk-project.com"
