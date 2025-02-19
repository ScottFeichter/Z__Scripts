#!/bin/bash
export AWS_PAGER=""

# This script:

        # 1.  Checks if a repository name is provided as an argument

        # 2.  Converts the repository name to a valid S3 bucket name (lowercase, only valid characters)

        # 3.  Verifies AWS CLI is installed and configured

        # 4.  Creates an S3 bucket with the formatted name 

        # 5.  Enables versioning on the bucket

        # 6.  Configures default encryption using AES-256


# To use the script:

        # 1.  create-s3-from-repo.sh 

        # 2.  chmod +x create-s3-from-repo.sh

        # 3.  ./create-s3-from-repo.sh your-repo-name


# Important security considerations:

        # *   The script enables versioning by default for better data protection

        # *   Default encryption is enabled using AES-256

        # *   Make sure you have proper AWS credentials configured

        # *   The bucket name will be globally unique across all AWS accounts


# Note: This creates the bucket in the us-east-1 region by default. If you need a different region, you can modify the create-bucket command accordingly. 

###########################################################################################################
# THE SCRIPT

# Check if repository name is provided as argument
if [ -z "$1" ]; then
    echo "Please provide a GitHub repository name as argument"
    echo "Usage: ./create-s3-from-repo.sh <repository-name>"
    exit 1
fi

REPO_NAME=$1
# Convert repo name to lowercase and replace any special characters for S3 compatibility
BUCKET_NAME=$(echo "$REPO_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g')

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if user is authenticated with AWS
if ! aws sts get-caller-identity &> /dev/null; then
    echo "Not authenticated with AWS. Please configure AWS CLI first."
    exit 1
fi

# Create S3 bucket
echo "Creating S3 bucket: $BUCKET_NAME"
if aws s3api create-bucket \
    --bucket "$BUCKET_NAME" \
    --region us-east-1; then

    # Enable versioning on the bucket
    echo "Enabling versioning on bucket"
    aws s3api put-bucket-versioning \
        --bucket "$BUCKET_NAME" \
        --versioning-configuration Status=Enabled

    # Add default encryption
    echo "Enabling default encryption"
    aws s3api put-bucket-encryption \
        --bucket "$BUCKET_NAME" \
        --server-side-encryption-configuration '{
            "Rules": [
                {
                    "ApplyServerSideEncryptionByDefault": {
                        "SSEAlgorithm": "AES256"
                    }
                }
            ]
        }'

    echo "Successfully created and configured S3 bucket: $BUCKET_NAME"
else
    echo "Failed to create bucket. It might already exist or the name might not be unique."
    exit 1
fi
