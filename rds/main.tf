#VPC

resource "aws_vpc" "my_vpc" {

  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "my_vpc"
  }

}

#internet_gateway

resource "aws_internet_gateway" "igw" {

  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "my_igw"
  }
}

#public_Subnet-1a

resource "aws_subnet" "public_subnet_1a" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_1a"
  }
}

#Private_subnet-1a
resource "aws_subnet" "private_subnet_1a" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-1a"
  tags = {
    Name = "pribate_subnet_1a"
  }
}

#Private_subnet-1b

resource "aws_subnet" "private_subnet_1b" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-1b"
  tags = {
    Name = "private_subnet_1b"
  }
}

#EIP
resource "aws_eip" "nat_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]
  tags = {
    Name = "nat_eip"
  }
}

#NAT
resource "aws_nat_gateway" "nat" {
  subnet_id     = aws_subnet.public_subnet_1a.id
  allocation_id = aws_eip.nat_eip.id
  tags = {
    Name = "my_nat"
  }
}

#Route_Tables

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "public_rt"
  }

  route {

    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

#public_rt_associate
resource "aws_route_table_association" "public_rt_associate" {
  subnet_id      = aws_subnet.public_subnet_1a.id
  route_table_id = aws_route_table.public_rt.id
}

#Private_rt
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "private_rt"
  }

  route {

    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

#Private_rt_association

resource "aws_route_table_association" "private_rt-associate_1a" {
  subnet_id      = aws_subnet.private_subnet_1a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rt-associate_1b" {
  subnet_id      = aws_subnet.private_subnet_1b.id
  route_table_id = aws_route_table.private_rt.id
}

#Public_Security_group

resource "aws_security_group" "public_sg" {
  vpc_id = aws_vpc.my_vpc.id
  name   = "public_sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public_sg"
  }

}

#private_sg
resource "aws_security_group" "app_sg" {
  vpc_id = aws_vpc.my_vpc.id
  name   = "app_sg"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app_sg"
  }

}

#Public_instance
resource "aws_instance" "bastion" {
  ami                         = "ami-04060762724eee84a"
  instance_type               = "t3.micro"
  key_name                    = "Suraj"
  subnet_id                   = aws_subnet.public_subnet_1a.id
  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "bastion"
  }

}

#Private_instance
resource "aws_instance" "private_ec2" {
  ami                    = "ami-04060762724eee84a"
  instance_type          = "t3.micro"
  key_name               = "Suraj"
  subnet_id              = aws_subnet.private_subnet_1a.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  tags = {
    Name = "private_ec2"
  }
}


#Rds

#RDS_sunetGroups

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "rds_subnet_group"
  subnet_ids = [aws_subnet.private_subnet_1a.id, aws_subnet.private_subnet_1b.id]

  tags = {
    Name = "rds_subnet_group"
  }
}


#database_sg
resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.my_vpc.id
  name   = "rds_sg"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds_sg"
  }

}

#Rds_db
resource "aws_db_instance" "test_db_instance" {

  identifier     = "test-instance"
  engine         = "mysql"
  engine_version = "8.0"

  instance_class    = "db.t4g.micro"
  allocated_storage = 20
  storage_type      = "gp2"
  storage_encrypted = true

  db_name  = "test_db"
  username = "suraj"
  password = "Suraj12345"
  port     = "3306"

  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = false

  multi_az = false

  skip_final_snapshot = true

  tags = {
    Name = "test_db"
  }
}







