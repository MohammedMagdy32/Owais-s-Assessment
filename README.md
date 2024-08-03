# Node.js API with Docker, Jenkins, and CI/CD Pipeline Module-1 CICD

## Introduction

This project is a Node.js API application that is containerized using Docker and managed with a CI/CD pipeline built in Jenkins. The pipeline includes stages for building, testing, and deploying the application, along with integration for dynamic security testing using OWASP ZAP.

## Table of Contents

- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Setup and Installation](#setup-and-installation)
- [CI/CD Pipeline](#cicd-pipeline)
- [Docker Configuration](#docker-configuration)
- [Deployment](#deployment)
- [Environment Variables](#environment-variables)
## Project Structure

├── Jenkinsfile

├── Dockerfile

├── docker-compose.yml

├── src

│ ├── app.js

│ ├── controllers

│ ├── models

│ ├── routes

│ └── tests

├── package.json

└── README.md
- **`Jenkinsfile`**: Defines the CI/CD pipeline stages.
- **`Dockerfile`**: Configuration for building the Docker image.
- **`docker-compose.yml`**: Manages multi-container Docker applications.
- **`src`**: Contains the application code and tests.


## Prerequisites

Before you begin, ensure you have met the following requirements:

- Docker and Docker Compose installed
- Jenkins installed and configured
- Node.js and npm installed
- Access to a cloud server (e.g., AWS, Azure)
- GitHub account and repository access
- Valid DockerHub credentials

## Setup and Installation

### Clone the Repository

```bash
git clone https://github.com/MohammedMagdy32/Owais
cd Owais
```
### Build and Run with Docker Compose
```bash
docker-compose up --build
```
- Access the Application
- Node.js API: http://localhost:3000
- Redis: localhost:6379
- MySQL: localhost:3306

## CI/CD Pipeline
```
pipeline {
    agent any

    tools { 
        nodejs "NodeJS" 
    }

    environment {
        registry = "mohammed32/owais"
        dockerImage = ''
        remoteServer = '157.175.4.250'
        sshCredentialsId = 'Deployment-Docker-Server'
        TARGET_URL = 'http://xx.xx.xx.xx:XXXX/'
    }

    stages {
        stage('Cloning Git') {
            steps {
                git branch: 'main', url: 'https://github.com/MohammedMagdy32/Owais'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }

        stage('Run Unit Tests') {
            steps {
                sh 'npm test'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("${registry}:${env.BUILD_NUMBER}")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials') {
                        dockerImage.push('latest')
                    }
                }
            }
        }

        stage('Dynamic Analysis - DAST with OWASP ZAP') {
            steps {
                script {
                    // Run ZAP baseline scan and print the output to the screen
                    sh '''
                    docker run -t ghcr.io/zaproxy/zaproxy:stable zap-baseline.py -t "$TARGET_URL" || true
                    '''
                }
            }
        }

        stage('Deploy to Server') {
            steps {
                sshagent(credentials: [sshCredentialsId]) {
                    sh '''
                    ssh -o StrictHostKeyChecking=no ubuntu@${remoteServer} '
                    cd /home/ubuntu/deploy &&
                    docker compose pull &&
                    docker compose up -d'
                    '''
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo 'Pipeline completed successfully'
        }
        failure {
            echo 'Pipeline failed'
        }
    }
}
```
Pipeline Stages
- Cloning Git: Clones the Git repository
- Install Dependencies: Installs Node.js dependencies.
- Run Unit Tests: Executes unit tests.
- Build Docker Image: Builds the Docker image for the application.
- Push Docker Image: Pushes the Docker image to DockerHub.
- Dynamic Analysis - DAST with OWASP ZAP: Performs security scanning.
- Deploy to Server: Deploys the application to a remote serve

## Docker Configuration
### Dockerfile 
```
FROM node:10

# Create and change to the app directory.
WORKDIR /usr/src/app

# Copying this separately prevents re-running npm install on every code change.
COPY package*.json ./

# Install dependencies.
RUN npm install 

# Copy local code to the container image.
COPY . .

# Run the web service on container startup.
CMD [ "npm", "start" ]

# Document that the service listens on port 3000.
EXPOSE 3000
```
### Docker Compose File

```
version: '3.8'

services:
  nodejs-app:
    build: .
    container_name: nodejs-app
    ports:
      - "3000:3000"
    environment:
      - REDIS_HOST=redis
      - REDIS_PORT=6379
      - MYSQL_HOST=mysql
      - MYSQL_PORT=3306
      - MYSQL_USER=root
      - MYSQL_PASSWORD=Root@123
      - MYSQL_DATABASE=nodejs_api
    depends_on:
      mysql:
        condition: service_healthy
      redis:
        condition: service_started
    networks:
      - app-network

  redis:
    image: redis:alpine
    container_name: redis
    ports:
      - "6379:6379"
    networks:
      - app-network

  mysql:
    image: mysql:5.7
    container_name: mysql
    environment:
      MYSQL_ROOT_PASSWORD: Root@123
      MYSQL_DATABASE: nodejs_api
    ports:
      - "3306:3306"
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
```
## Deployment
### Deploy to Remote Server
 ```
ssh -o StrictHostKeyChecking=no ubuntu@157.175.4.250 '
cd /home/ubuntu/deploy &&
docker compose pull &&
docker compose up -d'

 ```
### Environment Variables 
- REDIS_HOST: Hostname for Redis (default: redis)
- REDIS_PORT: Port for Redis (default: 6379)
- MYSQL_HOST: Hostname for MySQL (default: mysql)
- MYSQL_PORT: Port for MySQL (default: 3306)
- MYSQL_USER: MySQL username (default: root)
- MYSQL_PASSWORD: MySQL password (default: Root@123)
- MYSQL_DATABASE: MySQL database name (default: nodejs_api)

# Terraform AWS Infrastructure Setup

## Introduction

This project uses Terraform to provision and manage a cloud infrastructure on AWS. It includes resources such as Virtual Private Clouds (VPCs), EC2 instances, IAM roles, RDS databases, and security groups. The infrastructure is modular, allowing for flexible configuration and scalability.

## Table of Contents

- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Setup and Installation](#setup-and-installation)
- [Terraform Modules](#terraform-modules)
- [Variables](#variables)
- [Outputs](#outputs)


## Project Structure

```plaintext
.
├── main.tf
├── modules
│   ├── ec2
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── iam
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── rds
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── security_groups
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── vpc
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── outputs.tf
├── provider.tf
├── terraform.tfstate
├── terraform.tfstate.backup
└── variables.tf
```
File Descriptions
- main.tf: The main entry point for Terraform configuration, where the modules - are instantiated.
- modules/: Directory containing reusable Terraform modules for different AWS resources.
- ec2/: Manages EC2 instances.
- iam/: Manages IAM roles and policies.
- rds/: Manages RDS database instances.
- security_groups/: Manages security groups for network access control.
- vpc/: Manages VPCs, subnets, and related networking resources.
- outputs.tf: Defines the outputs for the Terraform configuration.
- provider.tf: Specifies the provider configuration, such as AWS credentials and region.
- terraform.tfstate: Stores the Terraform state file, which tracks resource states.
- terraform.tfstate.backup: Backup of the Terraform state file.
- variables.tf: Defines input variables for the Terraform configuration.
Prerequisites
Before you begin, ensure you have met the following requirements:

- Terraform installed
- The S3 bucket and DynamoDB must be updated in the provider.tf
- AWS account with necessary permissions
- AWS CLI configured with access keys
- Git installed for version control


## Setup and Installation

### 1.Clone the Repository:

```bash
git clone https://github.com/yourusername/terraform-aws-infrastructure
cd terraform-aws-infrastructure
```
### 2.Configure AWS Credentials:
```bash 
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key
```
### deploy 
```bash
terraform init 
terraform plan
terraform apply  
```

# Kubernetes Deployment for Node.js and Redis Application

## Introduction

This module describes the deployment of a Node.js application along with a Redis instance on a Kubernetes cluster. The setup includes configuration management using ConfigMaps and Secrets, network exposure with Services and Ingress, and application scaling with a Horizontal Pod Autoscaler (HPA). All configurations are contained within a single YAML file.

## Table of Contents

- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Kubernetes Configuration](#kubernetes-configuration)
- [Deployment Instructions](#deployment-instructions)

## Project Structure

```plaintext
└── kubernetes-manifest.yaml
```
### File Descriptions
k8s-deployment.yaml: Contains the entire Kubernetes configuration, including namespace, ConfigMap, Secret, Deployment, Service, Ingress, and Horizontal Pod Autoscaler (HPA).

### Prerequisites
Before deploying the application, ensure you have the following:

- A Kubernetes cluster (local or cloud-based)
- kubectl configured to interact with the cluster
- Ingress controller installed (e.g., NGINX Ingress Controller)
- Optional: A domain name configured to point to your cluster's external IP


### Kubernetes Configuration
The following sections describe the Kubernetes resources defined in the kubernetes-manifest.yaml file:

### 1. Namespace
Create a dedicated namespace for the application to isolate resources:
```
apiVersion: v1
kind: Namespace
metadata:
  name: app-namespace
```
### 2. ConfigMap
The ConfigMap stores application configuration data, such as hostnames and ports for Redis and MySQL:
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: app-namespace
data:
  REDIS_HOST: "<--changeme-->"
  REDIS_PORT: "<--changeme-->"
  MYSQL_HOST: "<--changeme-->"
  MYSQL_PORT: "<--changeme-->"
  MYSQL_DATABASE: "<--changeme-->"
```


### 3.Secret
The Secret manages sensitive data, such as MySQL credentials:
```
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
  namespace: app-namespace
type: Opaque
stringData:
  MYSQL_USER: "<--changeme-->"
  MYSQL_PASSWORD: "<--changeme-->"
```
### Deployment
Deploy the Node.js and Redis containers within a single pod: 2 container on 1 pod as needed
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nodejs-app
  namespace: app-namespace
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nodejs-app
  template:
    metadata:
      labels:
        app: nodejs-app
    spec:
      containers:
      - name: nodejs-app
        image: <--changeme-->
        ports:
        - containerPort: 3000
        env:
        - name: REDIS_HOST
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: REDIS_HOST
        - name: REDIS_PORT
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: REDIS_PORT
        - name: MYSQL_HOST
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: MYSQL_HOST
        - name: MYSQL_PORT
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: MYSQL_PORT
        - name: MYSQL_DATABASE
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: MYSQL_DATABASE
        - name: MYSQL_USER
          valueFrom:
            secretKeyRef:
              name: app-secret
              key: MYSQL_USER
        - name: MYSQL_PASSWORD
          valueFrom:
            secretKeyRef:
              name: app-secret
              key: MYSQL_PASSWORD
      - name: redis
        image: redis:alpine
        ports:
        - containerPort: 6379
```
### 5. Service
Expose the application within the cluster:
```
apiVersion: v1
kind: Service
metadata:
  name: nodejs-app-service
  namespace: app-namespace
spec:
  selector:
    app: nodejs-app
  ports:
  - protocol: TCP
    port: 3000
    targetPort: 3000
  type: ClusterIP
```
### 6. Ingress
Manage external access to the application using an Ingress resource:

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nodejs-app-ingress
  namespace: app-namespace
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: <--changeme-->
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nodejs-app-service
            port:
              number: 3000

```

### 7. Horizontal Pod Autoscaler (HPA)
Configure horizontal scaling of pods based on CPU utilization:
```
apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
metadata:
  name: nodejs-app-hpa
  namespace: app-namespace
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nodejs-app
  minReplicas: 1
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50


 ```
 ### Deployment Instructions
To do eploy the application, follow these steps:

Step 1: Apply the Configuration
Apply the single YAML file containing all configurations:

```bash
kubectl apply -f k8s-deployment.yaml
```
Step 2: Verify the Deployment
Check the status of the deployment to ensure everything is running correctly:

```bash
kubectl get all -n app-namespace
```

# Monitoring and Logging Module

## Introduction

This module provides a comprehensive monitoring and logging solution for your applications using Docker Compose. It includes Prometheus for monitoring, Grafana for visualization, and the ELK stack (Elasticsearch, Logstash, and Kibana) for centralized logging. This setup allows you to monitor application metrics, visualize data, and analyze logs in a cohesive environment.

## Table of Contents

- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)

## Project Structure

```plaintext
.
├── docker-compose.yml
├── logstash
│   └── pipeline
│       └── logstash.conf
└── prometheus
    └── prometheus.yml
```
File Descriptions
- docker-compose.yml: Docker Compose configuration file for setting up all services.
- logstash/pipeline/logstash.conf: Logstash configuration file for processing incoming logs and sending them to Elasticsearch.
- prometheus/prometheus.yml: Prometheus configuration file for scraping metrics from the Node.js application.

## Prerequisites
Before starting, ensure you have the following installed on your machine:

- Docker: 
- Docker Compose

## Setup Instructions
```bash
cd monitoring-and-logging-module-four
``` 
```bash 
docker compose up -d
```
# Security Integration Module

## Introduction

This module focuses on integrating security measures into your CI/CD pipeline and Kubernetes environment. It leverages OWASP ZAP for dynamic application security testing (DAST) and implements Kubernetes network policies to control traffic between application components. These practices help ensure that your application is secure against common vulnerabilities and unauthorized access.

## Table of Contents

- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
- [DAST with OWASP ZAP](#dast-with-owasp-zap)
- [Kubernetes Network Policies](#kubernetes-network-policies)
- [Usage](#usage)


## Project Structure

```plaintext

├── Jenkinsfile
└── networkpolicy.yaml
```
File Descriptions
- Jenkinsfile: Defines the CI/CD pipeline with stages for building, testing, - - scanning, and deploying the application.
- networkpolicy.yaml: Contains Kubernetes network policies for securing - pod-to-pod communication.


## Prerequisites
Before you begin, ensure you have the following:

- Jenkins: Installed and configured for running pipelines.
- Docker: Installed on your Jenkins server.
- Kubernetes Cluster: With kubectl configured to manage it.
- SSH Access: For deployment to remote servers.
- OWASP ZAP: Available as a Docker image.


### Setup Instructions
```
cd security-integration-module-five
```


### 2.Configure Jenkins:

- Install required Jenkins plugins:
- Docker Pipeline
- SSH Agent
- NodeJS Plugin
- Set up NodeJS in Jenkins global tools configuration.
- Add Credentials:

- DockerHub Credentials: For pushing Docker images.
 SSH Credentials: For remote server deployment.


Modify Jenkinsfile:

### Update the Jenkinsfile with your specific configuration:
```
environment {
    registry = "yourdockerusername/yourimagename"
    remoteServer = 'your.remote.server.ip'
    TARGET_URL = 'http://your-application-url/'
}
``` 
### DAST Stage in Jenkins Pipeline 
```
stage('Dynamic Analysis - DAST with OWASP ZAP') {
    steps {
        script {
            // Run ZAP baseline scan and print the output to the screen
            sh '''
            docker run -t ghcr.io/zaproxy/zaproxy:stable zap-baseline.py -t "$TARGET_URL" || true
            '''
        }
    }
}

```
### Kubernetes Network Policies
```
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: app-namespace
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-redis
  namespace: app-namespace
spec:
  podSelector:
    matchLabels:
      app: redis
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: nodejs-app
    ports:
    - protocol: TCP
      port: 6379
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-mysql
  namespace: app-namespace
spec:
  podSelector:
    matchLabels:
      app: mysql
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: nodejs-app
    ports:
    - protocol: TCP
      port: 3306
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-nodejs
  namespace: app-namespace
spec:
  podSelector:
    matchLabels:
      app: nodejs-app
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: redis
    - podSelector:
        matchLabels:
          app: mysql
    ports:
    - protocol: TCP
      port: 3000

```

### Benefits of Network Policies:
- Trafic Control: Restricts communication between pods to prevent unauthorized access.
- Enhanced Security: Reduces the attack surface by limiting pod-to-pod communication.
- Compliance: Helps meet security compliance requirements by enforcing network segmentation.

### Usage
Deploy Network Policies
Apply the network policies to the Kubernetes cluster:
```bash 
kubectl apply -f networkpolicy.yaml
```
# Automation Script Deliverables: Module Six

## Introduction

This module contains automation scripts designed to handle various tasks related to application maintenance and security. The scripts included are:

1. **rotate_credentials.py**: Automatically rotates database credentials for improved security.
2. **database-backup.py**: Creates backups of the MySQL database to prevent data loss.
3. **health-check.py**: Performs health checks on the application to ensure it's running correctly.

These scripts are intended to automate routine maintenance tasks and provide an added layer of security to your application infrastructure.

## Table of Contents

- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Script Details](#script-details)
  - [rotate_credentials.py](#rotate_credentialspy)
  - [database-backup.py](#database-backuppy)
  - [health-check.py](#health-checkpy)
- [Setup Instructions](#setup-instructions)
- [Usage](#usage)


## Project Structure

```plaintext
.
├── rotate_credentials.py
├── database-backup.py
└── health-check.py
```

### Prerequisites
Before using the scripts, ensure that you have the following:

- Python 3.x: Installed on your machine. You can download it from python.org.
- Docker: Installed and running on your machine. Refer to the Docker -
 ## installation guide for setup instruction 
- MySQL Connector for Python: Installable via pip (pip install mysql-connector-python).
- Requests library for Python: Installable via pip (pip install requests).


## Script Details
### rotate_credentials.py
This script is responsible for rotating MySQL database credentials. It connects to the MySQL database inside a Docker container, creates a new user with a randomly generated username and password, grants the necessary privileges, and restarts the Docker container to apply the changes.

### Key Features
Automatic Credential Rotation: Generates a new username and password using a secure random string.
Privilege Management: Grants all necessary privileges to the new user.
Docker Integration: Restarts the Docker container to ensure changes are applied.

### Code Overview
```
import mysql.connector
import subprocess
import random
import string

# Function to generate a random password
def generate_random_string(length=12):
    return ''.join(random.choice(string.ascii_letters + string.digits) for _ in range(length))

# Update MySQL credentials
def update_mysql():
    new_user = "user_" + generate_random_string(6)
    new_password = generate_random_string()

    try:
        # Connect to MySQL inside the Docker container
        conn = mysql.connector.connect(
            host='localhost',
            user='root',
            password='Root@123',  # Old password
            database='nodejs_api'
        )
        cursor = conn.cursor()
        
        # Create a new user with the new password
        cursor.execute(f"CREATE USER '{new_user}'@'%' IDENTIFIED BY '{new_password}';")
        cursor.execute(f"GRANT ALL PRIVILEGES ON *.* TO '{new_user}'@'%' WITH GRANT OPTION;")
        conn.commit()
        
        print(f"New credentials: User='{new_user}', Password='{new_password}'")

    except Exception as e:
        print(f"Error: {e}")
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()

# Restart Docker container
def restart_container():
    subprocess.run(["docker", "restart", "mysql"])
    print("Docker container restarted successfully.")

# Main function to run the script
def main():
    update_mysql()
    restart_container()

if __name__ == "__main__":
    main()

```

### database-backup.py
This script performs a backup of the MySQL database by executing a mysqldump command within a Docker container. It saves the backup file with a timestamp in a specified directory.

### Key Features
Automated Backups: Uses the mysqldump tool to create database backups.
Timestamped Files: Saves backup files with a timestamp to easily track backup versions.
Custom Backup Directory: Allows setting a custom directory for storing backups.
### Code Overview
```
import subprocess
from datetime import datetime
import os

# Environment variables for security
MYSQL_HOST = 'localhost'
MYSQL_PORT = '3306'
DB_NAME = os.getenv('DB_NAME', 'nodejs_api')
DB_USER = os.getenv('DB_USER', 'root')
DB_PASSWORD = os.getenv('DB_PASSWORD', 'Root@123')
BACKUP_DIR = '/home/shalan/Desktop'

def create_backup_directory():
    if not os.path.exists(BACKUP_DIR):
        os.makedirs(BACKUP_DIR)

def backup_database():
    create_backup_directory()
    backup_file = f"{BACKUP_DIR}/{DB_NAME}_backup_{datetime.now().strftime('%Y%m%d%H%M%S')}.sql"
    command = f"docker exec mysql mysqldump -u {DB_USER} -p{DB_PASSWORD} {DB_NAME} > {backup_file}"
    try:
        subprocess.run(command, shell=True, check=True, executable='/bin/bash')
        print(f"Backup created: {backup_file}")
    except subprocess.CalledProcessError as e:
        print(f"Error backing up database: {e}")

def main():
    backup_database()

if __name__ == "__main__":
    main()

```

###health-check.py
This script performs a health check on the application by sending an HTTP GET request to the application's /metrics endpoint. It determines the health status based on the HTTP response code.

### Key Features
Endpoint Monitoring: Checks the health of the application by hitting a specific endpoint.
Status Reporting: Provides feedback on whether the application is healthy or not.
Customizable Endpoint: Allows changing the target endpoint for different applications or environments.
### Code Overview
```
import requests

# Health check
# you can change the following localhost endpoint to your live endpoint 
try:
    response = requests.get('http://localhost:3000/metrics')
    if response.status_code == 200:
        print("Application is healthy.")
    else:
        print("Application is not healthy.")
except Exception as e:
    print(f"Error performing health check: {e}")

```


## Usage
### Running rotate_credentials.py
Rotate the database credentials using the following command:
```bash
python rotate_credentials.py
```
### Running database-backup.py
Create a backup of the database: 
```bash
python database-backup.py

```
### Running health-check.py
```bash 
python health-check.py

```

# Configuration Management Module

## Introduction

This module provides an Ansible playbook to configure a web server using Nginx as a reverse proxy with SSL certificates from Let's Encrypt. This setup ensures secure traffic management for your web application.

## Project Structure

```plaintext
.
├── inventory.ini
├── key.pem
└── playbook.yml
```

## File Descriptions
- inventory.ini: Defines the target web server and connection details.
- key.pem: SSH private key for accessing the server.
- playbook.yml: Ansible playbook to set up Nginx and SSL certificates.
## Prerequisites
- Ansible: Installed locally.
- SSH Access: Ensure access to the target server.
- Domain Name: Pointed to the server's IP.

## Setup Instructions
#### Edit Inventory:

Update inventory.ini with your server IP and SSH details

### Configure Playbook:

Set your domain and backend server details in playbook.yml.
```
vars:
  domain_name: your-domain.com
  backend_server: your-backend-ip
  backend_port: 8080

```
### Add you private Key in key.pem 

## Running the Playbook
#### Execute the playbook with:

```bash
ansible-playbook -i inventory.ini playbook.yml
```


