
variable "region" {
  type = string
}

#vpc
variable "vpc_cidr" {
  type = string
}

variable "vpc_tag" {
  type = string
}

#IGW
variable "igw_name" {
  type = string
}

#Public_subnet
variable "public_subnet_name"{
  type =string
}

variable "public_subnet_cider" {
  type = string
}

#private_subnet
variable "private_subnet_name" {
  type =string
}

variable "private_subnet_cider" {
  type = string
}

#EIP
variable "nat_eip_tag"{
  type = string
}

#NAT
variable "nat_name" {
  type = string
}

#public_RT

variable "public_rt_name" {
    type = string
  
}

#privateRT

variable "private_rt_name" {
    type = string
  
}

#Public_SG

variable "public_sg" {
    type = string
  
}

#Private_SG

variable "private_sg" {
    type = string
  
}


#Instance_details

variable "ami_id" {
  type = string
}

variable "instance_type" {
   type = string
}

variable "key" {
    type = string
  
}

#public_ec2
variable "public_iname" {
  type = string
}

#private_ec2

variable "private_iname" {
  type = string
}





