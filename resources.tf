provider "aws" {
  region = var.region
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_blocks.vpc
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "vpc"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.cidr_blocks.subnet
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.cidr_blocks.global
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "rt"
  }
}

resource "aws_route_table_association" "a" {
  route_table_id = aws_route_table.rt.id
  subnet_id      = aws_subnet.subnet.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw"
  }
}

resource "aws_security_group" "sg" {
  name   = "sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_cidr_block]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = aws_ec2_client_vpn_network_association.vpn.security_groups
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidr_blocks.global]
  }
  tags = {
    Name = "sg"
  }
}

resource "aws_instance" "myinstance" {
  ami                         = var.instance_info.ami
  instance_type               = var.instance_info.instance_type
  vpc_security_group_ids      = [aws_security_group.sg.id]
  subnet_id                   = aws_subnet.subnet.id
  key_name                    = var.ssh_keyname
  associate_public_ip_address = true

  tags = {
    Name = "myinstance"
  }
}


resource "aws_ec2_client_vpn_endpoint" "vpn" {
  description            = "client vpn endpoint test"
  server_certificate_arn = data.aws_acm_certificate.server_certificate.arn
  client_cidr_block      = var.cidr_blocks.client_vpn
  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = data.aws_acm_certificate.client_certificate.arn
  }
  connection_log_options {
    enabled = false
  }
  tags = {
    Name = "vpn"
  }
}

resource "aws_ec2_client_vpn_network_association" "vpn" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  subnet_id              = aws_subnet.subnet.id
}
