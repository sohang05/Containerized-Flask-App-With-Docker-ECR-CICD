output "jenkins_url" {
  value = "http://${aws_eip.jenkins_eip.public_ip}:8080"
}

output "flask_url" {
  value = "http://${aws_eip.flask_eip.public_ip}"
}
