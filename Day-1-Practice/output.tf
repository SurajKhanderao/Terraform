output "instance_id" {
  value = aws_instance.my_instance[*].id
}

output "instance_name" {
  value = aws_instance.my_instance[*].tags.Name
}