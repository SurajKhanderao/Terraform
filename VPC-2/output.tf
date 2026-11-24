output "baston_public_ip" {

    value = aws_instance.baston.public_ip
  
}

output "private_ec2_ip" {
    value = [ aws_instance.private-ec2.private_dns, aws_instance.private-ec2.private_ip]
}