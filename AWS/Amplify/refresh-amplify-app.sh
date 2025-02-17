#!/bin/bash

# When you push changes to your GitHub repository that is connected to AWS Amplify, the frontend will automatically rebuild and redeploy without requiring any additional CLI commands.

# This is part of Amplify's built-in CI/CD pipeline functionality. [1]

# However, if you need to manually trigger a new build/deployment, you can use the AWS CLI to start a new job:

aws amplify start-job --app-id YOUR_APP_ID --branch-name YOUR_BRANCH_NAME --job-type RELEASE

# You'll need to replace:

    # YOUR_APP_ID with your Amplify app ID [2]

    # YOUR_BRANCH_NAME with the name of your branch (e.g., "main" or "master")



# If you want to check the status of your deployment, you can use:

aws amplify list-jobs --app-id YOUR_APP_ID --branch-name YOUR_BRANCH_NAME

# But in most cases, you shouldn't need these commands since pushing to your connected GitHub repository will automatically trigger a new build and deployment of your frontend application.
