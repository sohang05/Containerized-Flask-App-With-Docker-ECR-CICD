pipeline {
    agent any

    environment {
        AWS_REGION = "us-east-1"
        ECR_REPO = "474150620111.dkr.ecr.us-east-1.amazonaws.com/flask-app"
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
              --instance-ids i-0fd26bf6b4b3967c1 \
              --document-name "AWS-RunShellScript" \
              --region us-east-1 \
              --query "Command.CommandId" \
              --output text \
              --parameters 'commands=[
                "aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 474150620111.dkr.ecr.us-east-1.amazonaws.com",
                "docker pull 474150620111.dkr.ecr.us-east-1.amazonaws.com/flask-app:latest",
                "docker stop flask-app || true",
                "docker rm flask-app || true",
                "docker run -d -p 80:5000 --name flask-app 474150620111.dkr.ecr.us-east-1.amazonaws.com/flask-app:latest"
              ]')

            echo "Command ID: $COMMAND_ID"

            aws ssm wait command-executed \
              --command-id $COMMAND_ID \
              --instance-id i-0fd26bf6b4b3967c1 \
              --region us-east-1

            aws ssm list-command-invocations \
              --command-id $COMMAND_ID \
              --details \
              --region us-east-1
            '''
        }
    }
}   
     }
}
