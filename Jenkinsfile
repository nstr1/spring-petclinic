pipeline {
    agent { label 'agent1' }

    tools {
        // Install the Maven version configured as "M3" and add it to the path.
        maven "M3"
    }

    stages {
        stage('Maven Build'){
            steps{
                sh "./mvnw package -Dmaven.test.skip"
            }
        }
        stage("Publish to Nexus Repository Manager") {
            steps {
                script {
                    pom = readMavenPom file: "pom.xml";
                    filesByGlob = findFiles(glob: "target/*.${pom.packaging}");
                    echo "${filesByGlob[0].name} ${filesByGlob[0].path} ${filesByGlob[0].directory} ${filesByGlob[0].length} ${filesByGlob[0].lastModified}"
                    artifactPath = filesByGlob[0].path;
                    artifactExists = fileExists artifactPath;
                    if(artifactExists) {
                        echo "*** File: ${artifactPath}, group: ${pom.groupId}, packaging: ${pom.packaging}, version ${pom.version}";
                        nexusArtifactUploader(
                            nexusVersion: "nexus3",
                            protocol: "HTTP",
                            nexusUrl: "34.116.143.12:8081",
                            groupId: pom.groupId,
                            version: pom.version,
                            repository: "maven-nexus-repo",
                            credentialsId: "jenkins-user",
                            artifacts: [
                                [artifactId: pom.artifactId,
                                classifier: '',
                                file: artifactPath,
                                type: pom.packaging],
                                [artifactId: pom.artifactId,
                                classifier: '',
                                file: "pom.xml",
                                type: "pom"]
                            ]
                        );
                    } else {
                        error "*** File: ${artifactPath}, could not be found";
                    }
                }
            }

    }
    stage("Deploy app with ansible") {
        steps {
            ws('/home/jenkins/ansible') {
                sh "ansible-playbook playbooks/app-deploy.yaml"
            }
        }
    }
}
}
