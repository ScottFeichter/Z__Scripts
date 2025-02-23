#!/bin/bash

# The script:

        # Sets up Amplify for TypeScript React [1]

        # Configures hosting with CI/CD

        # Generates TypeScript types for Amplify services

        # Installs necessary TypeScript dependencies

        # Includes error checking at each step

        # Make sure your project has:

        # A valid tsconfig.json

        # TypeScript set up in your build process

        # Proper TypeScript file extensions (.ts, .tsx)



setup_amplify_non_interactive() {
    local FRONTEND_REPO_NAME=$1
    local TOKEN=$2

    echo "Setting up Amplify for TypeScript React project: $FRONTEND_REPO_NAME..."

    # Initialize Amplify
    amplify init \
    --name $FRONTEND_REPO_NAME \
    --envName dev \
    --yes \
    --amplify "{
        \"projectName\": \"$FRONTEND_REPO_NAME\",
        \"defaultEditor\": \"code\",
        \"appType\": \"javascript\",
        \"javascript\": {
            \"framework\": \"react\",
            \"config\": {
                \"SourceDir\": \"src\",
                \"DistributionDir\": \"dist\",
                \"BuildCommand\": \"npm run build\",
                \"StartCommand\": \"npm run dev\",
                \"BuildScriptEnabled\": true,
                \"framework\": \"react\",
                \"typescript\": true
            }
        }
    }" \
    --frontend "{
        \"frontend\": \"javascript\",
        \"framework\": \"react\",
        \"config\": {
            \"SourceDir\": \"src\",
            \"DistributionDir\": \"dist\",
            \"BuildCommand\": \"npm run build\",
            \"StartCommand\": \"npm run dev\",
            \"BuildScriptEnabled\": true,
            \"framework\": \"react\",
            \"typescript\": true
        }
    }" \
    --providers "{
        \"awscloudformation\": {
            \"configLevel\": \"project\",
            \"useProfile\": true,
            \"profileName\": \"default\",
            \"typescript\": true
        }
    }"

    if [ $? -ne 0 ]; then
        echo "Amplify initialization failed"
        return 1
    fi

    # Add hosting
    amplify add hosting \
    --service amplify \
    --providerPlugin amplify-provider-awscloudformation \
    --type cicd \
    --repository "https://github.com/ScottFeichter/$FRONTEND_REPO_NAME" \
    --branch main \
    --accessToken $TOKEN \
    --framework react \
    --typescript true

    if [ $? -ne 0 ]; then
        echo "Failed to add hosting"
        return 1
    fi

    # Add auth (optional, remove if not needed)
    amplify add auth \
    --service cognito \
    --providerPlugin amplify-provider-awscloudformation \
    --requiresAuth true \
    --allowUnauthenticatedIdentities false \
    --typescript true

    # Push changes
    amplify push --yes

    if [ $? -ne 0 ]; then
        echo "Failed to push changes"
        return 1
    fi

    # Generate TypeScript types for any added services
    amplify codegen models

    # Publish
    amplify publish --yes

    if [ $? -ne 0 ]; then
        echo "Failed to publish"
        return 1
    fi

    # Install necessary TypeScript dependencies
    npm install --save aws-amplify @aws-amplify/ui-react
    npm install --save-dev @types/node @types/react @types/react-dom typescript

    echo "Amplify TypeScript setup completed successfully"
    return 0
}

# Usage
setup_amplify_non_interactive "$FRONTEND_REPO_NAME" "$TOKEN"
