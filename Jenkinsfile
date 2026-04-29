pipeline {
    agent any

    environment {
        AWS_REGION = credentials('aws-region')     // string credential
        ECR_REPO   = credentials('ecr-repo-url')   // string credential
        INSTANCE_ID = credentials('ec2-instance-id') // string credential
    }

    stages {

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t flask-app .'
            }
        }

        stage('Tag Image') {
            steps {
                sh 'docker tag flask-app:latest $ECR_REPO:latest'
            }
        }

        stage('Login to ECR') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    sh '''
                    aws ecr get-login-password --region $AWS_REGION |
                    docker login --username AWS --password-stdin $ECR_REPO
                    '''
                }
            }
        }

        stage('Push to ECR') {
            steps {
                sh 'docker push $ECR_REPO:latest'
            }
        }

        stage('Deploy using SSM') {
            steps {
                withCredentials([
                    aws(credentialsId: 'aws-creds')
                ]) {
                    sh '''
                    COMMAND_ID=$(aws ssm send-command \
                      --instance-ids $INSTANCE_ID \
                      --document-name "AWS-RunShellScript" \
                      --region $AWS_REGION \
                      --query "Command.CommandId" \
                      --output text \
                      --parameters "commands=[
                        \\"aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO\\",
                        \\"docker stop flask-app || true\\",
                        \\"docker rm flask-app || true\\",
                        \\"docker rmi $ECR_REPO:latest || true\\",
                        \\"docker pull $ECR_REPO:latest\\",
                        \\"docker run -d -p 80:5000 --name flask-app $ECR_REPO:latest\\"
                      ]")

                    echo "Command ID: $COMMAND_ID"
                    '''
                }
            }
        }
    }
}