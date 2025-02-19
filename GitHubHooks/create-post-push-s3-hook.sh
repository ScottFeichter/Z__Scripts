#!/bin/bash


# To run this script call it with your s3 bucket name as the argument:

        # ./create-git-hook.sh your-bucket-name


# Features of this script:

        # *   Checks if you're in a Git repository

        # *   Creates the post-push hook with proper permissions

        # *   Includes error handling and logging

        # *   Verifies AWS CLI installation

        # *   Checks AWS credentials

        # *   Verifies S3 bucket exists

        # *   Excludes common unnecessary files

        # *   Provides feedback about recently modified files

        # *   Includes helpful status messages


# The script will:

        # 1.  Create the post-push hook

        # 2.  Make it executable

        # 3.  Configure it to sync with your specified S3 bucket

        # 4.  Verify everything is set up correctly


# After setup, every time you push to your repository, it will automatically sync your files to the specified S3 bucket.

# Remember:

        # *   Run this script from the root of your Git repository

        # *   Make sure you have AWS CLI installed and configured

        # *   The S3 bucket must already exist

        # *   You need appropriate AWS permissions



######################################################################################################
# create-git-hook.sh

# Check if we're in a Git repository
if [ ! -d .git ]; then
    echo "Error: Not a Git repository. Please run this script from the root of your Git repository."
    exit 1
fi

# Check if bucket name is provided
if [ -z "$1" ]; then
    echo "Please provide an S3 bucket name as argument"
    echo "Usage: ./create-git-hook.sh <bucket-name>"
    exit 1
fi

BUCKET_NAME=$1

# Create hooks directory if it doesn't exist
mkdir -p .git/hooks

# Create post-push hook
echo "Creating post-push hook..."
cat > .git/hooks/post-push << EOL
#!/bin/bash

# Log start of sync
echo "Starting sync to S3 bucket: ${BUCKET_NAME}"

# Sync to S3, excluding unnecessary files
aws s3 sync . s3://${BUCKET_NAME} \
    --exclude ".git/*" \
    --exclude "node_modules/*" \
    --exclude ".env" \
    --exclude ".DS_Store" \
    --exclude "*.log"

# Check if sync was successful
if [ \$? -eq 0 ]; then
    echo "Successfully synced to S3 bucket: ${BUCKET_NAME}"
else
    echo "Failed to sync to S3 bucket: ${BUCKET_NAME}"
    exit 1
fi

# Optional: List recently modified files in S3
echo "Recently modified files in S3:"
aws s3 ls s3://${BUCKET_NAME} --recursive --human-readable --summarize | tail -n 5
EOL

# Make the hook executable
chmod +x .git/hooks/post-push

# Verify the hook was created
if [ -x .git/hooks/post-push ]; then
    echo "Successfully created and configured post-push hook"
    echo "Hook location: .git/hooks/post-push"
    echo "The hook will sync to S3 bucket: ${BUCKET_NAME}"
else
    echo "Failed to create post-push hook"
    exit 1
fi

# Check AWS CLI is installed and configured
if ! command -v aws &> /dev/null; then
    echo "Warning: AWS CLI is not installed. Please install it to use the S3 sync feature."
    exit 1
fi

# Test AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    echo "Warning: AWS credentials not configured. Please run 'aws configure' to set up your credentials."
    exit 1
fi

# Verify S3 bucket exists
if ! aws s3 ls "s3://${BUCKET_NAME}" &> /dev/null; then
    echo "Warning: S3 bucket '${BUCKET_NAME}' does not exist or you don't have access to it."
    echo "Please verify the bucket name and your AWS credentials."
    exit 1
fi

echo "Setup complete! The post-push hook will now sync your repository to S3 after each push."
