# Create a VPC
resource "aws_vpc" "joy" {
  cidr_block = "10.0.0.0/16"


  tags = {
    Name = "Joy VPC"
  }
}


resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.joy.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "joy_private_subnet"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.joy.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "joy_public_subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.joy.id

  tags = {
    Name = "joy IG"
  }
}


resource "aws_route_table" "joy_RT" {
  vpc_id = aws_vpc.joy.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "joy_RT"
  }
}

resource "aws_route_table_association" "private_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.joy_RT.id
}

resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.joy_RT.id
}


resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.joy.id

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = aws_vpc.joy.cidr_block
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

