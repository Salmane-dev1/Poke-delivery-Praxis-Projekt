pipelineJob('pokedelivery-cd') {
    description('PokéDelivery CD Pipeline created automatically with Job DSL')

    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        url('https://github.com/Salmane-dev1/Poke-delivery-Praxis-Projekt.git')
                    }
                    branch('main')
                }
            }
            scriptPath('Jenkinsfile')
        }
    }

    triggers {
    }
}
