pipeline {
    agent { label 'agent1' }

    environment {
        AZURE_TENANT_ID = "${env.AZURE_TENANT_ID}"
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/Salmane-dev1/Poke-delivery-Praxis-Projekt.git'
                    ]],
                    extensions: [[$class: 'CleanBeforeCheckout']]
                ])
            }
        }

        stage('Install Dependencies') {
            steps {
                dir('api') {
                    sh 'npm install'
                }
            }
        }

        stage('Run Tests') {
            steps {
                dir('api') {
                    sh 'npm test'
                }
            }
        }

        stage('Build') {
            steps {
                echo 'Build ready ✅'
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'azure-sp',
                    usernameVariable: 'AZ_CLIENT_ID',
                    passwordVariable: 'AZ_CLIENT_SECRET'
                )]) {
                    dir('terraform') {
                        sh '''
                        echo "=== TERRAFORM START ==="

                        az login --service-principal \
                          -u $AZ_CLIENT_ID \
                          -p $AZ_CLIENT_SECRET \
                          --tenant $AZURE_TENANT_ID

                        rm -f /home/jenkins/.terraformrc
                        rm -rf .terraform
                        rm -f .terraform.lock.hcl

                        mkdir -p /home/jenkins/.terraform.d/plugins/registry.terraform.io/hashicorp/azurerm/3.117.1/linux_amd64
                        mkdir -p /home/jenkins/.terraform.d/plugins/registry.terraform.io/hashicorp/random/3.9.0/linux_amd64

                        echo "Downloading Terraform providers with correct structure..."

                        curl -L -o azurerm.zip https://releases.hashicorp.com/terraform-provider-azurerm/3.117.1/terraform-provider-azurerm_3.117.1_linux_amd64.zip
                        unzip -o azurerm.zip -d azurerm_tmp
                        mv azurerm_tmp/terraform-provider-azurerm_* /home/jenkins/.terraform.d/plugins/registry.terraform.io/hashicorp/azurerm/3.117.1/linux_amd64/
                        rm -rf azurerm.zip azurerm_tmp

                        curl -L -o random.zip https://releases.hashicorp.com/terraform-provider-random/3.9.0/terraform-provider-random_3.9.0_linux_amd64.zip
                        unzip -o random.zip -d random_tmp
                        mv random_tmp/terraform-provider-random_* /home/jenkins/.terraform.d/plugins/registry.terraform.io/hashicorp/random/3.9.0/linux_amd64/
                        rm -rf random.zip random_tmp

                        cat > /home/jenkins/.terraformrc <<'EOF'
provider_installation {
  filesystem_mirror {
    path    = "/home/jenkins/.terraform.d/plugins"
    include = ["registry.terraform.io/hashicorp/*"]
  }

  direct {
    exclude = ["registry.terraform.io/hashicorp/*"]
  }
}
EOF

                        terraform init

                        terraform import azurerm_resource_group.rg \
                        /subscriptions/54c804f5-885d-4164-b8a8-7371ca92d8ce/resourceGroups/poke-delivery-rg || true

                        terraform apply -auto-approve

                        echo "=== TERRAFORM DONE ✅ ==="
                        '''
                    }
                }
            }
        }

        stage('Deploy to Azure') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'azure-sp',
                    usernameVariable: 'AZ_CLIENT_ID',
                    passwordVariable: 'AZ_CLIENT_SECRET'
                )]) {
                    sh '''
                    echo "=== START DEPLOYMENT ==="

                    cd api

                    az login --service-principal \
                      -u $AZ_CLIENT_ID \
                      -p $AZ_CLIENT_SECRET \
                      --tenant $AZURE_TENANT_ID

                    func azure functionapp publish salmane-poke-func --javascript --force

                    echo "=== DEPLOYMENT DONE ✅ ==="
                    '''
                }
            }
        }
    }
}
