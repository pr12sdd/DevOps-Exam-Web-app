pipeline {
    agent any
    tools {
        jdk 'jdk'
    }
    environment {
        SCANNER_HOME = tool 'sonarqube'
    }
    stages {
        stage('Clean Workspace'){
            steps{
                cleanWs()
            }
        }
        stage('Checkout from Git'){
            steps {
                git branch :'main',url:'https://github.com/pr12sdd/DevOps-Exam-Web-app.git'
            }
        }
        stage('Sonarqube Analysis'){
            steps {
                withSonarQubeEnv('sonarqube-server'){
                    sh ''' ${SCANNER_HOME}/bin/sonar-scanner -Dsonar.projectName=Devops-exam-app -Dsonar.projectKey=Devops-exam-app '''
                }
            }
        }
        stage("Quality Gate"){
            steps {
                script {
                    waitForQualityGate abortPipeline:false , credentialsId : 'sonarqube'
                }
            }
        }
        stage('OWASP FS SCAN'){
            steps {
                dependencyCheck additionalArguments:'--scan ./ --disableYarnAudit --disableNodeAudit',odcInstallation:'owsap'
                dependencyCheckPublisher pattern:'**/dependency-check-report.xml'
            }
        }
        stage('trivy fs scan'){ 
            steps {
                sh 'trivy fs . > trivyfs.txt'
            }
        }
        stage('Docker build and push'){
            steps {
                script {
                    withDockerRegistry(credentialsId:'docker',toolName:'docker'){
                        sh "docker build -t pkmadhubani/devops-exam-app:latest backend/"
                        sh "docker push pkmadhubani/devops-exam-app:latest"
                    }
                }
            }
        }
        stage('Docker image scan'){
            steps{
                sh "trivy image pkmadhubani/devops-exam-app:latest > trivyimage.txt"
            }
        }
        stage('Deploy to docker'){
            steps {
                sh '''
                docker compose pull
                docker compose down --remove-orphans
                docker compose up -d --build
                
                '''
            }
        }
    }
    
    post {
        always {
            emailext (
            attachLog:true,
            subject:"${currentBuild.result}",
            mimeType: 'text/html',
            body:"Project: ${env.JOB_NAME}<br/>" + 
                 "Build Number: ${env.BUILD_NUMBER}<br/>" +
                 "URL: ${env.BUILD_URL}<br/>" ,
            to: 'prakashkumar5332@gmail.com',
            attachmentsPattern:'trivyfs.txt,trivyimage.txt'
            )
        }
    }
}
