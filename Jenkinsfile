pipeline {
    agent { label 'agent1' }  

    tools {
        maven "M3"
    }
    environment {
        NEXUS_VERSION = "nexus3"
        NEXUS_PROTOCOL = "http"
        NEXUS_URL = "${NEXUS_URL}" 
        NEXUS_REPOSITORY = "image-repo"
        NEXUS_CREDENTIAL_ID = "${NEXUS_CREDENTIAL_ID}"
        DOCKER_USERNAME = "${DOCKER_USERNAME}"
        DOCKER_PASSWORD = "${DOCKER_PASSWORD}"
    }

    stages {
        stage("Maven Build"){
            steps{
                sh "echo $DOCKER_USERNAME $DOCKER_PASSWORD"
                sh "mvn clean package -Dmaven.test.skip -Dcheckstyle.skip"
            }
        }
        stage("Docker Build and Tag"){
            steps{
                sh "docker image build -t $NEXUS_URL/petclinic:latest -t $NEXUS_URL/petclinic:\$(git log -1 --pretty=%h) ."
            }
        }
        stage("Push to Nexus repository") {
            steps{
                sh "docker login $NEXUS_URL -u=$DOCKER_USERNAME -p=$DOCKER_PASSWORD"
                sh "docker push $NEXUS_URL/petclinic --all-tags"
            }
        }
        stage("Deploy to app-server"){
            steps{
                ws('/home/jenkins/ansible') {
                    sh "docker login $NEXUS_URL -u=$DOCKER_USERNAME -p=$DOCKER_PASSWORD"
                    sh "echo '${VAULT_PASS}' > .secret.txt"
                    sh "ansible-playbook playbooks/app-deploy.yaml  --vault-password-file .secret.txt"
                    sh "rm .secret.txt"
                }
            }
        }
    }
    post {
        success {
            slackSend color: "good", message:"Build successful - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
        }
        failure {
            slackSend color: "danger", message:"Build failed  - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
        }
    }
}
