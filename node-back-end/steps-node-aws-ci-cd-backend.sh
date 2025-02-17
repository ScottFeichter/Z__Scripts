#!/bin/bash
########################################################################################################################################################
# NOTE ABOUT APP CLEANUP

                # WHEN YOU WANT TO DELTE AN APP'S AWS RESOURCES:

                        # 1. Run the VPC deletion script first (handles all networking/compute)
                        # 2. Then clean up any non-VPC resources your app uses

                # Recourses NOT deleted with the VPC:

                        # 1. S3 Buckets
                        # 2. DynamoDB Tables
                        # 3. IAM Roles/Users/Policies
                        # 4. Route 53 DNS Records
                        # 5. CloudFront Distributions
                        # 6. ECR Repositories
                        # 7. CloudWatch Logs
                        # 8. Lambda Functions (unless VPC-connected)
                        # 9. Certificates (ACM)
                        # 10. Amplify Applications




########################################################################################################################################################
# HIGH LEVEL OVERVIEW

# Building a node app and deploying on AWS using CI/CD:

        # Front End
                # 1. Develop the front end locally and use git with github for version control.
                # 2. Deploy the front end with Amplify via the github repo.
                
                # (NOTE the front end should not be in a VPC)

        # Back End
                # 1. Develop the back end locally and use git with github for version control.
                # 2. Create VPC
                # 3. Create and attach Gateway to VPC
                # 4. Create Public Subnet (for EC2
                # 5. Create Private Subnet (for RDS)
                # 6. Create Route Tables
                # 7. Create Security Groups
                # 8. Create EC2 Instance (in public subnet)
                # 9. Create EBS volume and attach to EC2 Instance
                # 10. Install nvm on EC2
                # 11. Install node.js on EC2
                # 12. Create RDS Instance (in private subnet)
                # 13. Use GitHub Actions, Code Deploy, or CodePipeline to integrate the app to the AWS services


########################################################################################################################################################
# OVERVIEW

        # Frontend:

                # 1.  Develop locally & use GitHub

                        #     *   Create React/Vue/Angular app

                        #     *   Set up environment variables for API endpoints

                        #     *   Test API integration locally

                # 2.  Deploy with Amplify

                        #     *   Connect to GitHub repository

                        #     *   Configure build settings

                        #     *   Set up environment variables in Amplify console


        # Backend:

                # 1.  Develop locally & use GitHub

                        #     *   Set up proper project structure

                        #     *   Create package.json and lock file

                        #     *   Write tests

                        #     *   Use environment variables for configurations


                # 2-7. VPC Setup (Networking)

                        # *   VPC with appropriate CIDR block

                        # *   Internet Gateway for public access

                        # *   Public subnet for EC2 (API access)

                        # *   2 Private subnet for RDS (database security)

                        # *   Route tables for proper traffic flow

                        # *   Security Groups:

                                #     *   EC2: Allow HTTP/HTTPS from internet

                                #     *   RDS: Allow PostgreSQL only from EC2


                # 8-9. EC2 & EBS Setup

                        # *   EC2 in public subnet

                        # *   EBS for persistent storage

                        # *   Mount EBS to /app directory


                # 10-11. Runtime Setup

                        # *   Install nvm for Node.js version management

                        # *   Install Node.js LTS version

                        # *   (Note: Future deployments will handle dependencies)


                # 12.  Database Setup


                        # *   RDS in private subnet

                        # *   Set strong master password

                        # *   Configure backup retention

                        # *   Set up monitoring


                # 13.  CI/CD Pipeline


                        # *   Choose one: GitHub Actions/CodeDeploy/CodePipeline 

                                # *   Configure deployment scripts

                                # *   Set up environment variables

                                # *   Configure automatic deployments

                                # *   Set up logging and monitoring


        # Key things to remember:

                # *   Never commit sensitive data to GitHub

                # *   Use environment variables for configurations

                # *   Set up proper error logging

                # *   Configure automated backups

                # *   Implement proper security measures

                # *   Test your CI/CD pipeline thoroughly



##########################################################################BACKEND#######################################################################
########################################################################################################################################################
# 1. Develop Locally backend and use a CI/CD pipeline to get code to your AWS services


        # Handle npm initialization and dependencies in your local development environment. not directly on the EC2 instance.

        # Here's the correct workflow:
            # 1. Local Development:
                # On your local machine:
                    # mkdir my-node-app
                    # cd my-node-app
                    # npm init
                    # npm install express # (or whatever packages you need)

            # 2. Include the following files in your repository:

                    # my-node-app/
                    # ├── package.json
                    # ├── package-lock.json
                    # ├── .gitignore
                    # ├── src/
                    # │   ├── index.js
                    # │   ├── routes/
                    # │   ├── controllers/
                    # │   └── models/
                    # ├── tests/
                    # └── .github/workflows/
                    #     └── deploy.yml

            # 3. Your GitHub Actions workflow will handle the installation on deployment: (This will be the last step at end of this doc)


                    name: Deploy to EC2
                    on:
                        push:
                            branches: [ main ]
                        jobs:
                        deploy:
                            runs-on: ubuntu-latest
                            steps:
                            - uses: actions/checkout@v2

                            - name: Setup Node.js
                            uses: actions/setup-node@v2
                            with:
                                node-version: '18'

                            - name: Install dependencies
                            run: npm ci # Uses package-lock.json for exact versions

                            - name: Deploy to EC2
                            uses: appleboy/ssh-action@master
                            with:
                                host: ${{ secrets.EC2_HOST }}
                                username: ec2-user
                                key: ${{ secrets.EC2_SSH_KEY }}
                                script: |
                                    cd /app/nodejs
                                    git pull
                                    npm ci --production
                                    npm run build
                                    pm2 restart all

            # (instead of Actions you could use CodeDeploy or CodePipeline)


            # The pipeline will:

                    # Get your code from GitHub

                    # Install dependencies

                    # Run tests

                    # Build the application

                    # Deploy to EC2

                    # Restart the application

            # The EBS volume at /app will still store:

                    # The deployed application code

                    # node_modules (installed by the deployment process)

                    # Application logs

                    # Uploaded files

                    # Backups

                    # Other runtime data

            # Key points:

                    # ✅ Initialize and develop your project locally

                    # ✅ Use version control (Git/GitHub)

                    # ✅ Let the CI/CD pipeline handle deployment and dependency installation

                    # ❌ Don't run npm commands directly on the EC2 instance (except during troubleshooting) [1]

            # This approach ensures:

                    # Consistent dependencies across environments

                    # Version-controlled package.json and package-lock.json

                    # Automated, repeatable deployments

                    # Clean separation between development and production



########################################################################################################################################################
# 2. Create VPC

        # You should create a VPC first because:

                # Every EC2 instance must be launched into a VPC

                # Your RDS instance needs to be in the same VPC as your EC2 instance for secure communication [2]

                # The VPC provides the fundamental networking framework for all your resources

        # A typical VPC setup for your EC2/RDS architecture should include:

                # Public subnet(s) for your EC2 instance

                # Private subnet(s) for your RDS database

                # Internet Gateway for the public subnet

                # Security Groups for both EC2 and RDS

        # Here's the general order of creation:

                # 1. Create VPC
                #    └── Create Internet Gateway and attach to VPC
                #        └── Create Public Subnet (for EC2)
                #            └── Create Private Subnet (for RDS)
                #                └── Create Route Tables
                #                    └── Create Security Groups
                #                        ├── Create EC2 Instance
                #                        │   └── Create and Attach EBS Volume
                #                        └── Create RDS Instance



        # While AWS provides a default VPC, creating your own gives you:

                # Better security through network isolation

                # Fine-grained control over your network configuration

                # Proper separation of public and private resources

                # Better resource organization

        # Your EC2 instance will need to be in a public subnet (if it needs internet access), while your RDS instance should be in a private subnet for better security.


        # Amazon Amplify doesn't need to be in your VPC at all since it's a fully managed service that handles the hosting and deployment of your frontend separately from your VPC infrastructure.

                # Here's the recommended architecture:

                        # Internet
                        # │
                        # ├── Amplify (Frontend - managed by AWS, not in your VPC)
                        # │
                        # └── VPC
                        #     ├── Public Subnet
                        #     │   └── EC2 (Backend API)
                        #     │
                        #     └── Private Subnet
                        #         └── RDS (Database)

        # Your EC2 backend should be in a public subnet because:

                # It needs to receive API requests from your Amplify frontend

                # The EC2 instance needs internet access to:

                        # Receive application deployments

                        # Download updates and packages

                        # Communicate with other AWS services

        # The RDS database should stay in a private subnet because:

                # It only needs to communicate with your backend

                # It should never be directly accessible from the internet

                # It provides an additional layer of security

        # Security configuration:

                # EC2 Security Group:

                        # Inbound: Allow HTTPS/HTTP from Amplify

                        # Outbound: Allow traffic to RDS and internet

                # RDS Security Group:

                        # Inbound: Allow PostgreSQL (5432) only from EC2 Security Group

                        # Outbound: Deny all

                # This setup ensures:

                        # Your frontend can communicate with your backend API

                        # Your backend can communicate with the database

                        # The database is protected from direct internet access

                        # Your backend can receive deployments and updates




########################################################################################################################################################
# 3. Create Internet Gateway and attach to VPC

########################################################################################################################################################
# 4. Create Public Subnet (for EC2

########################################################################################################################################################
# 5. Create Private Subnet (for RDS)


########################################################################################################################################################
# 6. Create Route Tables


########################################################################################################################################################
# 7. Create Security Groups


########################################################################################################################################################
# 8. Create EC2 Instance in vpc public subnet


########################################################################################################################################################
# 9a. Create Elastic Block Storage


########################################################################################################################################################
# 9b. Log in to the EC2 instance shell locally using SSH via ID w Key

        # open terminal in same directory as pem folder
        # connect in EC2 console
        # click connect
        # click SSH Client
        # copy the example
        # paste it in the terminal and execute

########################################################################################################################################################
# 9c. Mount it to EC2

        # These commands are meant to be executed in the shell of your EC2 instance.

        # Connect to the EC2 instance shell

        # Before running these commands, make sure that the volume is successfully attached to your EC2 instance.

            # You can check this with:

            lsblk

        # Make sure that the device name (/dev/xvdf) matches the one shown in your EC2 dashboard, as AWS might show it as /dev/sdf but it is mapped as /dev/xvdf on the instance.

        # Here's how to prepare the volume for use after it's attached:

            # Format the volume (if it's new)
            sudo mkfs -t xfs /dev/xvdf

            # Create a mount point
            sudo mkdir /app

            # Mount the volume
            sudo mount /dev/xvdf /app

            # To configure automatic mounting on restart, add to /etc/fstab:
            echo '/dev/xvdf /app xfs defaults,nofail 0 2' | sudo tee -a /etc/fstab

        # The create EBS for EC2 script includes error checking and will wait for the volume to become available before attempting to attach it.

        # It also outputs the relevant IDs and device name for reference.

        # Remember that the EBS volume must be created in the same availability zone as the EC2 instance.

        # The script automatically handles this by querying the instance's availability zone.


########################################################################################################################################################
# 10a. Install nvm on the EC2 instance

        # For a Node.js setup on EC2 with an attached EBS volume, here's the recommended approach:

        # - Install nvm and Node.js on the EC2 instance itself (not specifically on the EBS volume).

        # - This is because nvm and Node.js are part of the system's runtime environment.

        # - Use the EBS volume for your application code, data, and logs.

        # - Here's the sequence of commands to set up Node.js using nvm on your EC2 instance:

            # Install nvm
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

            # Reload shell configuration file
            source ~/.bashrc

            # Activate nvm
            . ~/.nvm/nvm.sh

########################################################################################################################################################
# 10b. Install Node.js (includes npm) on the EC2 instance

            # Install Node.js (LTS version)
            nvm install --lts

            # Verify version of node
            node -v

            # Verify version of npm
            npm -v

            # Verify installation
            node -e "console.log('Running Node.js ' + process.version)"



########################################################################################################################################################

# 12. Create database in vpc private subnet

        # if you need a database, you should create an RDS PostgreSQL instance, but it doesn't "mount" to the EC2 instance like an EBS volume does.

        # Instead, your application running on the EC2 instance connects to RDS via a network connection. [1]

        # Here's how the components work together:

                #  EC2 Instance
                #     ├── EBS Volume (mounted at /app)
                #     │   ├── /app/nodejs (application code)
                #     │   ├── /app/logs   (application logs)
                #     │   └── /app/uploads (user uploads)
                #     │
                #     └── Application connects to RDS via network connection
                #             │
                #             └── RDS PostgreSQL Instance

        # To set this up:

                # - Create the RDS instance in local shell aws cli:

                        # Before running the command, you'll need to:

                            # Replace sg-xxxxxxxx with your actual security group ID

                            # Change the password to something secure

                                    # Don't use mypassword - create a strong password

                                    # Store the password securely - you'll need it for your application

                                    # The security group should only allow access from your EC2 instance

                                    # Consider using AWS Secrets Manager for credential management

                            # Make sure you're in the correct AWS region

                            # Ensure your VPC and security groups are properly configured

                                    aws rds create-db-instance \
                                        --db-instance-identifier my-postgres-db \
                                        --db-instance-class db.t3.micro \
                                        --engine postgres \
                                        --master-username mydbadmin \
                                        --master-user-password mypassword \
                                        --allocated-storage 20 \
                                        --vpc-security-group-ids sg-xxxxxxxx

                # The database will take several minutes to create and become available.

                # Verify the database creation with:

                        aws rds describe-db-instances --db-instance-identifier my-postgres-db


                # In your Node.js application, connect using environment variables:

                            const { Pool } = require('pg');
                                const pool = new Pool({
                                host: process.env.DB_HOST,     // Your RDS endpoint
                                database: process.env.DB_NAME,
                                user: process.env.DB_USER,
                                password: process.env.DB_PASSWORD,
                                port: process.env.DB_PORT || 5432,
                                });


                # Important security considerations:

                        # Create the RDS instance in a private subnet

                        # Configure security groups to:

                        # Allow EC2 → RDS connections on port 5432

                        # Deny direct public access to RDS

                        # Store database credentials in environment variables or AWS Secrets Manager

                        # Use SSL/TLS for database connections

                # Remember:

                        # RDS is managed by AWS (backups, updates, maintenance)

                        # EBS is for file storage (application code, uploads, logs)

                        # RDS connects via network, not mounting

                        # You cannot create a streaming replication from a self-managed PostgreSQL on EC2 to RDS PostgreSQL [3]

                # This setup gives you:

                        # Managed database service (RDS)

                        # Persistent file storage (EBS)

                        # Application runtime (EC2)

                        # Each component serves a different purpose in your architecture.

########################################################################################################################################################
# 13. Use AWS GitHub Actions, AWS CodeDeploy, or AWS CodePipeline to connect your EC2/EBS to GitHub repo

        # Using this CI/CD is strongly recommended because it:

            # Keeps your code safely in version control

            # Provides automated, repeatable deployments

            # Makes it easier to recover from errors

            # Enables team collaboration

            # Follows industry best practices

            # Makes it easier to set up additional environments (staging, testing, etc.)


        # You should still create the EC2 instance and attach the EBS volume! Here's why:

            # The EC2 instance and EBS volume are your infrastructure (where your app runs), while GitHub Actions/CodeDeploy/CodePipeline are your deployment tools (how your code gets there). [1]

        # Here's a typical setup:

            # Infrastructure:

                # EC2 Instance
                #     └── EBS Volume (mounted at /app)
                #         ├── /app/nodejs (application code)
                #         ├── /app/logs   (application logs)
                #         ├── /app/uploads (user uploads)
                #         └── /app/backup (backups)

        # Code & Deployment Flow:

                # Your Local Machine --> GitHub Repository --> CI/CD Pipeline --> EC2/EBS
                # (write code)         (store code)          (automate deploy)   (run app)

        # The EBS volume is still important because it:

                # Provides persistent storage for your application

                # Survives EC2 instance restarts

                # Can be backed up using snapshots

                # Can be moved to different EC2 instances if needed [2]

                # Stores your application logs, uploads, and other runtime data

                # The key difference is:

                # ❌ Don't: Write/develop code directly on the EBS volume

                # ✅ Do: Write code locally, push to GitHub, and let your CI/CD pipeline deploy it to EC2/EBS [3]



        # Here are the key differences between GitHub Actions, AWS CodeDeploy, and AWS CodePipeline: [1]

                # GitHub Actions:

                        # Built into GitHub

                        # Good for simpler deployments

                        # Free for public repositories

                        # Easier to set up if you're already using GitHub

                        # Handles both build and deploy steps

                # AWS CodeDeploy:

                    # AWS native service

                    # Focused specifically on deployment [2]

                    # More sophisticated deployment options:

                            # Rolling deployments

                            # Blue/green deployments

                            # Rollback capabilities

                    # Requires an application specification file

                # AWS CodePipeline:

                        # Full-featured CI/CD orchestration service

                        # Integrates multiple stages and services

                        # More complex but more powerful

                        # Can combine multiple AWS services:

                                # CodeBuild for building

                                # CodeDeploy for deployment

                                # CodeStar for source control


        # Typical Use Cases:

                # GitHub Actions:

                        # Small to medium projects

                        # Teams already using GitHub

                        # Simple deployment needs

                        # Need for quick setup

                # CodeDeploy:

                        # Complex deployment requirements

                        # Need for advanced deployment strategies

                        # Focus on deployment automation

                        # Already using other AWS services

                # CodePipeline:

                        # Complex, multi-stage pipelines

                        # Enterprise applications

                        # Need for advanced workflow control

                        # Deep AWS integration needed

                        # Multiple environments (dev, staging, prod)

        # Recommendations:

                # Start with GitHub Actions if:

                        # You're using GitHub

                        # Have a simpler application

                        # Need quick setup

                # Use CodeDeploy if:

                        # Need advanced deployment strategies

                        # Focus is on deployment automation

                        # Want AWS native tooling

                # Choose CodePipeline if:

                        # Need complex pipeline orchestration

                        # Have multiple stages/environments

                        # Want deep AWS service integration

                        # Enterprise-level requirements
