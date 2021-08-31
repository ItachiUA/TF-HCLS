provider "aws" {
  region = "eu-central-1"
}
resource "aws_instance" "picture-bot" {
  ami                    = "ami-0453cb7b5f2b7fca2"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.picture-py-bot.id]
  key_name               = "keys1"
  user_data              = <<EOF
#!/bin/bash
mkdir /docker
chown ec2-user.ec2-user /docker
cd /docker && yum install docker* -y
usermod -a -G docker ec2-user
systemctl start docker
systemctl enable docker
wget https://github.com/ItachiUA/pic-py-bot/raw/main/Dockerfile.yml -O /docker/Dockerfile.yml
docker build -t pic-py-bot:latest -f /docker/Dockerfile.yml .
docker run -d $( docker images | grep pic | awk '{print $3}')
EOF
  tags = {
    Name = "Picture py-bot"
  }
}

resource "aws_security_group" "picture-py-bot" {
  name = "Picture py-bot SG"
  ingress {
    from_port   = 22
    to_port     = 22
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
    from_port   = 80
    to_port     = 80
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
