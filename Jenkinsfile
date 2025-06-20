pipeline {
    agent any
    environment {
        AWS_REGION = 'us-east-1'
        TERRAFORM_CLUSTER_INFRA_PATH = 'infrastructure'
        TERRAFORM_CLUSTER_CONFIG_PATH = 'cluster-config'
    }
    stages {

        stage('Check infrastructure terraform files') {
            agent {
                docker { image 'jenkins/jnlp-agent-terraform' }
            }
            steps {
                dir("${TERRAFORM_CLUSTER_INFRA_PATH}") {
                    withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
                        script {
                            sh """
                            terraform init -reconfigure
                            terraform validate
                            terraform fmt -recursive
                            terraform plan
                            """
                        }
                    }
                }
            }
        }

        stage('Infrastructure security scan - Checkov') {
            agent {
                docker { image 'socksshop/checkov:latest'}
            }
            steps {
                script {
                    catchError(buildResult: 'UNSTABLE', stageResult: 'UNSTABLE') {
                        sh """
                        checkov -d "infrastructure" \
                                --framework terraform \
                                --output cli \
                                --compact
                        """
                    }
                }
            }
        }

        stage('Deploy infrastructure to AWS') {
            agent {
                docker { image 'jenkins/jnlp-agent-terraform' }
            }
            steps {
                dir("${TERRAFORM_CLUSTER_INFRA_PATH}") {
                    withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
                        input message: "Lancer le deploy de l'infrastructure AWS ?", ok: 'Oui'
                        sh """
                        terraform init -upgrade
                        terraform apply --auto-approve
                        """
                    }
                }
            }
        }

        stage('Check cluster configuration terraform files') {
            environment {
                TF_VAR_grafana_admin_password = credentials('TF_VAR_grafana_admin_password')
            }
            agent {
                docker {
                    image 'socksshop/aws-cli-terraform-helm:latest'
                    args '-u root -v $HOME/.kube:/root/.kube'
                }
            }
            steps {
                dir("${TERRAFORM_CLUSTER_CONFIG_PATH}") {
                    withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
                        script {
                            sh """
                            helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
                            helm repo add eks https://aws.github.io/eks-charts
                            helm repo update

                            terraform init -reconfigure
                            terraform validate
                            terraform fmt -recursive
                            terraform plan
                            """
                        }
                    }
                }
            }
        }

        stage('Cluster-config security scan - Checkov') {
            agent {
                docker { image 'socksshop/checkov:latest' }
            }
            steps {
                script {
                    catchError(buildResult: 'UNSTABLE', stageResult: 'UNSTABLE') {
                        sh """
                        checkov -d "cluster-config" \
                                --framework terraform \
                                --output cli \
                                --compact
                        """
                    }
                }
            }
        }

        stage('Deploy AWS EKS cluster configuration to AWS') {
            agent {
                docker {
                    image 'socksshop/aws-cli-terraform-curl-kubectl-helm-velero:latest'
                    args '-u root -v $HOME/.kube:/root/.kube'
                }
            }
            environment {
                TF_VAR_grafana_admin_password = credentials('TF_VAR_grafana_admin_password')
            }
            steps {
                dir("${TERRAFORM_CLUSTER_CONFIG_PATH}") {
                    withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
                        sh """
                        helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
                        helm repo add eks https://aws.github.io/eks-charts
                        helm repo update

                        terraform init -reconfigure
                        terraform apply --auto-approve
                        """
                    }
                }
            }
        }

        stage('Post-deployment Infrastructure Management') {
            agent {
                docker {
                    image 'jenkins/jnlp-agent-terraform'
                }
            }
            steps {
                withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
                    script {
                        def userChoice = input(
                            id: 'infrastructureAction',
                            message: 'Que souhaitez-vous faire avec l\'infrastructure AWS EKS ?',
                            parameters: [
                                choice(
                                    name: 'ACTION',
                                    choices: ['Continuer (ne rien faire)', 'Détruire'],
                                    description: 'Choisissez une action à effectuer'
                                )
                            ]
                        )

                        if (userChoice == 'Détruire') {
                            echo "Confirmation de destruction reçue. Lancement de la destruction des modules Terraform."

                            // --- Destruction de la configuration du cluster ---
                            echo "Lancement de la destruction de la configuration du cluster (${TERRAFORM_CLUSTER_CONFIG_PATH})..."
                            dir("${TERRAFORM_CLUSTER_CONFIG_PATH}") {
                                withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
                                    sh """
                                    terraform init -reconfigure
                                    terraform destroy --auto-approve
                                    """
                                }
                            }
                            echo "Configuration du cluster détruite."

                            // --- Destruction de l'infrastructure de base ---
                            echo "Lancement de la destruction de l'infrastructure de base (${TERRAFORM_CLUSTER_INFRA_PATH})..."
                            dir("${TERRAFORM_CLUSTER_INFRA_PATH}") {
                                withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
                                    sh """
                                    terraform init -reconfigure
                                    terraform destroy --auto-approve
                                    """
                                }
                            }
                            echo "Infrastructure de base détruite."

                        } else { // userChoice == 'Continuer (ne rien faire)'
                            echo "Pas de destruction de l'infrastructure."
                        }
                    }
                }
            }
        }

    }

}
