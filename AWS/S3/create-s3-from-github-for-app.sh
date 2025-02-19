#!/bin/bash
export AWS_PAGER=""

# Note: The script blocks public access by default for security. 
# If you need public access for your images, you'll need to:

        # 1.  Remove or modify the public access block configuration
        # 2.  Add a bucket policy allowing public read access to specific paths
        # 3.  Consider setting up CloudFront for secure content delivery

# This script:
        # 1.  Checks if a repository name is provided as an argument
        # 2.  Converts the repository name to a valid S3 bucket name (lowercase, only valid characters)
        # 3.  Verifies AWS CLI is installed and configured
        # 4.  Creates an S3 bucket with the formatted name
        # 5.  Enables versioning on the bucket
        # 6.  Configures default encryption using AES-256
        # 7.  Sets up CORS for frontend access
        # 8.  Creates a logical folder structure for images
        # 9.  Sets up lifecycle rules for cost optimization
        # 10. Provides option for setting up CloudFront via second flag
        # 11. Checks if in a git folder if so creates git hub hook

# To use the script without CloudFront (SEE BELOW):
        # 1.  create-s3-from-repo.sh
        # 2.  chmod +x create-s3-from-repo.sh
        # 3.  ./create-s3-from-repo.sh your-repo-name

# To use the script WITH CLOUDFRONT:
        # 1.  create-s3-from-repo.sh
        # 2.  chmod +x create-s3-from-repo.sh
        # 3.  ./create-s3-from-repo.sh your-repo-name --with-cloudfront

# Sets up CloudFront distribution with best practices:

        #     *   HTTPS only
        #     *   Compression enabled
        #     *   GET/HEAD methods only
        #     *   Price Class 100 (US, Canada, Europe)

# Remember that CloudFront distribution deployment takes 15-20 minutes to complete.

# The CloudFront setup provides:
        # *   Secure access to your S3 content
        # *   Global content delivery
        # *   HTTPS encryption
        # *   Caching for better performance
        # *   Protection against direct S3 access

# Important security considerations:
        # *   The script enables versioning by default for better data protection
        # *   Default encryption is enabled using AES-256
        # *   Make sure you have proper AWS credentials configured
        # *   The bucket name will be globally unique across all AWS accounts
        # *   CORS is configured to allow GET requests
        # *   Public access is blocked by default - configure as needed

# Example of how your frontend might use the images:

        # const imageUrl = `https://XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/path/to/image.jpg`;

# Or with CloudFront:

        # const imageUrl = `https://your-cloudfront-distribution.net/path/to/image.jpg`;


######################################################################################################
# THE SCRIPT:

# Check if repository name is provided as argument
if [ -z "$1" ]; then
    echo "Please provide a GitHub repository name as argument"
    echo "Usage: ./create-s3-from-repo.sh <repository-name> [--with-cloudfront]"
    exit 1
fi

REPO_NAME=$1
SETUP_CLOUDFRONT=false

# Check for optional CloudFront flag
if [ "$2" = "--with-cloudfront" ]; then
    SETUP_CLOUDFRONT=true
fi

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

    # Configure CORS for frontend access
    echo "Configuring CORS policy"
    aws s3api put-bucket-cors --bucket "$BUCKET_NAME" --cors-configuration '{
        "CORSRules": [
            {
                "AllowedHeaders": ["*"],
                "AllowedMethods": ["GET"],
                "AllowedOrigins": ["*"],
                "ExposeHeaders": [],
                "MaxAgeSeconds": 3000
            }
        ]
    }'

    # Create folder structure
    echo "Creating folder structure"
    aws s3api put-object --bucket "$BUCKET_NAME" --key "images/"
    aws s3api put-object --bucket "$BUCKET_NAME" --key "images/products/"
    aws s3api put-object --bucket "$BUCKET_NAME" --key "images/banners/"
    aws s3api put-object --bucket "$BUCKET_NAME" --key "images/icons/"
    aws s3api put-object --bucket "$BUCKET_NAME" --key "thumbnails/"
    aws s3api put-object --bucket "$BUCKET_NAME" --key "uploads/"

    # Configure lifecycle rules
    echo "Configuring lifecycle rules"
    aws s3api put-bucket-lifecycle-configuration \
        --bucket "$BUCKET_NAME" \
        --lifecycle-configuration '{
            "Rules": [
                {
                    "ID": "DeleteOldVersions",
                    "Status": "Enabled",
                    "NoncurrentVersionExpiration": {
                        "NoncurrentDays": 90
                    }
                }
            ]
        }'

    # Block public access by default
    echo "Configuring public access block"
    aws s3api put-public-access-block \
        --bucket "$BUCKET_NAME" \
        --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

    # Setup CloudFront if requested
    if [ "$SETUP_CLOUDFRONT" = true ]; then
        echo "Setting up CloudFront distribution..."

        # Create Origin Access Control (OAC)
        OAC_NAME="${BUCKET_NAME}-oac"
        OAC_CONFIG='{
            "Name": "'${OAC_NAME}'",
            "Description": "OAC for '${BUCKET_NAME}'",
            "SigningProtocol": "sigv4",
            "SigningBehavior": "always",
            "OriginAccessControlOriginType": "s3"
        }'

        OAC_ID=$(aws cloudfront create-origin-access-control --origin-access-control-config "$OAC_CONFIG" --query 'OriginAccessControl.Id' --output text)

        # Create CloudFront distribution
        DISTRIBUTION_CONFIG='{
            "Comment": "Distribution for '${BUCKET_NAME}'",
            "Origins": {
                "Quantity": 1,
                "Items": [
                    {
                        "Id": "S3Origin",
                        "DomainName": "'${BUCKET_NAME}'.s3.amazonaws.com",
                        "S3OriginConfig": {
                            "OriginAccessIdentity": ""
                        },
                        "OriginAccessControlId": "'${OAC_ID}'"
                    }
                ]
            },
            "DefaultCacheBehavior": {
                "TargetOriginId": "S3Origin",
                "ViewerProtocolPolicy": "redirect-to-https",
                "AllowedMethods": {
                    "Quantity": 2,
                    "Items": ["GET", "HEAD"],
                    "CachedMethods": {
                        "Quantity": 2,
                        "Items": ["GET", "HEAD"]
                    }
                },
                "CachePolicyId": "658327ea-f89d-4fab-a63d-7e88639e58f6",
                "Compress": true
            },
            "Enabled": true,
            "DefaultRootObject": "index.html",
            "PriceClass": "PriceClass_100"
        }'

        # Create the distribution
        DISTRIBUTION_ID=$(aws cloudfront create-distribution \
            --distribution-config "$DISTRIBUTION_CONFIG" \
            --query 'Distribution.Id' \
            --output text)

        # Create bucket policy for CloudFront access
        BUCKET_POLICY='{
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Sid": "AllowCloudFrontServicePrincipal",
                    "Effect": "Allow",
                    "Principal": {
                        "Service": "cloudfront.amazonaws.com"
                    },
                    "Action": "s3:GetObject",
                    "Resource": "arn:aws:s3:::'${BUCKET_NAME}'/*",
                    "Condition": {
                        "StringEquals": {
                            "AWS:SourceArn": "arn:aws:cloudfront::'$(aws sts get-caller-identity --query Account --output text)':distribution/'${DISTRIBUTION_ID}'"
                        }
                    }
                }
            ]
        }'

        # Apply the bucket policy
        aws s3api put-bucket-policy --bucket "$BUCKET_NAME" --policy "$BUCKET_POLICY"

        echo "CloudFront distribution created with ID: $DISTRIBUTION_ID"
        echo "Please wait 15-20 minutes for the distribution to deploy"
    fi

    echo "Successfully created and configured S3 bucket: $BUCKET_NAME"
    echo "Folder structure created:"
    echo "  - images/"
    echo "    |- products/"
    echo "    |- banners/"
    echo "    |- icons/"
    echo "  - thumbnails/"
    echo "  - uploads/"

    if [ "$SETUP_CLOUDFRONT" = true ]; then
        echo "CloudFront distribution is being created. Once deployed, you can access your content via:"
        echo "https://<distribution-domain>/<path-to-file>"
    fi
else
    echo "Failed to create bucket. It might already exist or the name might not be unique."
    exit 1
fi


######################################################################################################
# create-git-hook.sh

# Check if we're in a Git repository
echo "Checking if Git repo..."
if [ ! -d .git ]; then
    echo "Error: Not a Git repository. Please run this script from the root of your Git repository."
    exit 1
fi


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
