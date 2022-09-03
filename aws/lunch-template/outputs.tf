output "ID_of_the_launch_template" {
  description = "ID of the launch template"
  value       = aws_launch_template.my_LT.id
}

output "Name_of_the_LT" {
  description = "Name of the launch template"
  value       = aws_launch_template.my_LT.name
}
