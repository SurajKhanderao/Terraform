#Create vpc
resource "aws_vpc" "demo_vpc" {
  cidr_block = "192.168.0.0/16"
  tags = {
    Name = "my_vpc"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.demo_vpc.id
  tags = {
    Name = "demo_igw"
  }
}

resource "aws_subnet" "public_subnet-1" {
  vpc_id            = aws_vpc.demo_vpc.id
  cidr_block        = "192.168.0.0/24"
  availability_zone = "eu-west-1a"
  tags = {
        Name = "public_subnet-1"
    }
}

resource "aws_subnet" "private_subnet-1"{

    vpc_id            = aws_vpc.demo_vpc.id
    cidr_block        = "192.168.1.0/24"
    availability_zone = "eu-west-1a"
    tags = {
        Name = "private_subnet-1"
    }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.demo_vpc.id

  tags = {
    Name = "public_route_table"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet-1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_eip" "nat_eip"{
    domain = "vpc"
    depends_on = [aws_internet_gateway.my_igw]
    tags = {
        Name = "nat_eip"
    }
}

resource "aws_nat_gateway" "nat_gw" {
    allocation_id = aws_eip.nat_eip.id
    subnet_id     = aws_subnet.public_subnet-1.id
    tags = {
        Name = "nat_gw"
    }
}

resource "aws_route_table" "private_route_table" {
    vpc_id = aws_vpc.demo_vpc.id

    tags = {
        Name = "private_route_table"
    }

    route {
        cidr_block     = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat_gw.id
    }
}

resource "aws_route_table_association" "private_subnet_association" {
    subnet_id      = aws_subnet.private_subnet-1.id
    route_table_id = aws_route_table.private_route_table.id
}

#security group for public subnet
resource "aws_security_group" "public_sg" {
    name        = "public_sg"
    description = "Allow SSH and HTTP traffic"
    vpc_id      = aws_vpc.demo_vpc.id

    ingress {
        from_port   = 22
        to_port     = 22
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
    tags = {
        Name = "public_sg"
    }   
}

#private security group
resource "aws_security_group" "private_sg" {
    name        = "private_sg"
    description = "Allow SSH and HTTP traffic"
    vpc_id      = aws_vpc.demo_vpc.id

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        security_groups = [aws_security_group.public_sg.id]
    }
    
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "private_sg"
    }   
}

resource "aws_instance" "public_instance" {
    ami           = "ami-04060762724eee84a"
    instance_type = "t3.micro"
    subnet_id     = aws_subnet.public_subnet-1.id
    vpc_security_group_ids = [aws_security_group.public_sg.id]
    associate_public_ip_address = true
    key_name = "Suraj"
    tags = {   
        Name = "public_instance"
    }
}

resource "aws_instance" "private_instance" {
    ami           = "ami-04060762724eee84a"
    instance_type = "t3.micro"
    subnet_id     = aws_subnet.private_subnet-1.id
    vpc_security_group_ids = [aws_security_group.private_sg.id]
    key_name = "Suraj"
    tags = {   
        Name = "private_instance"
    }
}
