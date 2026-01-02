# Deploy Go Web App on Cloud using Github Actions - DevOps Project!

### **Phase 1: Initial Setup and Deployment**

**Step 1: Provision EC2 (Ubuntu 22.04) using Terraform:**

- Create a directory with the following structure.
```
  terraform/
├── providers.tf      # AWS provider and region
├── main.tf           # EC2 instance, key pair, security group , vpc
├── outputs.tf        # Public IP output
└── variables.tf      # Customizable variables
```
```
  terraform-backend/
├── providers.tf      # AWS provider and region
├── s3.tf             # s3 bucket
├── dynamodbtable.tf  # dynamodb table
├── outputs.tf        # Public IP output
└── variables.tf      # Customizable variables
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
    docker build -t netflix .
    docker run -d --name netflix -p 8081:80 netflix:latest
    ```
- For deleting:
   ```bash
    docker stop <containerid>
    docker rmi -f netflix
   ```
