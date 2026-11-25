output "baston_ip" {
  value = aws_instance.bastion.public_ip
}

output "private-ec2_ip" {
  value = aws_instance.private_ec2.private_ip
}

output "rds_endpoint" {
  value = aws_db_instance.test_db_instance.endpoint
}