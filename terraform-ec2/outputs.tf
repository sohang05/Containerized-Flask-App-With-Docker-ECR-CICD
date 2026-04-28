output "flask_ec2_public_ip" {
  value = aws_instance.flask_ec2.public_ip
}

output "jenkins_ec2_public_ip" {
    value = aws_instance.jenkins_ec2.public_ip  
}
