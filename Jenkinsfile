pipeline {
    agent {
        docker { image 'jenkins/jnlp-agent-terraform'}
    }
    stages {

        stage('Check infrastructure terraform files') {
            steps {
                script {
                    sh """
                    cd infrastructure
                    terraform init
                    terraform validate
                    terraform fmt -recursive
                    terraform plan
                    """
                }
            }
        }

        // stage('Deploy infrastructure to AWS') {
        //     steps {
        //         withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
        //             input message: 'Lancer le deploy de l'infrastructure AWS ?', ok: 'Oui'
        //             sh """
        //             cd infrastructure
        //             terraform apply --auto-approve
        //             """
        //         }
        //     }
        // }

        // stage('Destroy AWS infrastructure') {
        //     steps {
        //         withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
        //             input message: 'Lancer le destroy de l'infrastructure AWS ?', ok: 'Oui'
        //             sh """
        //             cd infrastructure
        //             terraform destroy --auto-approve
        //             """
        //         }
        //     }
        // }

        // stage('Check cluster configuration terraform files') {
        //     steps {
        //         script {
        //             sh """
        //             cd cluster-config
        //             terraform init
        //             terraform validate
        //             terraform fmt -recursive
        //             terraform plan
        //             """
        //         }
        //     }
        // }

        // stage('Deploy AWS EKS cluster configuration to AWS') {
        //     steps {
        //         withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
        //             sh """
        //             cd cluster-config
        //             terraform apply --auto-approve --var-file terraform-dev.tfvars
        //             """
        //         }
        //     }
        // }

        // stage('Destroy AWS EKS cluster configuration') {
        //     steps {
        //         withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
        //             input message: 'Lancer le destroy de la configuration du cluster?', ok: 'Oui'
        //             sh """
        //             cd cluster-config
        //             terraform destroy --auto-approve
        //             """
        //         }
        //     }
        // }

        // stage('Destroy AWS infrastructure + EKS cluster configuration') {
        //     steps {
        //         withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
        //             input message: 'Lancer le destroy de l'infrastructure et de la configuration du cluster ?', ok: 'Oui'
        //             sh """
        //             cd cluster-config
        //             terraform destroy --auto-approve
        //             cd ../infrastructure
        //             terraform destroy --auto-approve
        //             """
        //         }
        //     }
        // }

    }
}
