output "app_url" {
  description = "The URL of the application"
  value       = aws_apprunner_service.private_ecr_example.service_url
}