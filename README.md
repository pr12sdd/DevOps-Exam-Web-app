# Deploy Go Web App on Cloud using Github Actions - DevOps Project!

### **Phase 1: Initial Setup and Deployment**

**Step 1: Provision EC2 (Ubuntu 22.04) using Terraform:**

- Create a directory with the following structure.
```
  terraform/
├── providers.tf      # AWS provider and region
├── ec2.tf           # EC2 instance, key pair, security group , vpc
├── output.tf        # Public IP output
├── terraform.tf     # AWS provider and remote backend configuration   
└── variable.tf      # Customizable variables
```
```
  terraform-backend/
├── providers.tf      # AWS provider and region
├── s3.tf             # s3 bucket
├── dynamodb.tf       # dynamodb table       
└── terraform.tf      # AWS provider configuration
```
### How to proceed
1. Create the folder: `mkdir terraform && cd terraform`
2. Generate Public and Private Keys:
   ```bash
   ssh-keygen
   ```
4. Create the above files with the required Terraform configuration.
5. Run:
   ```bash
   terraform init
   terraform apply --auto-approve
   ```
6. Create the folder: `mkdir terraform-backend && cd terraform-backend
7. Create the above files with the required Terraform configuration.
8. Run:
   ```bash
   terraform init
   terraform apply --auto-approve
   ```
- Connect to the instance using SSH.

**Step 2: Clone the Code:**

- Update all the packages and then clone the code.
- Clone your application's code repository onto the EC2 instance:
    
    ```bash
    git clone https://github.com/pr12sdd/DevSecOps-Project.git
    ```
**Step 3: Install Docker and Run the App Using a Container:**

- Set up Docker on the EC2 instance:
    
    ```bash
    
    sudo apt-get update
    sudo apt-get install docker.io -y
    sudo usermod -aG docker $USER  # Replace with your system's username, e.g., 'ubuntu'
    newgrp docker
    sudo chmod 777 /var/run/docker.sock
    ```
    
- Build and run your application using Docker containers:
    
    ```bash
    docker compose up
    ```
- For deleting:
   ```bash
    docker compose down
   ```
**Step 4: Build Docker image from dockerfile and push it to dockerHub:**
- Build your docker image from the dockerfile:
  ```bash
  docker build -t pkmadhubani/docker-image-name .
  docker push pkmadhubani/docker-image-name
  ```
### **Phase 2: Security:**
- Install Sonarqube and Trivy:
  ```bash
  sonarqube: docker run -d -p 9000:9000 sonarqube:lts-community
  ```
  ```bash
  trivy:
    sudo apt-get install wget apt-transport-https gnupg lsb-release
    wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
    echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
    sudo apt-get update
    sudo apt-get install trivy 
  ```
  ```bash
  For scanning image using trivy:
  trivy image image_id
  ```
- Integrate SonarQube with jenkins CI/CD pipeline and Configure SonarQube to analyze code for quality and security issues.
### **Phase 3: CI/CD Setup:
- Install Jenkins For automation on your ec2 instance:
  ```bash
  Installing java required by jenkins to run: 
  sudo apt update
  sudo apt install fontconfig openjdk-17-jre
  java -version
  openjdk version "17.0.8" 2023-07-18
  OpenJDK Runtime Environment (build 17.0.8+7-Debian-1deb12u1)
  OpenJDK 64-Bit Server VM (build 17.0.8+7-Debian-1deb12u1, mixed mode, sharing)
  ```
  ```bash
  Installing Jenkins:
  sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
  echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
  sudo apt-get update
  sudo apt-get install jenkins
  sudo systemctl start jenkins
  sudo systemctl enable jenkins
  ```
- Access Jenkins in a web browser using the public IP of your EC2 instance.
- Install necessary Plugins in jenkins which is required for your Jenkins Declartive pipeline to run such as Docker , SonarQube Scanner , OWASP etc.
- Create a CI/CD pipeline in Jenkins to automate your application deployment:
  ```
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
  ```
- Now run your Jenkins CI/CD pipeline for Continuous Integration and Continuous Deployment on Docker Container.
