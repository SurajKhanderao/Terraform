resource "aws_vpc" "dev_vpc" {
  
  cidr_block = var.vpc_cidr
  tags = {
    Name = "dev_vpc"
  }
}

resource "aws_internet_gateway" "igw" {

    vpc_id = aws_vpc.dev_vpc.id
    tags = {
      Name = var.igw_name
    }
}

resource "aws_subnet" "public_subnet-1a" {

    vpc_id = aws_vpc.dev_vpc.id
    availability_zone = "${var.region}a"
    cidr_block = var.public_subnet_cider
    map_public_ip_on_launch = true

    tags = {
      Name = var.public_subnet_name
    }
}

resource "aws_subnet" "private_subnet-1a" {

    vpc_id = aws_vpc.dev_vpc.id
    availability_zone = "${var.region}a"
    cidr_block = var.private_subnet_cider

    tags =  {
        Name = var.private_subnet_name
    }
  
}

resource "aws_eip" "nat_eip" {

    domain = "vpc"
    depends_on = [ aws_internet_gateway.igw ]
    tags = {
      Name = var.nat_eip_tag
    }
  
}

resource "aws_nat_gateway" "nat" {

    subnet_id = aws_subnet.public_subnet-1a.id
    allocation_id = aws_eip.nat_eip.id
    tags = {
        Name = var.nat_name
    }
  
}


resource "aws_route_table" "public_rt" {

    vpc_id = aws_vpc.dev_vpc.id
    tags = {
      Name = var.public_rt_name
    }

    route {
        
         cidr_block = "0.0.0.0/0"
         gateway_id = aws_internet_gateway.igw.id

    }
  
}

#Public Subnet Association

resource "aws_route_table_association" "public_rt_associate" {

    subnet_id = aws_subnet.public_subnet-1a.id
    route_table_id = aws_route_table.public_rt.id
  
}

#private_RT

resource "aws_route_table" "private_rt" {

    vpc_id = aws_vpc.dev_vpc.id
    tags = {
       Name = var.private_rt_name
    }

    route {
         cidr_block     = "0.0.0.0/0"
        nat_gateway_id  = aws_nat_gateway.nat.id
    }
}

#Private_subnet_association

resource "aws_route_table_association" "privte_rt_associate" {

    subnet_id = aws_subnet.private_subnet-1a.id
    route_table_id = aws_route_table.private_rt.id
  
}

#security Groups

resource "aws_security_group" "public-sg" {

    vpc_id = aws_vpc.dev_vpc.id
    name = var.public_sg

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        self = true
    }

    egress  {

        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]

    }

    tags = {
      Name = var.public_sg
    }

}

#Private_sg

resource "aws_security_group" "private-sg" {

    vpc_id = aws_vpc.dev_vpc.id
    name = var.private_sg

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        security_groups = [aws_security_group.public-sg.id]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = var.private_sg
    }
  
}

#Public_ec2
resource "aws_instance" "baston" {

    ami = var.ami_id
    instance_type = var.instance_type
    key_name = var.key

    subnet_id = aws_subnet.public_subnet-1a.id
    availability_zone = "${var.region}a"
    vpc_security_group_ids = [aws_security_group.public-sg.id]
    associate_public_ip_address = true

    tags = {
        Name = var.public_iname
    }

}

#Private_ec2

resource "aws_instance" "private-ec2" {

    ami = var.ami_id
    instance_type = var.instance_type
    key_name = var.key

    subnet_id = aws_subnet.private_subnet-1a.id
    availability_zone = "eu-west-1a"
    vpc_security_group_ids = [aws_security_group.private-sg.id]
    associate_public_ip_address = true

    tags = {
      Name = var.private_iname
    }
}






