#!/bin/bash

# Rather than connecting your EC2 instance or EBS volume directly to GitHub, the recommended approach would be to:

# Set up a CI/CD pipeline using either:

    # GitHub Actions

    # AWS CodeDeploy

    # AWS CodePipeline


# For a simple but effective setup, you could use GitHub Actions to: [2]

    # Build your Node.js application

    # Deploy it to your EC2 instance

    # Copy files to your mounted EBS volume at /app
    

# Here's a basic example of a GitHub Actions workflow you could use:

    # name: Deploy to EC2

    # on:
    #   push:
    #     branches: [ main ]

    # jobs:
    #   deploy:
    #     runs-on: ubuntu-latest
    #     steps:
    #     - uses: actions/checkout@v2

    #     - name: Setup Node.js
    #       uses: actions/setup-node@v2
    #       with:
    #         node-version: '18'

    #     - name: Install dependencies
    #       run: npm ci

    #     - name: Deploy to EC2
    #       uses: appleboy/ssh-action@master
    #       with:
    #         host: ${{ secrets.EC2_HOST }}
    #         username: ec2-user
    #         key: ${{ secrets.EC2_SSH_KEY }}
    #         script: |
    #           cd /app/nodejs
    #           git pull
    #           npm install
    #           pm2 restart all # If using PM2 for process management



# You would need to:

    # Store your EC2 host address as EC2_HOST in GitHub secrets

    # Store your EC2 SSH private key as EC2_SSH_KEY in GitHub secrets

    # Ensure your EC2 security group allows SSH access from GitHub Actions


# This approach:

    # Keeps your code in version control

    # Automates the deployment process

    # Maintains proper separation between your code repository and production environment

    # Allows you to run tests before deployment

    # Provides deployment history and the ability to roll back if needed

    # Remember to properly secure your EC2 instance and use environment variables for sensitive information.




# The key reasons to use a CI/CD pipeline instead of direct connection:

    # Security: Proper credential management and access control

    # Reliability: Automated, consistent deployments

    # Rollback capability: Easy to revert problematic deployments

    # Testing: Ability to run tests before deployment

    # Audit trail: Track who deployed what and when

# If you're looking for a quick development setup, you could:

    # Set up a deployment user with limited permissions

    # Use environment variables for sensitive data

    # Create a deployment script that pulls from your repository

    # Use process managers like PM2 to handle application restarts

    # Remember: Never store credentials in your code or repository. Always use environment variables or AWS Secrets Manager for sensitive information.
