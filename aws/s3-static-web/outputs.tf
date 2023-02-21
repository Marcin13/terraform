output "Click_link_to_enter_s3_static_web_---X" {
  value       = "http://${aws_s3_bucket_website_configuration.website_example.website_endpoint}"
  description = "Website end point"
}