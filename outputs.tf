output "flask_server_public_ip" {
  description = "Public IP of the Flask server"
  value       = aws_instance.flask_server.public_ip
}
