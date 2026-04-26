resource "aws_default_vpc" "default" {}

resource "aws_security_group" "flask_sg" {
  name   = "flask-sg"
  vpc_id = aws_default_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2-ecr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = "us-east-1a"

  tags = {
    Name = "Default subnet for us-east-1a"
  }
}

resource "aws_iam_role_policy_attachment" "ssm_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_instance" "flask_ec2" {
  ami                  = "ami-098e39bafa7e7303d"
  instance_type        = "t3.micro"
  subnet_id            = aws_default_subnet.default_az1.id
  vpc_security_group_ids = [aws_security_group.flask_sg.id]
  # key_name             = "flask-keypair"
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
            #!/bin/bash
            yum update -y

            # install docker
            yum install docker -y
            systemctl start docker
            systemctl enable docker

            # install SSM agent
            yum install -y amazon-ssm-agent
            systemctl enable amazon-ssm-agent
            systemctl start amazon-ssm-agent

            # login to ECR
            aws ecr get-login-password --region us-east-1 | \
            docker login --username AWS --password-stdin 474150620111.dkr.ecr.us-east-1.amazonaws.com

            # pull & run app
            docker pull 474150620111.dkr.ecr.us-east-1.amazonaws.com/flask-app:latest

            docker run -d -p 80:5000 --name flask-app \
            474150620111.dkr.ecr.us-east-1.amazonaws.com/flask-app:latest
            EOF

  tags = {
    Name = "Flask-App-EC2"
  }
}
