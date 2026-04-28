resource "aws_default_vpc" "default" {}

# ---------------- SECURITY GROUP - FLASK APP ----------------
resource "aws_security_group" "flask_sg" {
  name   = "flask-sg"
  vpc_id = aws_default_vpc.default.id

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

# ---------------- IAM ROLE ----------------
resource "aws_iam_role" "ec2_role" {
  name = "ec2-ecr-ssm-role"

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

# ECR READ ACCESS
resource "aws_iam_role_policy_attachment" "ecr_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# SSM ACCESS (IMPORTANT FOR SSM DEPLOYMENT)
resource "aws_iam_role_policy_attachment" "ssm_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# ---------------- SUBNET ----------------
resource "aws_default_subnet" "default_az1" {
  availability_zone = "us-east-1a"
}

# ---------------- FLASK EC2 ----------------
resource "aws_instance" "flask_ec2" {
  ami                    = "ami-098e39bafa7e7303d"
  instance_type          = "t3.small"
  associate_public_ip_address = true
  subnet_id              = aws_default_subnet.default_az1.id
  vpc_security_group_ids = [aws_security_group.flask_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
#!/bin/bash
yum update -y

# Install Docker
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

# Install AWS CLI
yum install -y awscli

# Install SSM agent
yum install -y amazon-ssm-agent
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 474150620111.dkr.ecr.us-east-1.amazonaws.com

# Pull and run app
docker pull 474150620111.dkr.ecr.us-east-1.amazonaws.com/flask-app:latest

docker run -d -p 80:5000 --name flask-app 474150620111.dkr.ecr.us-east-1.amazonaws.com/flask-app:latest
EOF

  tags = {
    Name = "Flask-App-EC2"
  }
}

# ---------------- JENKINS SECURITY GROUP ----------------
resource "aws_security_group" "jenkins_sg" {
  name   = "jenkins-sg"
  vpc_id = aws_default_vpc.default.id

  # Jenkins UI
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH (optional but useful)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------------- JENKINS EC2 ----------------

resource "aws_instance" "jenkins_ec2" {
  ami                         = "ami-098e39bafa7e7303d" 
  instance_type               = "t3.small"
   root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  associate_public_ip_address = true
  subnet_id                   = aws_default_subnet.default_az1.id
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
#!/bin/bash
sudo yum update -y

sudo yum install -y git

sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/rpm-stable/jenkins.repo


sudo rpm --import https://pkg.jenkins.io/rpm-stable/jenkins.io-2026.key

sudo yum upgrade

sudo yum install java-21-amazon-corretto -y

sudo yum install jenkins -y

sudo systemctl enable jenkins

sudo systemctl start jenkins

sudo cat /var/lib/jenkins/secrets/initialAdminPassword

# Install Docker
sudo yum install -y docker

# Start and enable Docker
systemctl enable docker
systemctl start docker

# Add users to Docker group
usermod -aG docker ec2-user
usermod -aG docker jenkins

# Install AWS CLI v2
cd /tmp
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
apt-get install -y unzip
unzip -o awscliv2.zip
./aws/install
EOF

  tags = {
    Name = "Jenkins-Server"
  }
}
