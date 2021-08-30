provider "aws" {
  region     = "eu-central-1"
}

resource "aws_instance" "nginx-proxy" {
  ami                    = "ami-0453cb7b5f2b7fca2"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.nginx-proxy.id]
  key_name               = "keys1"
  user_data              = <<EOF
#!/bin/bash
yum install openssl-devel gcc -y && mkdir  -p /web/nginx/{modules,run,binaries} && cd /web/nginx/ && wget https://nginx.org/download/nginx-1.19.9.tar.gz && tar  -xzvf nginx-1.19.9.tar.gz && mv nginx-1.19.9/* binaries/ && rm  -rf nginx-1.19.9/ && cd binaries/ && ./configure --prefix=/web/nginx --modules-path=/web/nginx/modules --with-http_ssl_module  --without-http_fastcgi_module --without-http_uwsgi_module --without-http_grpc_module --without-http_scgi_module --without-mail_imap_module --without-mail_pop3_module --with-http_auth_request_module && make && make install && cd .. && rm -rf binaries

echo "user  root;
pid        run/nginx.pid;" >> /web/nginx/conf/nginx.conf

echo "
[Unit]
Description=nginx - high performance web server
Documentation=http://nginx.org/en/docs/
After=network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target
[Service]
User=root
Group=root
Type=forking
PIDFile=/web/nginx/run/nginx.pid
ExecStart=/web/nginx/sbin/nginx -c /web/nginx/conf/nginx.conf
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s TERM $MAINPID
[Install]
WantedBy=multi-user.target
" > /usr/lib/systemd/system/nginx.service

systemctl daemon-reload && systemctl restart nginx.service && systemctl enable nginx.service
EOF
  tags = {
    Name = "Nginx Reverse Proxy"
  }
}

resource "aws_security_group" "nginx-proxy" {
  name = "Nginx Reverse Proxy SG"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
