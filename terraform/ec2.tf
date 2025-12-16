resource "aws_key_pair" "mykeypair" {
  key_name = "microsvc-proj"
  public_key = file("microsvc-proj-keypair.pub")
}

resource "aws_default_vpc" "myvpc" {
  tags={
    Name="myvpc"
  }
}

resource "aws_security_group" "mysg" {
   name = "microsvc-proj-sg"
   description = "This is basically my microsvc-proj sg"

   ingress {
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "tcp"
    description = "Port 22 open for sg"
   }
   ingress {
    from_port = 80
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
    description = "Port 80 open for sg"
    protocol = "tcp"
   }

   ingress {
     from_port = 443
     to_port = 443
     cidr_blocks = ["0.0.0.0/0"]
     protocol = "tcp"
     description = "Port 443 open for this sg"
   }

   ingress {
    from_port = 8080
    to_port = 8080
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "tcp"
    description = "Port 8080 open for this sg"
   }
   ingress {
    from_port = 9000
    to_port = 9000
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "tcp"
    description = "Port 9000 open for this sg"
   }

   ingress {
    from_port = 5000
    to_port = 5000
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "tcp"
    description = "Port 5000 open for this sg"
   }

   egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    description = "This is my sg outbound rules"
    cidr_blocks = ["0.0.0.0/0"]
   }
   
   tags = {
     Name="microsvc-proj-sg"
   }
}

resource "aws_instance" "myinstance" {
  key_name = aws_key_pair.mykeypair.key_name
  security_groups = [aws_security_group.mysg.name]
  instance_type = "t2.medium"
  ami = var.aws-ami
  root_block_device {
    volume_size = var.aws-volume_size
    volume_type = "gp3"
  }

  tags = {
    Name="microsvc-proj"
  }
}