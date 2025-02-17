#!/bin/bash

##########################################################################################################
# THIS SCRIPT NEEDS ARGUMENTS:

    # - The desired app name

    # - Your GitHub repository URL

    # - A GitHub personal access token with appropriate permissions

##########################################################################################################
# To run:

    # ./create-amplify-via-gh.sh "My App Name" "https://github.com/username/repo" "your-github-token"

##########################################################################################################
# Before running the script:

    # - Make sure your GitHub repository is properly set up with your application code before running the script.

    # - The repository should contain your application files including the index.html at the appropriate location according to your build settings.

    # - Make sure you have AWS CLI installed

    # - Configure AWS credentials (aws configure)

    # - Make the script executable: chmod +x create-amplify-via-gh.sh


##########################################################################################################
# For a React application deployed to AWS Amplify, the standard structure should have your index file in the following location:

# your-react-app/
# ├── public/
# │   ├── index.html      # The main HTML file
# │   ├── favicon.ico
# │   └── manifest.json
# ├── src/
# │   ├── index.js        # The main JavaScript entry point
# │   ├── App.js
# │   └── ...
# ├── package.json
# └── ...

# The index.html should be in the public directory, while your main application entry point index.js should be in the src directory. This is the default structure created by Create React App (CRA).

# For Amplify to build and deploy your React application correctly, you should also have a proper build configuration. Here's what you typically need in your amplify.yml file at the root of your project:

# version: 1
# frontend:
#   phases:
#     preBuild:
#       commands:
#         - npm install
#     build:
#       commands:
#         - npm run build
#   artifacts:
#     baseDirectory: build
#     files:
#       - '**/*'
#   cache:
#     paths:
#       - node_modules/**/*


# This configuration tells Amplify to:

    # 1. Install dependencies using npm install [3]

    # 2. Build your React app using npm run build

    # 3. Serve the contents of the build directory

    # 4. Cache the node_modules directory for faster subsequent builds



# Your package.json should have the necessary scripts, particularly:

# {
#   "scripts": {
#     "start": "react-scripts start",
#     "build": "react-scripts build",
#     "test": "react-scripts test",
#     "eject": "react-scripts eject"
#   }
# }


# When Amplify builds your React application, it will process your src/index.js file along with all its dependencies, and the resulting built files will be based on the template in public/index.html.


##########################################################################################################



##########################################################################################################
# THE SCRIPT
export AWS_PAGER=""  # Disable the AWS CLI pager

# Exit on any error
set -e

# Check if required parameters are provided
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo "Usage: $0 <app-name> <github-repo-url> <github-access-token>"
    echo "Example: $0 'My App' 'https://github.com/username/repo' 'ghp_xxxxxxxxxxxx'"
    exit 1
fi

echo "Starting Amplify deployment process..."

# Get the current timestamp for unique app name
TIMESTAMP=$(date +%Y.%m.%d.%H:%M:%S)
NAME=$1
GITHUB_REPO=$2
GITHUB_TOKEN=$3
APP_NAME="${NAME} - ${TIMESTAMP}"

# Create a new Amplify app connected to GitHub
echo "Creating Amplify app..."
APP_ID=$(aws amplify create-app \
    --name "${APP_NAME}" \
    --repository "${GITHUB_REPO}" \
    --access-token "${GITHUB_TOKEN}" \
    --query 'app.appId' \
    --output text)

if [ -z "$APP_ID" ]; then
    echo "Error: Failed to create Amplify app"
    exit 1
fi

# Create main branch
echo "Creating branch..."
aws amplify create-branch \
    --app-id "${APP_ID}" \
    --branch-name "main"

# Wait for deployment to complete
echo "Waiting for initial deployment..."
DEPLOY_TIMEOUT=300  # 5 minute timeout
ELAPSED=0
INTERVAL=10  # Check every 10 seconds

while [ $ELAPSED -lt $DEPLOY_TIMEOUT ]; do
    # Get the active job ID
    ACTIVE_JOB_ID=$(aws amplify get-branch \
        --app-id "${APP_ID}" \
        --branch-name "main" \
        --query 'branch.activeJobId' \
        --output text)

    if [ "$ACTIVE_JOB_ID" != "None" ]; then
        # Get the status of the active job
        JOB_STATUS=$(aws amplify get-job \
            --app-id "${APP_ID}" \
            --branch-name "main" \
            --job-id "${ACTIVE_JOB_ID}" \
            --query 'job.summary.status' \
            --output text)

        if [ "$JOB_STATUS" = "SUCCEED" ]; then
            echo "Deployment completed successfully!"
            break
        elif [ "$JOB_STATUS" = "FAILED" ]; then
            echo "Deployment failed. Please check the AWS Amplify Console"
            exit 1
        else
            echo "  Deployment status: ${JOB_STATUS}... Timeout after: ${DEPLOY_TIMEOUT}s... Time elapsed: ${ELAPSED}s..."
            sleep $INTERVAL
            ELAPSED=$((ELAPSED + INTERVAL))
        fi
    else
        echo "Waiting for deployment to start..."
        sleep $INTERVAL
        ELAPSED=$((ELAPSED + INTERVAL))
    fi
done

if [ $ELAPSED -ge $DEPLOY_TIMEOUT ]; then
    echo "  Deployment verification timed out after ${DEPLOY_TIMEOUT} seconds"
    echo "Please check the AWS Amplify Console for deployment status..."
    exit 1
fi

# Get the full URL of the app
echo "Getting app information..."
FULL_URL=$(aws amplify get-app --app-id "${APP_ID}" --query 'app.defaultDomain' --output text)
FULL_URL="https://main.${FULL_URL}"
echo "App ID: ${APP_ID}"
echo "App URL: ${FULL_URL}"

# Open the URL in the default browser based on the operating system
echo "Opening app in default browser..."
sleep 5
case "$(uname -s)" in
    Linux*)     xdg-open "$FULL_URL";;
    Darwin*)    open "$FULL_URL";;
    CYGWIN*|MINGW32*|MSYS*|MINGW*) start "$FULL_URL";;
    *)          echo "Please visit: $FULL_URL";;
esac

echo "Your app is now deployed via AWS Amplify!"
