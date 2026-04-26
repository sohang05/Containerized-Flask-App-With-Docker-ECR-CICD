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

	stage('Deploy to EC2') {
    steps {
        sshagent(['ec2-key']) {
            sh """
            ssh ec2-user@3.82.254.133 '
              aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 474150620111.dkr.ecr.us-east-1.amazonaws.com &&
              docker pull 474150620111.dkr.ecr.us-east-1.amazonaws.com/flask-app:latest &&
              docker stop flask-app || true &&
              docker rm flask-app || true &&
              docker run -d -p 80:5000 --name flask-app 474150620111.dkr.ecr.us-east-1.amazonaws.com/flask-app:latest
            '
            """
        }
    }
    }

	stage('Add EC2 to known hosts') {
    steps {
        sh "ssh-keyscan -H 3.82.254.133 >> ~/.ssh/known_hosts"
    }
}
}
}
