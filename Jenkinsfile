pipeline {
    agent {
        docker { image 'jenkins/jnlp-agent-terraform'}
    }
    environment {
        TERRAFORM_CLUSTER_INFRA_PATH = 'infrastructure'
        TERRAFORM_CLUSTER_CONFIG_PATH = 'cluster-config'
        AWS_REGION = 'us-east-1'
    }
    stages {

        // stage('Check infrastructure terraform files') {
        //     steps {
        //         dir("${TERRAFORM_CLUSTER_INFRA_PATH}") {
        //             withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
        //                 script {
        //                     sh """
        //                     terraform init
        //                     terraform validate
        //                     terraform fmt -recursive
        //                     terraform plan
        //                     """
        //                 }
        //             }
        //         }
        //     }
        // }

        stage('Infrastructure security scan - Checkov') {
            agent {
                docker {
                    image 'socksshop/checkov:latest'
                }
            }
            steps {
                script {
                    sh """
                    checkov -d "infrastructure" \
                            --framework terraform \
                            --output cli \
                            --compact
                            --quiet || true
                    """
                }
            }
        }

        stage('Deploy infrastructure to AWS') {
            steps {
                dir("${TERRAFORM_CLUSTER_INFRA_PATH}") {
                    withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
                        input message: "Lancer le deploy de l'infrastructure AWS ?", ok: 'Oui'
                        sh """
                        terraform init
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
            steps {
                dir("${TERRAFORM_CLUSTER_CONFIG_PATH}") {
                    withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
                        script {
                            sh """
                            terraform init
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
                docker {
                    image 'socksshop/checkov:latest'
                }
            }
            steps {
                script {
                    sh """
                    checkov -d "cluster-config" \
                            --framework terraform \
                            --output cli \
                            --compact
                            --quiet || true
                    """
                }
            }
        }

        stage('Deploy AWS EKS cluster configuration to AWS') {
            agent {
                docker {
                    image 'socksshop/aws-cli-terraform-curl-kubectl-velero:latest'
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
                        terraform init
                        terraform apply --auto-approve
                        """
                    }
                }
            }
        }

        stage('Destroy AWS EKS Infrastructure') {
            steps {
                withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
                    script {
                        // --- Étape de confirmation unique pour toutes les destructions ---
                        try {
                            input(
                                message: "ATTENTION : Voulez-vous DÉTRUIRE toute l'infrastructure (infrastructure et configuration du cluster) ? Cliquez sur 'Oui' pour détruite, sinon la pipeline s'arrêtera toute seule dans 5 minutes.",
                                ok: 'Oui, détruire tout',
                                timeout: 300
                            )
                            echo "Confirmation reçue. Lancement de la destruction des deux modules Terraform."
                        } catch (org.jenkinsci.plugins.workflow.steps.FlowInterruptedException e) {
                            echo "Destruction annulée par l'utilisateur ou par timeout. Arrêt de la pipeline."
                            currentBuild.result = 'ABORTED'
                            error "Pipeline interrompue, destruction non lancée."
                        }

                        // --- Destruction de la configuration du cluster ---
                        echo "Lancement de la destruction de la configuration du cluster (${TERRAFORM_CLUSTER_CONFIG_PATH})..."
                        dir("${TERRAFORM_CLUSTER_CONFIG_PATH}") {
                            withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
                                sh """
                                terraform init
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
                                terraform init
                                terraform destroy --auto-approve
                                """
                            }
                        }
                        echo "Infrastructure de base détruite."
                    }
                }
            }
        }

    }

    post {
        always {
            echo "Pipeline terminée."
        }
        success {
            echo "Opérations de destruction terminées avec succès."
        }
        failure {
            echo "Les opérations de destruction ont échoué à un moment donné."
        }
        aborted {
            echo "Pipeline annulée avant la destruction complète."
        }
    }

}
