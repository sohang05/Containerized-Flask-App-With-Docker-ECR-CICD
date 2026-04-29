# Docker-ECR-CI/CD Flask Application

**A Production-Ready Containerized Flask App with AWS ECR and Jenkins CI/CD Pipeline**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Python: 3.10+](https://img.shields.io/badge/Python-3.10+-blue.svg)](https://www.python.org/downloads/)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker)](https://www.docker.com/)
[![AWS](https://img.shields.io/badge/AWS-ECR-FF9900?logo=amazonaws)](https://aws.amazon.com/ecr/)
[![Jenkins](https://img.shields.io/badge/Jenkins-Pipeline-D24939?logo=jenkins)](https://www.jenkins.io/)

---

## 📋 Table of Contents

- [Project Overview](#project-overview)
- [Architecture Diagram](#architecture-diagram)
- [Tech Stack](#tech-stack)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Step-by-Step Setup](#step-by-step-setup)
- [Local Development](#local-development)
- [CI/CD Pipeline](#cicd-pipeline)
- [AWS Deployment](#aws-deployment)
- [Monitoring & Troubleshooting](#monitoring--troubleshooting)
- [Important Security Notes](#important-security-notes)
- [What NOT to Commit to GitHub](#what-not-to-commit-to-github)
- [Improvements & Enhancements](#improvements--enhancements)
- [Contributing](#contributing)
- [License](#license)
- [Resources](#resources)

---

## Project Overview

This project demonstrates a **professional DevOps workflow** for containerized applications. It showcases:

✅ **Flask Web Application** - Simple Python web app with UI  
✅ **Docker Containerization** - Multi-stage builds for optimization  
✅ **AWS ECR** - Container image registry with IAM integration  
✅ **Jenkins CI/CD** - Automated build, test, and deployment pipeline  
✅ **Infrastructure as Code** - Terraform for EC2 provisioning  
✅ **AWS SSM** - Secure, agent-based deployment  
✅ **Security Best Practices** - Non-root containers, IAM roles, encrypted credentials  

### Perfect For

- 🎯 **Learning** DevOps and cloud engineering
- 💼 **Portfolio Projects** - Show interviewers your skills
- 🏢 **Production Reference** - Patterns applicable to real systems
- 📚 **Team Documentation** - Clear, well-explained setup

---

## Architecture Diagram

```
┌──────────────────────────────────┐
│   Developer (Local Machine)      │
│  - Source code                   │
│  - Git push                      │
└──────────────────────────────────┘
              ↓ (Git webhook)
┌──────────────────────────────────┐
│   Jenkins CI/CD Server (EC2)     │
│  ├─ Build Docker Image           │
│  ├─ Tag & Push to ECR            │
│  ├─ Deploy to Flask EC2          │
│  └─ Run Tests                    │
└──────────────────────────────────┘
              ↓
┌──────────────────────────────────┐
│   AWS ECR (Image Registry)       │
│  - flask-app:latest              │
│  - flask-app:v1.0.0              │
│  - Image scanning enabled        │
└──────────────────────────────────┘
              ↓
┌──────────────────────────────────┐
│   Flask App EC2 Instance         │
│  - Docker container running      │
│  - Port 80 (HTTP)                │
│  - Elastic IP for access         │
└──────────────────────────────────┘
              ↓
┌──────────────────────────────────┐
│   Users / Applications           │
│  - http://<elastic-ip>           │
└──────────────────────────── ─────┘
```

**Data Flow:**
```
Code Push → Jenkins Webhook → Build → Push to ECR → Deploy to EC2 → Live
```

---

## Tech Stack

### Backend & Application

| Technology | Version | Purpose |
|------------|---------|---------|
| Python | 3.10+ | Programming language |
| Flask | 2.x | Web framework |
| Flask-SocketIO | Optional | WebSocket support |

### Containerization & Orchestration

| Technology | Version | Purpose |
|-----------|---------|---------|
| Docker | 20.10+ | Containerization |
| Docker Compose | 1.29+ | Local orchestration |

### Cloud & Infrastructure

| Technology | Service | Purpose |
|-----------|---------|---------|
| AWS EC2 | t3.small | Compute instances |
| AWS ECR | Private Registry | Container image storage |
| AWS IAM | Access Control | Permissions management |
| AWS SSM | Systems Manager | Remote command execution |
| AWS VPC | Networking | Security groups, subnets |

### CI/CD & Automation

| Technology | Version | Purpose |
|-----------|---------|---------|
| Jenkins | 2.387+ | CI/CD orchestration |
| Terraform | 1.4+ | Infrastructure as Code |
| Git | 2.36+ | Version control |
| Bash/PowerShell | Latest | Scripting |

---

## Prerequisites

### Local Development

- **Windows 10/11** or **macOS** or **Linux**
- **Git** ([Download](https://git-scm.com/))
- **Docker Desktop** ([Download](https://www.docker.com/products/docker-desktop))
  - Includes Docker Engine and Docker Compose
  - ≥ 4GB RAM allocation
- **Python 3.10+** (for local testing without Docker)
- **AWS CLI v2** ([Download](https://aws.amazon.com/cli/))
- **Terraform** ([Download](https://www.terraform.io/downloads))

### AWS Account

- ✅ Active AWS account
- ✅ IAM user with credentials (Access Key ID + Secret Access Key)
- ✅ Permissions:
  - EC2 (create/manage instances)
  - ECR (create repository, push images)
  - IAM (create roles/policies)
  - VPC (security groups)
  - SSM (send commands)

### Jenkins Setup

- ✅ Jenkins running (Docker container or on EC2)
- ✅ Plugins installed:
  - Pipeline
  - Docker Pipeline
  - Git
  - AWS Credentials
  - Credentials Binding

---

## Quick Start

### 1️⃣ Clone Repository

```bash
git clone https://github.com/yourusername/docker-ecr-project.git
cd docker-ecr-project
```

### 2️⃣ Local Testing with Docker Compose

```bash
# Start services
docker-compose up --build

# In another terminal, test
curl http://localhost:5000

# View logs
docker-compose logs -f web

# Stop
docker-compose down
```

### 3️⃣ Configure AWS Credentials

#### Using AWS CLI:
```bash
aws configure
# Enter:
# AWS Access Key ID: AKIA...
# AWS Secret Access Key: ...
# Default region: us-east-1
# Default output format: json
```

#### Using Environment Variables (CI/CD):
```bash
export AWS_ACCESS_KEY_ID="AKIA..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_DEFAULT_REGION="us-east-1"
```

### 4️⃣ Build & Push Image to ECR

```bash
# Create ECR repository (one-time)
aws ecr create-repository --repository-name flask-app --region us-east-1

# Build image
docker build -t flask-app .

# Authenticate Docker with ECR
aws ecr get-login-password --region us-east-1 | \
docker login --username AWS --password-stdin \
474150620111.dkr.ecr.us-east-1.amazonaws.com

# Tag image
docker tag flask-app:latest \
474150620111.dkr.ecr.us-east-1.amazonaws.com/flask-app:latest

# Push to ECR
docker push 474150620111.dkr.ecr.us-east-1.amazonaws.com/flask-app:latest
```

### 5️⃣ Deploy with Terraform

```bash
cd terraform-ec2

# Initialize Terraform
terraform init

# Plan (see what will be created)
terraform plan

# Apply (provision infrastructure)
terraform apply
# Type 'yes' when prompted

# Get outputs
terraform output
# Shows: jenkins_url, flask_url
```

### 6️⃣ Configure Jenkins

1. **Open Jenkins:**
   ```
   http://<jenkins-elastic-ip>:8080
   ```

2. **Unlock Jenkins:**
   ```bash
   # Get password from EC2
   aws ssm start-session --target <jenkins-instance-id>
   $ sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```

3. **Install Suggested Plugins**

4. **Create Jenkins Credentials:**
   - Kind: AWS Credentials
   - ID: aws-creds
   - Enter Access Key ID and Secret

5. **Create Pipeline Job:**
   - Name: flask-app-pipeline
   - Pipeline → Definition: Pipeline script from SCM
   - SCM: Git
   - Repository URL: Your GitHub URL
   - Credentials: Select your Git credentials

---

## Project Structure

```
docker-ecr-project/
│
├── README.md                          # This file
├── .gitignore                         # Git ignore patterns
├── .dockerignore                      # Docker build ignore
│
├── app/                               # Flask Application
│   ├── app.py                         # Main Flask app (port 5000)
│   ├── templates/
│   │   └── index.html                 # HTML page
│   └── static/
│       └── style.css                  # CSS styling
│
├── requirements.txt                   # Python dependencies
│                                      # Contents:
│                                      # flask
│                                      # flask-socketio
│
├── Dockerfile                         # Multi-stage Docker build
│                                      # Stage 1: Builder (compile deps)
│                                      # Stage 2: Runtime (minimal image)
│
├── Dockerfile.jenkins                 # Jenkins container image
│                                      # Alternative: Run Jenkins in Docker
│
├── docker-compose.yml                 # Local development setup
│                                      # Services: web, redis
│                                      # Network: app-network
│
├── Jenkinsfile                        # CI/CD Pipeline (5 stages)
│                                      # 1. Build Docker Image
│                                      # 2. Tag Image
│                                      # 3. Login to ECR
│                                      # 4. Push to ECR
│                                      # 5. Deploy using SSM
│
├── scripts/                           # Automation Scripts
│   ├── build.ps1                      # PowerShell: docker build
│   └── push-ecr.ps1                   # PowerShell: push to ECR
│
└── terraform-ec2/                     # Infrastructure as Code
    ├── provider.tf                    # AWS provider config
    ├── main.tf                        # EC2, Security Groups, IAM
    │                                  # - Flask EC2 instance
    │                                  # - Jenkins EC2 instance
    │                                  # - Security groups
    │                                  # - IAM roles & policies
    │                                  # - Elastic IPs
    │                                  # - VPC & Subnets
    ├── variables.tf                   # Input variables
    ├── outputs.tf                     # Output values (IPs, URLs)
    ├── terraform.tfstate              # ⚠️ DO NOT COMMIT
    └── .terraform/                    # ⚠️ DO NOT COMMIT
```

---

## Step-by-Step Setup

### Phase 1: Local Development Setup (1-2 hours)

#### Step 1: Install Prerequisites

```bash
# Windows (PowerShell as Administrator)
choco install docker-desktop git python terraform awscli -y

# macOS (with Homebrew)
brew install docker-compose git python@3.10 terraform awscli

# Ubuntu/Debian
sudo apt update
sudo apt install -y docker.io docker-compose git python3.10 terraform awscli
```

#### Step 2: Clone and Test Locally

```bash
git clone <repo-url>
cd docker-ecr-project

# Start locally
docker-compose up --build

# Test
curl http://localhost:5000
# Should show: "🚀 Flask App Running in Docker"

# Stop
docker-compose down
```

#### Step 3: Verify Docker Skills

```bash
# Build image
docker build -t flask-app .

# Run container
docker run -p 5000:5000 flask-app

# Check image size
docker images flask-app
# Should be ~150MB (not 400MB)

# Stop
docker stop <container-id>
```

### Phase 2: AWS Setup (1-2 hours)

#### Step 4: Configure AWS Credentials

```bash
# Configure AWS CLI
aws configure
# Region: us-east-1
# Output: json

# Verify
aws sts get-caller-identity
# Should show your account ID
```

#### Step 5: Create ECR Repository

```bash
# Create repository
aws ecr create-repository --repository-name flask-app --region us-east-1

# Get registry URL
aws ecr describe-repositories --repository-names flask-app --region us-east-1
# Note the repositoryUri
```

#### Step 6: Provision Infrastructure with Terraform

```bash
cd terraform-ec2

# Initialize
terraform init
# Downloads AWS provider plugin

# Validate
terraform validate

# Plan
terraform plan
# Shows: 4 new security groups, 2 EC2 instances, 4 IAM resources

# Apply
terraform apply
# Creates infrastructure (takes ~5 minutes)

# Save outputs
terraform output -json > ../terraform-outputs.json
```

#### Step 7: Verify EC2 Instances

```bash
# List instances
aws ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId,PublicIpAddress,State.Name,Tags[?Key==`Name`].Value|[0]]' --output table

# Sample output:
# i-0fd26bf6b4b3967c1  | 54.123.45.67  | running | Flask-App-EC2
# i-0fg45gh7b9x1973y2  | 54.123.45.68  | running | Jenkins-Server
```

### Phase 3: Jenkins Setup (1-2 hours)

#### Step 8: Initialize Jenkins

```bash
# Get Jenkins instance ID
JENKINS_ID=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=Jenkins-Server" \
  --query 'Reservations[0].Instances[0].InstanceId' \
  --output text)

# Connect to Jenkins EC2
aws ssm start-session --target $JENKINS_ID

# Inside EC2:
$ sudo cat /var/lib/jenkins/secrets/initialAdminPassword
# Copy password
```

#### Step 9: Jenkins Web Setup

```
1. Open http://<jenkins-elastic-ip>:8080
2. Paste initial password
3. Install suggested plugins
4. Create first admin user
5. Skip instance configuration
```

#### Step 10: Configure Jenkins Credentials

```
Jenkins UI → Manage Jenkins → Manage Credentials:

1. Click (global) domain
2. Add Credentials:
   - Kind: AWS Credentials
   - ID: aws-creds
   - Access Key ID: AKIA...
   - Secret Access Key: ...
   
3. Add Credentials:
   - Kind: Username with password
   - Username: your-github-username
   - Password: your-github-token
   - ID: github-creds
```

#### Step 11: Create Jenkins Pipeline Job

```
Jenkins UI:

1. New Item
2. Name: flask-app-pipeline
3. Type: Pipeline
4. Configure:
   - Pipeline → Definition: Pipeline script from SCM
   - SCM: Git
   - Repository URL: https://github.com/yourusername/docker-ecr-project.git
   - Credentials: github-creds
   - Branch: */main
   - Script Path: Jenkinsfile
5. Save
6. Build Now (test)
```

#### Step 12: Verify Pipeline Success

```bash
# Jenkins UI shows all 5 stages green
# docker push succeeded
# ECR shows new image

# Verify ECR
aws ecr list-images --repository-name flask-app --region us-east-1

# Verify Flask EC2 running
curl http://<flask-elastic-ip>
# Should show Flask app
```

---

## Local Development

### Docker Compose Workflow

```bash
# Start all services
docker-compose up --build

# View logs (terminal 2)
docker-compose logs -f web

# Run commands in container (terminal 3)
docker-compose exec web python app/app.py
docker-compose exec web bash

# Stop services
docker-compose down

# Clean everything (warning: removes data)
docker-compose down -v
```

### Local Testing

```bash
# Install dependencies locally
pip install -r requirements.txt

# Run Flask directly
python app/app.py
# Access: http://localhost:5000

# Run tests
pytest app/ -v

# Check code quality
pylint app/
black app/ --check
```

### Docker Debugging

```bash
# See running containers
docker-compose ps

# View container logs
docker logs <container-name>

# Execute command in container
docker exec -it <container-name> bash

# Inspect image
docker history flask-app

# Check image size
docker images flask-app

# Remove dangling images
docker image prune

# View network
docker network ls
docker network inspect app-network
```

---

## CI/CD Pipeline

### Pipeline Stages Explained

#### Stage 1: Build Docker Image
```groovy
stage('Build Docker Image') {
  steps {
    sh 'docker build -t flask-app .'
  }
}
```
- Executes Dockerfile
- Creates image `flask-app:latest`
- Uses BuildKit for caching
- Time: ~1 minute

#### Stage 2: Tag Image
```groovy
stage('Tag Image') {
  steps {
    sh 'docker tag flask-app:latest $ECR_REPO:latest'
  }
}
```
- Aliases image for ECR
- Format: `account.dkr.ecr.region.amazonaws.com/repo:tag`
- No actual image copy, just metadata
- Time: < 1 second

#### Stage 3: Login to ECR
```groovy
stage('Login to ECR') {
  steps {
    withCredentials([aws(credentialsId: 'aws-creds')]) {
      sh 'aws ecr get-login-password --region $AWS_REGION | docker login ...'
    }
  }
}
```
- Uses Jenkins credentials
- Gets temporary ECR token
- Authenticates Docker CLI
- Time: ~3 seconds

#### Stage 4: Push to ECR
```groovy
stage('Push to ECR') {
  steps {
    sh 'docker push $ECR_REPO:latest'
  }
}
```
- Uploads image to AWS ECR
- Compresses layers for transfer
- Time: ~1-2 minutes (depends on image size)

#### Stage 5: Deploy using SSM
```groovy
stage('Deploy using SSM') {
  steps {
    // Send commands to Flask EC2
    // Stop old container
    // Remove old image
    // Pull new image
    // Run new container
  }
}
```
- Sends deployment commands via AWS SSM
- No SSH needed, uses IAM
- Automatic retry on failure
- Time: ~2-3 minutes

### Total Pipeline Time
**~5-10 minutes** (depending on network and resources)

### Manual Triggers

```bash
# Trigger Jenkins build from CLI
curl -X POST http://jenkins:8080/job/flask-app-pipeline/build \
  -u admin:token

# Or just push to Git (if webhook configured)
git push origin main
# Pipeline starts automatically
```

---

## AWS Deployment

### Architecture Overview

```
┌─────────────────────────────────────┐
│         GitHub / Git Repo            │
└──────────────┬──────────────────────┘
               │ (Webhook on push)
               ↓
┌─────────────────────────────────────┐
│      Jenkins EC2 (t3.small)          │
│  - Pipeline orchestration            │
│  - Docker build                      │
│  - Push to ECR                       │
└──────────────┬──────────────────────┘
               │ (SSM send-command)
               ↓
┌─────────────────────────────────────┐
│      Flask EC2 (t3.small)            │
│  - Docker container                  │
│  - Port 80 → 5000 mapping           │
│  - Auto-startup via user_data        │
└──────────────┬──────────────────────┘
               │ (HTTP requests)
               ↓
┌─────────────────────────────────────┐
│            Users / Clients            │
└─────────────────────────────────────┘
```

### Terraform Output

```bash
# After terraform apply

Jenkins URL:  http://54.123.45.68:8080
Flask URL:    http://54.123.45.67
ECR Repo:     474150620111.dkr.ecr.us-east-1.amazonaws.com/flask-app
```

### Scaling Considerations

#### Current Setup (Single Instance)
```
Pros:
✓ Simple
✓ Low cost (~$30/month)
✓ Easy to understand
✓ Good for learning

Cons:
✗ Single point of failure
✗ No high availability
✗ Manual scaling
✗ No load balancing
```

#### Production Setup (Recommended)
```
Add:
- Auto Scaling Group (2-5 instances)
- Application Load Balancer
- RDS database
- CloudWatch monitoring
- Multi-AZ deployment
- Spot instances (70% cost savings)
```

### Cost Optimization

```bash
# Stop instances when not in use (saves 70%)
terraform destroy
# or
aws ec2 stop-instances --instance-ids i-xxx i-yyy

# Later: restart
terraform apply
# or
aws ec2 start-instances --instance-ids i-xxx i-yyy

# Delete only Flask app (keep Jenkins)
terraform destroy -target aws_instance.flask_ec2
```

---

## Monitoring & Troubleshooting

### Accessing Logs

#### Jenkins Logs
```bash
# Via Jenkins UI
Jenkins → Build Name → Console Output

# Via AWS
aws ssm start-session --target <jenkins-instance-id>
$ sudo tail -f /var/log/jenkins/jenkins.log
```

#### Flask App Logs
```bash
# Via Docker logs
aws ssm start-session --target <flask-instance-id>
$ docker logs flask-app -f

# Via CloudWatch (if configured)
aws logs tail /aws/flask-app --follow
```

#### ECR Logs
```bash
# List images
aws ecr list-images --repository-name flask-app --region us-east-1

# Get image details
aws ecr describe-images --repository-name flask-app --region us-east-1
```

### Common Issues & Solutions

#### Issue: Pipeline stuck at "Deploy using SSM"
```bash
# Verify EC2 has SSM agent
aws ssm describe-instance-information \
  --filters "Key=tag:Name,Values=Flask-App-EC2"

# Should show: "PingStatus": "Online"

# If offline:
aws ssm start-session --target <instance-id>
$ sudo systemctl restart amazon-ssm-agent
```

#### Issue: docker push fails - "unauthorized"
```bash
# Verify ECR login
aws ecr get-login-password --region us-east-1 | \
docker login --username AWS --password-stdin \
474150620111.dkr.ecr.us-east-1.amazonaws.com

# Verify credentials
aws sts get-caller-identity

# Verify policy
aws iam get-user-policy --user-name <user> --policy-name <policy>
```

#### Issue: Can't access Flask app
```bash
# Verify EC2 security group
aws ec2 describe-security-groups --group-ids sg-xxx

# Verify port 80 in ingress rules:
# Should have: IpProtocol: tcp, FromPort: 80, ToPort: 80, CidrIp: 0.0.0.0/0

# Test connectivity
curl http://<elastic-ip>

# Check container
aws ssm start-session --target <flask-instance-id>
$ docker ps
$ docker logs flask-app
```

### Health Checks

```bash
# Test Flask app endpoint
curl -I http://<elastic-ip>/
# Should return 200 OK

# Test Docker container
aws ssm start-session --target <flask-instance-id>
$ curl localhost:5000
# Should return HTML

# Test ECR access from EC2
$ aws ecr get-login-password --region us-east-1 | docker login ...
$ docker pull 474150620111.dkr.ecr.us-east-1.amazonaws.com/flask-app:latest
```

---

## Important Security Notes

### ⚠️ Critical Security Practices

#### 1. Never Commit These Files
```
❌ terraform.tfstate
❌ terraform.tfstate.backup
❌ .terraform/ directory
❌ AWS credentials (*.key, *.pem, *.json)
❌ .env files with secrets
❌ Jenkins configuration (secrets.properties)
❌ SSH keys (id_rsa, id_rsa.pub)
```

#### 2. Use Environment Variables for Secrets
```bash
# ❌ WRONG (visible in code)
ECR_REPO = "474150620111.dkr.ecr.us-east-1.amazonaws.com/flask-app"

# ✓ RIGHT (injected at runtime)
environment {
  ECR_REPO = credentials('ecr-repo-url')
}
```

#### 3. Restrict Security Groups
```hcl
# ❌ WRONG (open to world)
ingress {
  from_port   = 22
  to_port     = 22
  cidr_blocks = ["0.0.0.0/0"]
}

# ✓ RIGHT (only your IP)
ingress {
  from_port   = 22
  to_port     = 22
  cidr_blocks = ["203.x.x.x/32"]  # Your IP
}
```

#### 4. Use IAM Roles, Not Access Keys
```hcl
# ✓ BEST (no credentials passed)
iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

# ✓ GOOD (credentials in Jenkins, not code)
withCredentials([aws(credentialsId: 'aws-creds')]) { ... }

# ❌ WORST (credentials in code)
env:
  AWS_ACCESS_KEY_ID: "AKIA..."
  AWS_SECRET_ACCESS_KEY: "..."
```

#### 5. Enable Image Scanning
```hcl
resource "aws_ecr_repository" "flask_app" {
  image_scan_configuration {
    scan_on_push = true  # ✓ Scan for CVEs
  }
}
```

#### 6. Use Non-Root Container User
```dockerfile
# ❌ WRONG (runs as root)
FROM python:3.10-slim
CMD ["python", "app/app.py"]

# ✓ RIGHT (non-root user)
RUN useradd -m -u 1000 appuser
USER appuser
CMD ["python", "app/app.py"]
```

---

## What NOT to Commit to GitHub

### 1. Sensitive Files
```
# Add to .gitignore
terraform.tfstate
terraform.tfstate.backup
.terraform/
**/*.key
**/*.pem
**/*.pfx
.env
.env.local
.env.*.local
secrets.json
credentials.json
```

### 2. Terraform State (Critical!)
```bash
# NEVER commit state files
# State contains:
# - Database passwords
# - API keys
# - Private IPs
# - Sensitive configurations

# Instead: Store remotely
# terraform {
#   backend "s3" {
#     bucket = "my-terraform-state"
#     key    = "prod/terraform.tfstate"
#     region = "us-east-1"
#   }
# }
```

### 3. Jenkins Artifacts
```
# Don't commit:
jenkins-logs/
*.log
build/
dist/
*.jks (keystore files)
```

### 4. Build Artifacts
```
# Don't commit:
__pycache__/
.pytest_cache/
*.pyc
*.pyo
.coverage
htmlcov/
dist/
build/
*.egg-info/
```

### 5. IDE/Editor Files
```
# Don't commit:
.vscode/
.idea/
*.swp
*.swo
*~
.DS_Store
```

### 6. Updated .gitignore Template

```gitignore
# Terraform
terraform-ec2/.terraform/
terraform-ec2/terraform.tfstate
terraform-ec2/terraform.tfstate.backup
terraform-ec2/terraform.tfstate.d/
terraform-ec2/.terraform.lock.hcl

# AWS credentials
*.key
*.pem
credentials.json
~/.aws/

# Environment
.env
.env.local
.env.*.local

# Python
__pycache__/
*.py[cod]
*$py.class
.Python
env/
venv/
pip-log.txt
.coverage
.pytest_cache/
htmlcov/

# IDE
.vscode/
.idea/
*.swp
*.swo
*~
.DS_Store

# Jenkins
*.log
jenkins-logs/

# Node (if used)
node_modules/
npm-debug.log

# OS
Thumbs.db
.directory
```

---

## Improvements & Enhancements

### Short Term (1-2 days)

1. **Add Unit Tests**
   ```bash
   pip install pytest pytest-cov
   pytest app/ --cov=app
   ```

2. **Add Code Quality Checks**
   ```bash
   pip install black pylint bandit
   black app/
   pylint app/
   bandit -r app/
   ```

3. **Add Health Check**
   ```dockerfile
   HEALTHCHECK --interval=30s --timeout=3s \
     CMD curl -f http://localhost:5000/ || exit 1
   ```

4. **Configure CloudWatch Logs**
   - Centralize container logs
   - Set up basic alarms

### Medium Term (1-2 weeks)

1. **Add Database**
   ```hcl
   resource "aws_db_instance" "postgres" {
     engine = "postgres"
     instance_class = "db.t3.micro"
   }
   ```

2. **Implement Blue-Green Deployment**
   - Run old and new versions simultaneously
   - Switch traffic when new version ready
   - Instant rollback if needed

3. **Add SSL/HTTPS**
   ```hcl
   resource "aws_acm_certificate" "cert" {
     domain_name = "example.com"
   }
   
   resource "aws_lb_listener" "https" {
     port = 443
     protocol = "HTTPS"
   }
   ```

4. **Add Load Balancer**
   ```hcl
   resource "aws_lb" "main" {
     load_balancer_type = "application"
   }
   
   resource "aws_autoscaling_group" "main" {
     min_size = 2
     max_size = 5
   }
   ```

### Long Term (Ongoing)

1. **Kubernetes Migration**
   - Use EKS instead of EC2
   - Better scalability
   - More sophisticated deployment

2. **Multi-Environment Setup**
   - Dev, Staging, Production
   - Separate Terraform modules
   - Promote between environments

3. **Monitoring & Observability**
   - Prometheus metrics
   - Grafana dashboards
   - ELK stack for logs
   - Alerting via PagerDuty

4. **Security Hardening**
   - Network policies
   - Pod security policies
   - Secret encryption
   - Audit logging

---

## Contributing

Contributions are welcome! Please follow these guidelines:

### Before Making Changes
```bash
# Create feature branch
git checkout -b feature/your-feature

# Make changes
# Test locally
docker-compose up --build

# Commit
git add .
git commit -m "Add feature: description"

# Push
git push origin feature/your-feature

# Create Pull Request on GitHub
```

### Code Style
- Python: Follow PEP 8 (use Black)
- Terraform: Use terraform fmt
- Bash: Use shellcheck

### Documentation
- Update README for new features
- Add comments for complex logic
- Document configuration changes

---

## License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## Resources

### Learning Materials
- [Docker Official Documentation](https://docs.docker.com/)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [Jenkins Pipeline Documentation](https://www.jenkins.io/doc/book/pipeline/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Flask Documentation](https://flask.palletsprojects.com/)

### Related Projects
- [Docker Compose Examples](https://github.com/docker/awesome-compose)
- [Terraform Best Practices](https://github.com/antonbabenko/terraform-best-practices)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

### Tools & Services
- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [AWS Management Console](https://aws.amazon.com/console/)
- [Jenkins Official](https://www.jenkins.io/)
- [Terraform Cloud](https://www.terraform.io/cloud)

---

## Support

### Getting Help

1. **Check Logs**
   ```bash
   docker-compose logs web
   docker logs <container-name>
   aws logs tail /aws/<log-group>
   ```

2. **Verify Prerequisites**
   ```bash
   docker --version
   docker-compose --version
   terraform --version
   aws --version
   ```

3. **Common Issues**
   - See "Monitoring & Troubleshooting" section
   - Check "Challenges & Solutions" documentation
   - Review security settings

### Report Issues
- Create GitHub Issue with:
  - Error message (full, not truncated)
  - Steps to reproduce
  - Your environment (OS, versions)
  - Relevant logs

---

## Acknowledgments

This project combines best practices from:
- AWS Well-Architected Framework
- Docker Best Practices
- Jenkins Community
- Terraform Best Practices
- DevOps Handbook

---

**Last Updated:** April 29, 2026  
**Version:** 1.0.0  
**Status:** Production-Ready

---

### Quick Command Reference

```bash
# Local Development
docker-compose up --build        # Start locally
docker-compose down              # Stop locally
docker-compose logs -f web       # View logs

# Docker
docker build -t flask-app .      # Build image
docker run -p 5000:5000 flask-app   # Run container
docker images                    # List images
docker ps                        # List containers

# AWS
aws configure                    # Setup credentials
aws ecr create-repository ...    # Create ECR repo
aws ssm start-session ...        # Connect to EC2
aws ec2 describe-instances ...   # List EC2s

# Terraform
terraform init                   # Initialize
terraform plan                   # Preview changes
terraform apply                  # Create infrastructure
terraform destroy                # Destroy infrastructure

# Git
git clone <url>                  # Clone repo
git push origin main             # Push changes
git pull origin main             # Pull changes

# Jenkins
curl -X POST http://jenkins:8080/job/NAME/build   # Trigger build
```

---

**Happy DevOps-ing! 🚀**
