pipeline {
    environment {
        DOCKER_ID = "socksshop"
        DOCKER_IMAGE = "front-end"
        // DOCKER_TAG = "v.${BUILD_ID}.0"
        // DOCKER_TAG = "latest"
        AWS_REGION = 'us-east-1'
        CLUSTER_NAME = 'sockshop-EKS-VPC'
        CHART_NAME = 'helm-charts/frontend/'
        NAMESPACE = 'dev'
        RELEASE_NAME = 'socksshop-frontend'
    }

    agent any

    stages {

        stage('Test2') {
            agent {
                docker {
                    image 'socksshop/aws-cli-git-kubectl-helm:latest'
                    args '-u root -v $HOME/.kube:/root/.kube'
                }
            }
            steps {
                withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
                    sh '''
                    echo "testing"
                    aws sts get-caller-identity
                    '''
                }
            }
        }



    }
}
