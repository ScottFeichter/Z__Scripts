#!/bin/bash
export AWS_PAGER=""


###################################################################################################
# Welcome Message
echo ""
echo "🌎   ˗ˏˋ ★ ˎˊ˗     WELCOME     ˗ˏˋ ★ ˎˊ˗   🌍"
echo ""
echo ""
echo "💡  THIS SCRIPT CREATES A FULL STACK PERN  💡"
echo ""
echo ""
read -p "▶️           PRESS ENTER TO BEGIN           ▶️          "
echo ""
echo "-------------------------------------------------------------------"
###################################################################################################

#region REPO_NAME
#########################################################################################################################
#########################################################################################################################
# REPO_NAME: CREATE REPO NAME FOR ADMIEND, FRONTEND, BACKEND WITH DATE AND VERSION
#########################################################################################################################
#########################################################################################################################


###################################################################################################
# Check if repo name is provided
echo ""
echo "🛠  ACTION: Checking if repo name provided as arg... "



if [ -z "$1" ]; then
    echo "Please try again and provide a repo name as argument..."
    echo "Usage: ./create-pern-gh-admiend-amplify-ec2-aws.sh my-repo"
    exit 1
fi

echo ""
echo "✅ RESULT: Repo name arg correctly provided! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"


###################################################################################################
echo ""
echo "🛠  ACTION: Creating version... "


ARG=$1
APP_NAME_ARG=$ARG
ADMIEND_NAME_ARG=admiend-$1
FRONTEND_NAME_ARG=frontend-$1
BACKEND_NAME_ARG=backend-$1
CREATE_DATE=$(date '+%m-%d-%Y')
REPO_VERSION=1


# Function to check if repository exists and get latest version
check_repo_version() {
    local base_name="${ADMIEND_NAME_ARG}-${CREATE_DATE}"
    local highest_version=0  # Initialize to 0 instead of 1

    # Check GitHub repositories
    local existing_repos=$(gh repo list ScottFeichter --json name --limit 100 | grep -o "\"name\":\"${base_name}_[0-9]*\"")

    # Check local directories
    local existing_dirs=$(ls -d "$base_name"* 2>/dev/null)

    # Check versions from GitHub repos
    if [ -n "$existing_repos" ]; then
        local gh_version=$(echo "$existing_repos" | grep -o '[0-9]*$' | sort -n | tail -1)
        if [ -n "$gh_version" ] && [ "$gh_version" -gt "$highest_version" ]; then
            highest_version=$gh_version
        fi
    fi

    # Check versions from local directories
    if [ -n "$existing_dirs" ]; then
        local dir_version=$(echo "$existing_dirs" | grep -o "${base_name}-[0-9]*$" | grep -o '[0-9]*$' | sort -n | tail -1)
        if [ -n "$dir_version" ] && [ "$dir_version" -gt "$highest_version" ]; then
            highest_version=$dir_version
        fi
    fi

    # Only increment if we found existing versions
    if [ "$highest_version" -gt 0 ]; then
        REPO_VERSION=$((highest_version + 1))
    else
        REPO_VERSION=1  # Start with version 1 if no existing versions found
    fi
}


# Check for existing repos and update version if needed
echo ""
echo "Checking for version..."
check_repo_version







echo ""
echo "✅ RESULT: REPO_VERSION is $REPO_VERSION! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"




###################################################################################################
echo ""
echo "🛠  ACTION: Creating app project directory... "
echo ""



APP_PROJECT_DIR_BASE_NAME="${APP_NAME_ARG}-${CREATE_DATE}"
project_highest_version=$REPO_VERSION  # Ensure this is initialized

check_project_version() {
    # Check local directories
    local existing_project_dirs=$(find . -maxdepth 1 -type d -name "${APP_PROJECT_DIR_BASE_NAME}-*" | sed 's|./||')

    # Check versions from local directories
    if [ -n "$existing_project_dirs" ]; then
        local project_dir_version=$(echo "$existing_project_dirs" | grep -o "${APP_PROJECT_DIR_BASE_NAME}-[0-9]*$" | grep -o '[0-9]*$' | sort -n | tail -1)
        project_dir_version=${project_dir_version:-0}  # Default to 0 if empty

        if [ "$project_dir_version" -gt "$project_highest_version" ]; then
            project_highest_version=$project_dir_version
        fi
    fi

    # Only increment if we found existing versions
    if [ "$project_highest_version" -gt 0 ]; then
        REPO_VERSION=$((project_highest_version + 1))
        echo ""
        echo "Incrementing version because local project exists..."
    else
        REPO_VERSION=1
    fi
}


# Check for existing repos and update version if needed
echo "Checking for project version..."
check_project_version

APP_PROJECT_DIR_NAME=${APP_PROJECT_DIR_BASE_NAME}-${REPO_VERSION}

mkdir $APP_PROJECT_DIR_NAME
cd $APP_PROJECT_DIR_NAME


echo ""
echo "✅ RESULT: APP_PROJECT_DIR_NAME is $APP_PROJECT_DIR_NAME! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"



###################################################################################################

#endregion
#region ADMIEND
#########################################################################################################################
#########################################################################################################################
# ADMIEND: CREATE ADMIEND REPO LOCAL AND REMOTE WITH STARTER FILES AND DIRECTORIES AND PUSH
#########################################################################################################################
#########################################################################################################################
echo ""
echo "-------------------------------------------------------------------"
echo "📣 UPDATE: CREATING ADMIEND..."
echo "-------------------------------------------------------------------"
###################################################################################################
# Create final repo name with appropriate version
echo ""
echo "🛠  ACTION: Creating final repo name with appropriate version... "
echo ""

ADMIEND_REPO_NAME="${ADMIEND_NAME_ARG}-${CREATE_DATE}-${REPO_VERSION}"


echo "✅ RESULT: ADMIEND is $ADMIEND_REPO_NAME! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"


###################################################################################################
# Creating project admiend directory and structure...
echo ""
echo "🛠  ACTION: Creating project admiend directory and structure... "
echo ""

# Create and cd project admeind directory
mkdir "$ADMIEND_REPO_NAME"
cd "$ADMIEND_REPO_NAME"


# Create admiend file structure
mkdir -p api-docs comporables draw-io images images/products images/banners images/icons misc postman questions requirements redux schema scripts sequelize sounds thumbnails uploads wireframes

echo "Created admiend file structure:"
echo "├── api-docs/"
echo "├── comporables/"
echo "├── draw-io/"
echo "├── images/"
echo "│   ├── products/"
echo "│   ├── banners/"
echo "│   └── icons/"
echo "├── misc/"
echo "├── postman/"
echo "├── questions/"
echo "├── requirements/"
echo "├── redux/"
echo "├── schema/"
echo "├── scripts/"
echo "├── sequelize/"
echo "├── sounds/"
echo "├── thumbnails/"
echo "├── uploads/"
echo "└── wireframes/"
echo ""


# Create starter files
echo "Creating starter files..."
echo ""

touch api-docs/$ARG-api.md
touch api-docs/scratch-api.md

touch draw-io/$ARG-architecture.drawio

touch postman/$ARG-backend.postman_collection.json
touch postman/$ARG-frontend.postman_collection.json

touch misc/authentication-flow.md
touch misc/fake-commits.md

touch redux/fetches-thunks.js
touch redux/reducers.js

touch requirements/$ARG-frontend-requirements.txt
touch requirements/$ARG-backend-requirements.txt

touch schema/$ARG-schema.png

touch sequelize/seeders.js
touch sequelize/commands.md
touch sequelize/migrations.js

echo "LIST SUBJECT TO CHANGE - CHECK PROD ENV FOR MOST CURRENT"

echo ""
echo "npm init -y"          >> $ARG-backend-requirements.txt
echo "" 					          >> $ARG-backend-requirements.txt
echo "# npm install for:" 	>> $ARG-backend-requirements.txt
echo cookie-parser 			    >> $ARG-backend-requirements.txt
echo cors 				          >> $ARG-backend-requirements.txt
echo csurf 					        >> $ARG-backend-requirements.txt
echo dotenv 				        >> $ARG-backend-requirements.txt
echo express 				        >> $ARG-backend-requirements.txt
echo express-async-errors 	>> $ARG-backend-requirements.txt
echo helmet 				        >> $ARG-backend-requirements.txt
echo jsonwebtoken 			    >> $ARG-backend-requirements.txt
echo morgan 				        >> $ARG-backend-requirements.txt
echo per-env 				        >> $ARG-backend-requirements.txt
echo sequelize@6 			      >> $ARG-backend-requirements.txt
echo sequelize-cli@6 		    >> $ARG-backend-requirements.txt
echo pg						          >> $ARG-backend-requirements.txt
echo "" 					          >> $ARG-backend-requirements.txt

echo "#npm install -D for:" >> $ARG-backend-requirements.txt
echo sqlite3 				        >> $ARG-backend-requirements.txt
echo dotenv-cli				      >> $ARG-backend-requirements.txt
echo nodemon				        >> $ARG-backend-requirements.txt
wait;


echo "✅ RESULT: Project directory and structure succesfully created! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"



###################################################################################################
# Creating a logging function and initialize the config object...
echo ""
echo "🛠  ACTION: Creating a logging function and initialize the config object... "


# Initialize configuration object as a JSON file
init_config_logging() {
    CONFIG_FILE="admiend_config.json"
    echo "{}" > "$CONFIG_FILE"
}

# Function to add or update configuration
update_config() {
    local key=$1
    local value=$2
    local temp_file="temp_config.json"

    # Escape special characters in the value
    value=$(echo "$value" | sed 's/"/\\"/g')

    # Read existing config and update/add new key-value pair
    jq --arg k "$key" --arg v "$value" '. + {($k): $v}' "$CONFIG_FILE" > "$temp_file"
    mv "$temp_file" "$CONFIG_FILE"
}

# Function to add nested configuration (for AWS services)
update_service_config() {
    local service=$1
    local key=$2
    local value=$3
    local temp_file="temp_config.json"

    # Escape special characters in the value
    value=$(echo "$value" | sed 's/"/\\"/g')

    # Create or update service configuration
    jq --arg s "$service" --arg k "$key" --arg v "$value" \
    'if has($s) then .[$s] += {($k): $v} else . += {($s): {($k): $v}} end' \
    "$CONFIG_FILE" > "$temp_file"
    mv "$temp_file" "$CONFIG_FILE"
}

# Initialize logging
init_config_logging

echo ""
echo "✅ RESULT: Logging successfully initialized! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"


###################################################################################################
# Create SETUP
echo ""
echo "🛠  ACTION: Creating SETUP.md... "

cat > SETUP.MD << EOL
This is a common and recommended development practice. Here's how the setup typically works:

Development Environment (Local):

Local Development
├── Database: Local PostgreSQL
├── Server: localhost:5555 (or similar)
├── Environment: .env.development
└── Benefits:
    ├── Faster development cycle
    ├── No AWS costs during development
    ├── Work offline
    └── Quick testing and debugging

Production Environment (AWS):

AWS Production
├── Database: AWS RDS PostgreSQL
├── Server: EC2 instance
├── Environment: .env.production
└── Benefits:
    ├── Scalable infrastructure
    ├── Managed services
    ├── High availability
    └── Production-grade security


Your .env files might look like:

# .env.development
SERVER_PORT=5555
NODE_ENV=development
DB_DIALECT=postgres
DB_USER=postgres
DB_PASSWORD=postgres
DB_NAME=your_local_db
DB_PORT=5432
DB_HOST=localhost

# .env.production
SERVER_PORT=5555
NODE_ENV=production
DB_DIALECT=postgres
DB_USER=postgres
DB_PASSWORD=your_secure_password
DB_NAME=your_prod_db
DB_PORT=5432
DB_HOST=your-rds-endpoint.region.rds.amazonaws.com


Typical workflow:

Local Development → Testing → Git Push → AWS Production
     ↑                                        ↓
  Quick iterations                     Production Environment
     ↑                                        ↓
  No AWS costs                          Managed Services

------------------------------------------------------------
EOL



echo ""
echo "✅ RESULT: SETUP.md successfully created! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"


###################################################################################################
# Create README
echo ""
echo "🛠  ACTION: Creating README.md... "

touch README.md
	echo "# [$ADMIEND_REPO_NAME]">> README.md;
	echo "! [db-schema ]">> README.md;
	echo "[db-schema]: ./schema/[$ARG]-schema.png">> README.md

echo ""
echo "✅ RESULT: README.md successfully created! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"


###################################################################################################
# Initialize repository local and remote and push
echo ""
echo "🛠  ACTION: Initializing admiend git local w github remote and pushing... "
echo ""

git init
git add .
git commit -m "initial \(msg via shell\)"

gh repo create "$ADMIEND_REPO_NAME" --public

git remote add origin "https://github.com/ScottFeichter/$ADMIEND_REPO_NAME.git"
git branch -M main
git push -u origin main


echo ""
echo "✅ RESULT: Git local w github remote initiated, staged, committed and pushed! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"



######################################################################################################

#endregion
#region ADMIEND S3
#########################################################################################################################
#########################################################################################################################
# ADMIEND: CREATE AND CONNECT S3 BUCKET TO ADMIEND
#########################################################################################################################
#########################################################################################################################
echo ""
echo "-------------------------------------------------------------------"
echo "📣 UPDATE: CREATING S3 BUCKET AND CONNECTING..."
echo "-------------------------------------------------------------------"
######################################################################################################
# S3 Bucket Creation


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
# Check if repository name is provided as argument
echo ""
echo "🛠  ACTION: Checking if repository name is provided as argument... "
echo ""

if [ -z "$1" ]; then
    echo ""
    echo "Please provide a GitHub repository name as argument"
    echo "Usage: ./create-s3-from-repo.sh <repository-name> [--with-cloudfront]"
    exit 1
fi


echo "✅ RESULT: Name properly provided! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"


######################################################################################################
# Check for cloudfront
echo ""
echo "🛠  ACTION: Checking if CloudFront argument provided... "
echo ""

SETUP_CLOUDFRONT=false


# Check for optional CloudFront flag
if [ "$2" = "--with-cloudfront" ]; then
    SETUP_CLOUDFRONT=true
fi

echo "✅ RESULT: CloudFront will not be used on this build! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"



######################################################################################################
# Generate and format bucket name and run checks...
echo ""
echo "🛠  ACTION: Generating and format bucket name and run checks... "
echo ""


# Generate bucket name with timestamp and random string
TIMESTAMP=$(date +%Y%m%d%H%M%S)
RANDOM_STRING=$(openssl rand -hex 4)
BUCKET_NAME="${ADMIEND_REPO_NAME}-${TIMESTAMP}-${RANDOM_STRING}"

# Convert bucket name to lowercase (S3 requirement)
BUCKET_NAME=$(echo "$BUCKET_NAME" | tr '[:upper:]' '[:lower:]')

# Remove any invalid characters (S3 only allows lowercase letters, numbers, dots, and hyphens)
BUCKET_NAME=$(echo "$BUCKET_NAME" | sed 's/[^a-z0-9.-]/-/g')


# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo ""
    echo "AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if user is authenticated with AWS
if ! aws sts get-caller-identity &> /dev/null; then
    echo ""
    echo "Not authenticated with AWS. Please configure AWS CLI first."
    exit 1
fi



echo "✅ RESULT: BUCKET_NAME is $BUCKET_NAME! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"



######################################################################################################
# Create S3 bucket...
echo ""
echo "🛠  ACTION: Creating S3 bucket... "
echo ""




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


    # Configure lifecycle rules
    echo "Configuring lifecycle rules"
    aws s3api put-bucket-lifecycle-configuration \
        --bucket "$BUCKET_NAME" \
        --lifecycle-configuration '{
            "Rules": [
                {
                    "ID": "DeleteOldVersions",
                    "Status": "Enabled",
                    "Filter": {},
                    "NoncurrentVersionExpiration": {
                        "NoncurrentDays": 90
                    },
                    "Prefix": ""
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
    echo "├── api-docs/"
    echo "├── comporables/"
    echo "├── draw-io/"
    echo "├── images/"
    echo "│   ├── products/"
    echo "│   ├── banners/"
    echo "│   └── icons/"
    echo "├── misc/"
    echo "├── postman/"
    echo "├── questions/"
    echo "├── requirements/"
    echo "├── redux/"
    echo "├── schema/"
    echo "├── sequelize/"
    echo "├── sounds/"
    echo "├── thumbnails/"
    echo "├── uploads/"
    echo "└── wireframes/"



    if [ "$SETUP_CLOUDFRONT" = true ]; then
        echo "CloudFront distribution is being created. Once deployed, you can access your content via:"
        echo "https://<distribution-domain>/<path-to-file>"
    fi
else
    echo "Failed to create bucket. It might already exist or the name might not be unique."
    exit 1
fi


echo ""
echo "✅ RESULT: Bucket creation complete! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"



#endregion
#region ADMIEND GIT HOOK
#########################################################################################################################
#########################################################################################################################
# ADMIEND: CREATE GIT HOOK TO SEND TO S3 ON PUSH
#########################################################################################################################
#########################################################################################################################
echo ""
echo "-------------------------------------------------------------------"
echo "📣 UPDATE: CONFIGURING AND CREATING HOOK TO PUSH FROM GH TO S3..."
echo "-------------------------------------------------------------------"
######################################################################################################
# Create hook for Git/GitHub/S3...
echo ""
echo "🛠  ACTION: Creating hook for Git/GitHub/S3..."
echo ""


# Check if we're in a Git repository
echo "Checking if Git repo..."
if [ ! -d .git ]; then
    echo "Error: Not a Git repository. Please run this script from the root of your Git repository."
    exit 1
fi


# Create hooks directory if it doesn't exist
mkdir -p .git/hooks

# Create pre-push hook
echo "Creating pre-push hook..."
cat > .git/hooks/pre-push << EOL
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
chmod +x .git/hooks/pre-push

# Verify the hook was created
if [ -x .git/hooks/pre-push ]; then
    echo "Successfully created and configured pre-push hook"
    echo "Hook location: .git/hooks/pre-push"
    echo "The hook will sync to S3 bucket: ${BUCKET_NAME}"
else
    echo "Failed to create pre-push hook"
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

echo "The post-push hook will now sync your repository to S3 after each push."



echo ""
echo "✅ RESULT: Hook successfully created! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"




######################################################################################################
# Final git stage commit push
echo ""
echo "🛠  ACTION: Staging, Committing, Pushing..."
echo ""


git add -A
git commit -m "admiend Setup Complete"
git push

cd ..

echo ""
echo "✅ RESULT: Repo staged, commited, and pushed! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"



######################################################################################################
echo ""
echo "-------------------------------------------------------------------"
echo "📣 UPDATE: ADMIEND SETUP COMPLETE! 🏆 "
echo "-------------------------------------------------------------------"
#endregion
#region FRONTEND
#########################################################################################################################
#########################################################################################################################
# FRONTEND: CREATES REACT FRONTEND THEN CREATES GIT LOCAL AND REMOTE AND PUSHES
#########################################################################################################################
#########################################################################################################################
echo " "
echo "-------------------------------------------------------------------"
echo "📣 UPDATE: CREATING FRONTEND..."
echo "-------------------------------------------------------------------"
######################################################################################################
# Create the final repo name with the appropriate version
echo ""
echo "🛠  ACTION: Creating final front repo name and initializing with vite..."
echo ""


FRONTEND_REPO_NAME="$FRONTEND_NAME_ARG-$CREATE_DATE-$REPO_VERSION"


# Initialize project with Vite
echo "Creating React w Vite project: $FRONTEND_REPO_NAME..."
npm create vite@latest $FRONTEND_REPO_NAME -- --template react-ts -- --skip-git



cd $FRONTEND_REPO_NAME


echo ""
echo "✅ RESULT: FRONTEND_REPO_NAME is $FRONTEND_REPO_NAME! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"


######################################################################################################
# Initialize repository local and remote and push
echo ""
echo "🛠  ACTION: Initializing admiend git local w github remote and pushing... "
echo ""


git init
cat > README.md << EOL
react front end for $FRONTEND_REPO_NAME
EOL
git add .
git commit -m "initial \(msg via shell\)"

git branch -M main

git branch Production
git branch Staging
git branch Development

# Create GitHub repository
gh repo create "$FRONTEND_REPO_NAME" --public

# Configure remote and push
git remote add origin "https://github.com/ScottFeichter/$FRONTEND_REPO_NAME.git"


# Push branches
git push -u origin main
git push -u origin Production
git push -u origin Staging
git push -u origin Development




echo ""
echo "✅ RESULT: Git local w github remote initiated, staged, committed and pushed! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"



######################################################################################################
# Create amplify.yml
echo ""
echo "🛠  ACTION: Creating amplify.yml for AWS Amplify... "
echo ""


# Define the output file
AWS_AMPLIFY_YML="${FRONTEND_REPO_NAME}-amplify.yml"

# Check if file already exists
if [ -f "$AWS_AMPLIFY_YML" ]; then
    read -p "amplify.yml already exists. Do you want to overwrite it? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Operation cancelled"
        exit 1
    fi
fi

# Create the amplify.yml file with proper configuration
cat > "$AWS_AMPLIFY_YML" << 'EOL'
version: 1
frontend:
  phases:
    preBuild:
      commands:
        - npm ci
        # Branch-specific environment variables
        - |
          if [ "${AWS_BRANCH}" = "Production" ]; then
            echo "REACT_APP_STAGE=production" >> .env
            echo "REACT_APP_API_URL=$PROD_API_URL" >> .env
          elif [ "${AWS_BRANCH}" = "Staging" ]; then
            echo "REACT_APP_STAGE=staging" >> .env
            echo "REACT_APP_API_URL=$STAGING_API_URL" >> .env
          else
            echo "REACT_APP_STAGE=development" >> .env
            echo "REACT_APP_API_URL=$DEV_API_URL" >> .env
          fi

    build:
      commands:
        - npm run build
  artifacts:
    baseDirectory: build
    files:
      - '**/*'
  cache:
    paths:
      - node_modules/**/*
      - .npm/**/*
  customHeaders:
    - pattern: '**/*'
      headers:
        - key: 'Strict-Transport-Security'
          value: 'max-age=31536000; includeSubDomains'
        - key: 'X-Frame-Options'
          value: 'SAMEORIGIN'
        - key: 'X-XSS-Protection'
          value: '1; mode=block'
        - key: 'X-Content-Type-Options'
          value: 'nosniff'
        - key: 'Content-Security-Policy'
          value: "default-src 'self' https:; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:;"
  customRules:
    - source: '</^[^.]+$|\.(?!(css|gif|ico|jpg|js|png|txt|svg|woff|woff2|ttf|map|json)$)([^.]+$)/>'
      target: '/index.html'
      status: '200'
EOL

# Make the file readable
chmod 644 "$AWS_AMPLIFY_YML"

# Verify the file was created
if [ -f "$AWS_AMPLIFY_YML" ]; then
    echo "Successfully created amplify.yml"
    echo "Configuration includes:"
    echo "- Clean npm install"
    echo "- Production build"
    echo "- Asset deployment configuration"
    echo "- Cache optimization"
    echo "- Security headers"
else
    echo "Failed to create amplify.yml"
    exit 1
fi

# Optional: Display the contents of the file
echo -e "\nHere's your new amplify.yml configuration:"
echo "----------------------------------------"
cat "$AWS_AMPLIFY_YML"
echo "----------------------------------------"

# Provide some next steps
echo -e "\nNext steps:"
echo "1. Review the configuration in amplify.yml"
echo "2. Adjust the security headers as needed for your application"
echo "3. Uncomment and configure any environment variables if needed"
echo "4. Commit the file to your repository"


echo ""
echo "✅ RESULT: Amplify yml successfully created as $AWS_AMPLIFY_YML! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"














######################################################################################################
# Intall dependencies
echo ""
echo "🛠  ACTION: Installing dependencies..."
echo ""

# Install core dependencies
echo "Installing core dependencies..."
npm install
echo ""

# Install TypeScript and type definitions first
echo "Installing TypeScript and type definitions..."
npm install --save-dev typescript @types/react @types/react-dom @types/node
npx tsc --init
echo ""


# Install additional common dependencies
echo "Installing additional dependencies..."
npm install \
    @reduxjs/toolkit \
    react-redux \
    react-router-dom \
    axios \
    @mui/material \
    @mui/icons-material \
    @emotion/react \
    @emotion/styled \
    formik \
    yup \
    sass \
    framer-motion \

npm install @aws-amplify/ui-react aws-amplify
npm install @fontsource/inter

echo " "
echo "Dependency install complete: including AWS Amplify UI..."
echo "For more information on AWS Amplify UI visit:"
echo "https://ui.docs.amplify.aws/react/getting-started/installation"
echo " "


echo ""
echo "✅ RESULT: Dependencies successfully installed! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"




######################################################################################################
# Create project structure
echo ""
echo "🛠  ACTION: Creating project structure..."
echo ""

mkdir -p \
    src/components \
    src/pages \
    src/features \
    src/services \
    src/hooks \
    src/utils \
    src/assets \
    src/styles \
    src/store


echo "✅ RESULT: Project structure created! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"


######################################################################################################
# Create basic files
echo ""
echo "🛠  ACTION: Creating basic files..."
echo ""



# Create store setup
cat > src/store/counterSlice.ts << EOL
import { createSlice } from '@reduxjs/toolkit';

interface CounterState {
  value: number;
}

const initialState: CounterState = {
  value: 0,
};

export const counterSlice = createSlice({
  name: 'counter',
  initialState,
  reducers: {
    increment: (state) => {
      state.value += 1;
    },
    decrement: (state) => {
      state.value -= 1;
    },
  },
});

export const { increment, decrement } = counterSlice.actions;
export default counterSlice.reducer;
EOL

cat > src/store/index.ts << EOL
import { configureStore } from '@reduxjs/toolkit';
import counterReducer from './counterSlice';

export const store = configureStore({
  reducer: {
    counter: counterReducer,
  },
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
EOL

# Create main style file
cat > src/styles/main.scss << EOL
/* Styles remain unchanged */
EOL

# Create API service
cat > src/services/api.js << EOL
import axios from 'axios';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:3000',
});

api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export default api;
EOL

# Create sample component
cat > src/components/Layout.tsx << EOL
import { Outlet } from 'react-router-dom';

const Layout = () => {
  return (
    <div>
      <header>
        {/* Add your header content */}
      </header>
      <main>
        <Outlet />
      </main>
      <footer>
        {/* Add your footer content */}
      </footer>
    </div>
  );
};

export default Layout;
EOL

# Create the file src/vite-env.d.ts
cat > src/vite-env.d.ts << EOL
/// <reference types="vite/client" />

declare module '*.svg' {
  import React = require('react');
  export const ReactComponent: React.FunctionComponent<React.SVGProps<SVGSVGElement>>;
  const src: string;
  export default src;
}

declare module '*.png' {
  const content: string;
  export default content;
}

declare module '*.jpg' {
  const content: string;
  export default content;
}
EOL

# Create HomePage component
cat > src/pages/HomePage.tsx << EOL
import { motion } from 'framer-motion';
import { useSelector, useDispatch } from 'react-redux';
import { increment, decrement } from '../store/counterSlice';
import { RootState } from '../store';
import { AppDispatch } from '../store';
import { FC } from 'react';

interface Styles {
  container: React.CSSProperties;
  logoContainer: React.CSSProperties;
  logo: React.CSSProperties;
  reduxLogo: React.CSSProperties;
  logoLink: React.CSSProperties;
  countContainer: React.CSSProperties;
  heading: React.CSSProperties;
  button: React.CSSProperties;
}

const styles: Styles = {
  container: {
    textAlign: 'center' as const,
    padding: '2rem',
    marginTop: '30vh',
  },
  logoContainer: {
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    gap: '2rem',
    marginBottom: '2rem',
  },
  logo: {
    height: '8rem',
    transition: 'filter 0.3s ease',
    display: 'block',
  },
  reduxLogo: {
    height: '9.5rem',
    transition: 'filter 0.3s ease',
    display: 'block',
  },
  logoLink: {
    cursor: 'pointer',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
  },
  countContainer: {
    marginTop: '2rem',
  },
  heading: {
    marginBottom: '2rem',
  },
  button: {
    margin: '0 0.5rem',
    padding: '0.5rem 1rem',
    border: '2px solid transparent',
    borderRadius: '4px',
    cursor: 'pointer',
    transition: 'border-color 0.3s ease',
    ':hover': {
      borderColor: '#ff69b4',
    }
  },
};

const animationVariants = {
  rotateY: {
    animate: { rotateY: 360 },
    transition: { duration: 2, repeat: Infinity, ease: "linear" }
  },
  rotate: {
    animate: { rotate: 360 },
    transition: { duration: 4, repeat: Infinity, ease: "linear" }
  },
  vibrate: {
    animate: {
      x: [-2, 2, -2],
      y: [-1, 1, -1],
    },
    transition: {
      duration: 0.3,
      repeat: Infinity,
      ease: "linear"
    }
  }
} as const;

const logoHoverVariants = {
  initial: {
    filter: 'drop-shadow(0 0 0px rgba(128, 0, 128, 0))',
    cursor: 'pointer'
  },
  hover: {
    filter: 'drop-shadow(0 0 10px rgba(128, 0, 128, 0.8))',
    cursor: 'pointer'
  }
};

const buttonHoverVariants = {
  initial: {
    border: '2px solid transparent',
    cursor: 'pointer',
    boxShadow: '0 2px 8px rgba(128, 0, 128, 0.3)',
  },
  hover: {
    border: '2px solid #ff69b4',
    cursor: 'pointer',
    boxShadow: '0 6px 8px rgba(128, 0, 128, 0.3)',
  }
};

const HomePage: FC = () => {
  const count = useSelector((state: RootState) => state.counter.value);
  const dispatch: AppDispatch = useDispatch();

  const handleIncrement = () => {
    try {
      dispatch(increment());
    } catch (error) {
      console.error('Failed to increment:', error);
    }
  };

  const handleDecrement = () => {
    try {
      dispatch(decrement());
    } catch (error) {
      console.error('Failed to decrement:', error);
    }
  };

  return (
    <div style={styles.container}>
      <div style={styles.logoContainer}>
        <motion.a
          href="https://vitejs.dev"
          target="_blank"
          rel="noopener noreferrer"
          {...animationVariants.rotateY}
          initial="initial"
          whileHover="hover"
          variants={logoHoverVariants}
          style={styles.logoLink}
        >
          <img
            src="https://vitejs.dev/logo.svg"
            alt="Vite logo"
            style={styles.logo}
          />
        </motion.a>
        <motion.a
          href="https://react.dev"
          target="_blank"
          rel="noopener noreferrer"
          animate={{ rotate: 360 }}
          transition={{ duration: 4, repeat: Infinity, ease: "linear" }}
          initial="initial"
          whileHover="hover"
          variants={logoHoverVariants}
          style={styles.logoLink}
        >
          <img
            src="https://upload.wikimedia.org/wikipedia/commons/a/a7/React-icon.svg"
            alt="React logo"
            style={styles.logo}
          />
        </motion.a>
        <motion.a
          href="https://redux.js.org"
          target="_blank"
          rel="noopener noreferrer"
          {...animationVariants.vibrate}
          initial="initial"
          whileHover="hover"
          variants={logoHoverVariants}
          style={styles.logoLink}
        >
          <img
            src="https://raw.githubusercontent.com/reduxjs/redux/master/logo/logo.svg"
            alt="Redux logo"
            style={styles.reduxLogo}
          />
        </motion.a>
      </div>
      <div style={styles.countContainer}>
        <h2 style={styles.heading}>Count: {count}</h2>
        <motion.button
          onClick={handleDecrement}
          style={styles.button}
          aria-label="Decrement counter"
          initial="initial"
          whileHover="hover"
          variants={buttonHoverVariants}
        >
          Decrement
        </motion.button>
        <motion.button
          onClick={handleIncrement}
          style={styles.button}
          aria-label="Increment counter"
          initial="initial"
          whileHover="hover"
          variants={buttonHoverVariants}
        >
          Increment
        </motion.button>
      </div>
    </div>
  );
};

export default HomePage;
EOL

# Create router setup
cat > src/router.tsx << EOL
import { createBrowserRouter } from 'react-router-dom';
import Layout from './components/Layout';
import HomePage from './pages/HomePage';

export const router = createBrowserRouter([
  {
    path: '/',
    element: <Layout />,
    children: [
      {
        path: '/',
        element: <HomePage />,
      },
    ],
  },
]);
EOL

# Update main.tsx
cat > src/main.tsx << EOL
import React from 'react';
import ReactDOM from 'react-dom/client';
import { Provider } from 'react-redux';
import { RouterProvider } from 'react-router-dom';
import { store } from './store';
import { router } from './router';
import './styles/main.scss';

ReactDOM.createRoot(document.getElementById('root') as HTMLElement).render(
  <React.StrictMode>
    <Provider store={store}>
      <RouterProvider router={router} />
    </Provider>
  </React.StrictMode>
);
EOL

# Update .gitignore
cat >> .gitignore << EOL
# TypeScript build output
dist/
EOL

# Update package.json scripts
npm pkg set scripts.dev="vite"
npm pkg set scripts.build="vite build"
npm pkg set scripts.preview="vite preview"
npm pkg set scripts.lint="eslint src --ext ts,tsx --report-unused-disable-directives --max-warnings 0"
npm pkg set scripts.format="prettier --write 'src/**/*.{ts,tsx,css,scss}'"




echo "
React setup complete! 🚀

Project structure:
├── src/
│   ├── components/    # Reusable components
│   ├── pages/         # Page components
│   ├── features/      # Feature-specific components and logic
│   ├── services/      # API and other services
│   ├── hooks/         # Custom hooks
│   ├── utils/         # Utility functions
│   ├── assets/        # Images, fonts, etc.
│   ├── styles/        # Global styles and themes
│   └── store/         # Redux store setup
└── ...

To get started:
1. cd $FRONTEND_REPO_NAME
2. npm run dev

Happy coding! 🎉"


echo ""
echo "✅ RESULT: Files created! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"





######################################################################################################
# Final git pull stage add push
echo ""
echo "🛠  ACTION: Pulling, Staging, Committing, Pushing..."
echo ""

git add -A
git commit -m "Updating and preparing to pull..."
git push


# Pull from main into Production, Development, and Staging
branches=("Production" "Development" "Staging")
for branch in "${branches[@]}"; do
    echo "Pulling latest changes from main into $branch..."
    git checkout $branch
    git pull origin main
    git push origin $branch
done

git checkout main

git add -A
git commit -m "Frontend Setup Complete"
git push

cd ..

echo ""
echo "✅ RESULT: Repo staged, commited, and pushed! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"






######################################################################################################
echo ""
echo "-------------------------------------------------------------------"
echo "📣 UPDATE: FRONTEND SETUP COMPLETE! 🏆 "
echo "-------------------------------------------------------------------"
#endregion
#region FRONTEND AMPLIFY
#########################################################################################################################
#########################################################################################################################
# FRONTEND: CREATE AND CONNECT AMPLIFY APP TO FRONTEND REPO
#########################################################################################################################
#########################################################################################################################
echo ""
echo "-------------------------------------------------------------------"
echo "📣 UPDATE: CONFIGURING AND CREATING AND CONNECTING DEPLOY WITH AMPLIFY..."
echo "-------------------------------------------------------------------"
######################################################################################################

######################################################################################################
# Check if gh cli is installed
echo ""
echo "🛠  ACTION: Running gh checks..."
echo ""


    if ! command -v gh &> /dev/null; then
        echo "GitHub CLI (gh) is not installed. Please install it first."
        echo "Visit: https://cli.github.com/ for installation instructions"
        exit 1
    fi


    # Check if user is authenticated
    if ! gh auth status &> /dev/null; then
        echo "Not logged in to GitHub. Please run 'gh auth login' first"
        exit 1
    fi

    # Check if repository exists
    if ! gh repo view "ScottFeichter/$FRONTEND_REPO_NAME" &> /dev/null; then
        echo "Repository not found: ScottFeichter/$FRONTEND_REPO_NAME"
        exit 1
    fi

    # Get repository URL
    FRONTEND_REPO_URL=$(gh repo view "ScottFeichter/$FRONTEND_REPO_NAME" --json url -q .url)


    # Get authentication token
    #! Note: This gets the token used by gh cli ie gho_xxxxxxx
    TOKEN=$(gh auth token)

    # can use this with ghp however ghp cannot be created in cli
    # perhaps it could be in environment variable
    # aws amplify create-app --name <app_name --repository https://<repo>.git --access-token <my access token>



    # Print results
    echo " "
    echo "Repository Information:"
    echo "======================"
    echo " "
    echo "Name: $FRONTEND_REPO_NAME"
    echo "URL: $FRONTEND_REPO_URL"
    echo "Token: $TOKEN"
    echo " "


    echo ""
    echo "✅ RESULT: Gh checks complete! "
    echo ""
    read -p "⏸️  PAUSE: Press Enter to continue... "
    echo ""
    echo "-------------------------------------------------------------------"


######################################################################################################
# Create amplify amp from repo
echo ""
echo "🛠  ACTION: Creating Amplify app from repo..."
echo ""

export AWS_PAGER=""  # Disable the AWS CLI pager

# Exit on any error
set -e

# Check if required parameters are provided
if [ -z "$FRONTEND_REPO_NAME" ] || [ -z "$FRONTEND_REPO_URL" ] || [ -z "$TOKEN" ]; then
    echo "Usage: $0 <app-name> <github-repo-url> <github-access-token>"
    echo "Example: $0 'My App' 'https://github.com/username/repo' 'ghp_xxxxxxxxxxxx'"
    exit 1
fi

echo "Starting Amplify deployment process..."


# Create Amplify app
echo "Creating Amplify app..."
APP_ID=$(aws amplify create-app \
    --name "$FRONTEND_REPO_NAME" \
    --repository "https://github.com/ScottFeichter/$FRONTEND_REPO_NAME" \
    --access-token "$TOKEN" \
    --platform "WEB" \
    --custom-rules '[{"source": "<\/^[^.]+$|\\.(?!(css|gif|ico|jpg|js|png|txt|svg|woff|woff2|ttf|map|json)$)([^.]+$)\/>/", "target": "/index.html", "status": "200"}]' \
    --query 'app.appId' \
    --output text)

# Check Amplify app created
if [ -z "$APP_ID" ]; then
    echo "Failed to create Amplify app"
    exit 1
else
    echo "Successfully created Amplify app with ID: $APP_ID"
fi


# Set up the Production branch as the main production branch
aws amplify create-branch \
    --app-id "$APP_ID" \
    --branch-name "Production" \
    --enable-auto-build \
    --framework "React" \
    --stage "PRODUCTION"

# Update branch to be production branch
aws amplify update-branch \
    --app-id "$APP_ID" \
    --branch-name "Production" \
    --enable-auto-build \
    --enable-pull-request-preview \
    --enable-performance-mode

# Set Production as the default branch (this will be your production environment)
aws amplify update-app \
    --app-id "$APP_ID" \
    --name "$FRONTEND_REPO_NAME" \
    --platform "WEB" \

# Optional: Set up other branches
for BRANCH in "main" "Staging" "Development"
do
    aws amplify create-branch \
        --app-id "$APP_ID" \
        --branch-name "$BRANCH" \
        --enable-auto-build \
        --stage "DEVELOPMENT"
done




#! I will suppress the waiting for amplify deploy
# BEGINING OF WAITING FOR APP TO COMPLETE
############################################################################################################################


# # Wait for deployment to complete
# echo "Waiting for initial deployment..."
# DEPLOY_TIMEOUT=300  # 5 minute timeout
# ELAPSED=0
# INTERVAL=10  # Check every 10 seconds

# while [ $ELAPSED -lt $DEPLOY_TIMEOUT ]; do
#     # Get the active job ID
#     ACTIVE_JOB_ID=$(aws amplify get-branch \
#         --app-id "${APP_ID}" \
#         --branch-name "main" \
#         --query 'branch.activeJobId' \
#         --output text)

#     if [ "$ACTIVE_JOB_ID" != "None" ]; then
#         # Get the status of the active job
#         JOB_STATUS=$(aws amplify get-job \
#             --app-id "${APP_ID}" \
#             --branch-name "main" \
#             --job-id "${ACTIVE_JOB_ID}" \
#             --query 'job.summary.status' \
#             --output text)

#         if [ "$JOB_STATUS" = "SUCCEED" ]; then
#             echo "Deployment completed successfully!"
#             break
#         elif [ "$JOB_STATUS" = "FAILED" ]; then
#             echo "Deployment failed. Please check the AWS Amplify Console"
#             exit 1
#         else
#             echo "  Deployment status: ${JOB_STATUS}... Timeout after: ${DEPLOY_TIMEOUT}s... Time elapsed: ${ELAPSED}s..."
#             sleep $INTERVAL
#             ELAPSED=$((ELAPSED + INTERVAL))
#         fi
#     else
#         echo "Waiting for deployment to start..."
#         sleep $INTERVAL
#         ELAPSED=$((ELAPSED + INTERVAL))
#     fi
# done

# if [ $ELAPSED -ge $DEPLOY_TIMEOUT ]; then
#     echo "  Deployment verification timed out after ${DEPLOY_TIMEOUT} seconds"
#     echo "Please check the AWS Amplify Console for deployment status..."
# fi


############################################################################################################################
# END OF WAITING FOR APP TO COMPLETE




# Get the full URL of the app
echo " "
echo "------------------------------------- "
echo "Getting app information..."
FULL_URL=$(aws amplify get-app --app-id "${APP_ID}" --query 'app.defaultDomain' --output text)
FULL_URL="https://main.${FULL_URL}"
echo "App ID: ${APP_ID}"
echo "App URL: ${FULL_URL}"






echo ""
echo "✅ RESULT: Frontend deployed to Amplify! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"

######################################################################################################
echo " "
echo "-------------------------------------------------------------------"
echo "📣 UPDATE: Frontend complete! 🙌  "
echo "-------------------------------------------------------------------"
#endregion
#region BACKEND
#########################################################################################################################
#########################################################################################################################
# BACKEND: CREATES NODE BACKEND THEN CREATES GIT LOCAL AND REMOTE AND PUSHES
#########################################################################################################################
#########################################################################################################################
echo " "
echo "-------------------------------------------------------------------"
echo "📣 UPDATE: CREATING BACKEND..."
echo "-------------------------------------------------------------------"

#########################################################################################################################
# Create the final backend repo name with the appropriate version
echo ""
echo "🛠  ACTION: Creating BACKEND_REPO_NAME... "
echo " "

echo "Creating backend repo name with appropriate version..."
BACKEND_REPO_NAME="${BACKEND_NAME_ARG}-${CREATE_DATE}-${REPO_VERSION}"


echo ""
echo "✅ RESULT: BACKEND_REPO_NAME is $BACKEND_REPO_NAME! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"


#########################################################################################################################
# Create DB_POSTGRES from BACKEND_REPO_NAME
echo ""
echo "🛠  ACTION: Creating DB_POSTGRES variables from BACKEND_REPO_NAME... "


POSTGRES_CREATE_DATE=$(date '+%m_%d_%Y')

DB_POSTGRES=backend_${1}_${POSTGRES_CREATE_DATE}_${REPO_VERSION}_db_postgres
DB_POSTGRES_TEST=backend_test_${1}_${POSTGRES_CREATE_DATE}_${REPO_VERSION}_db_postgres


echo ""
echo "✅ RESULT: DB_POSTGRES variables successfully created! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"


#########################################################################################################################
# Create project folder
echo ""
echo "🛠  ACTION: Creating project folder... "



mkdir "$BACKEND_REPO_NAME"
cd "$BACKEND_REPO_NAME"


echo ""
echo "✅ RESULT: Project folder successfully created! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"


#########################################################################################################################
# Create and initialize repository local and remote
echo ""
echo "🛠  ACTION: Creating and initializing git local and remote..."
echo ""



git init
touch README.md
git add .
git commit -m "initial \(msg via shell\)"

git branch -M main

git branch Production
git branch Staging
git branch Development

gh repo create "$BACKEND_REPO_NAME" --public

git remote add origin "https://github.com/ScottFeichter/$BACKEND_REPO_NAME.git"

git push -u origin main
git push -u origin Production
git push -u origin Staging
git push -u origin Development


echo ""
echo "✅ RESULT: Git local and remote successfully created! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"


###################################################################################################
# Create .gitignore
echo ""
echo "🛠  ACTION: Creating .gitignore..."




cat > .gitignore << EOL
.DS_Store
dist/

# Logs
logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*
.pnpm-debug.log*

report.[0-9]*.[0-9]*.[0-9]*.[0-9]*.json

pids
*.pid
*.seed
*.pid.lock

lib-cov

coverage
*.lcov

.nyc_output

.grunt

bower_components

.lock-wscript

build/Release

node_modules/
jspm_packages/

web_modules/

*.tsbuildinfo

.npm

.eslintcache

.stylelintcache

.rpt2_cache/
.rts2_cache_cjs/
.rts2_cache_es/
.rts2_cache_umd/

.node_repl_history

*.tgz

.yarn-integrity

.env
.env/.env.development
.env/.env.production
.env/.env.testing
.env/.env.example

.cache
.parcel-cache

.next
out

.nuxt
dist

.cache/

.vuepress/dist

.temp
.cache

.docusaurus

.serverless/

.fusebox/

.dynamodb/

.tern-port

.vscode-test

.yarn/cache
.yarn/unplugged
.yarn/build-state.yml
.yarn/install-state.gz
.pnp.*
EOL


echo ""
echo "✅ RESULT: .gitignore successfully created! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"







###################################################################################################
# Create file structure
echo ""
echo "🛠  ACTION: Creating file structure... "


# Create src folder and sub folders
mkdir -p src/config
mkdir -p src/database/models
mkdir -p src/database/migrations
mkdir -p src/database/seeders
mkdir -p src/docs
mkdir -p src/docs/templates
mkdir -p src/middlewares
mkdir -p src/types
mkdir -p src/types/express
mkdir -p src/routes
mkdir -p src/routes/api
mkdir -p src/tests
mkdir -p src/tests/middleware
mkdir -p src/utils
mkdir -p src/logs
mkdir -p src/controller
mkdir -p .env
mkdir -p misc

# Create dist folder and sub folders (for compiled files)
# mkdir -p dist/config
# mkdir -p dist/database/models
# mkdir -p dist/database/migrations
# mkdir -p dist/database/seeders
# mkdir -p dist/middlewares
# mkdir -p dist/types
# mkdir -p dist/types/express
# mkdir -p dist/routes
# mkdir -p dist/routes/api
# mkdir -p dist/tests
# mkdir -p dist/tests/middleware
# mkdir -p dist/utils


echo ""
echo "✅ RESULT: File structure successfully created!"
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"





###################################################################################################
# Create a .env.example file for environment variables (db credentials)
echo ""
echo "🛠  ACTION: Creating .env.example file... "



cat > .env/.env.example << EOL
SERVER_PORT=5555
NODE_ENV=development

PG_DB_DIALECT=postgres
PG_DB_USER=postgres
PG_DB_PASSWORD=postgres
PG_DB_NAME=$DB_POSTGRES
PG_DB_PORT=5432
PG_DB_HOST=localhost

PG_DB_NAME_TEST=$DB_POSTGRES_TEST



JWT_ACCESS_TOKEN_SECRET=your_jwt_access_token_secret_here
JWT_REFRESH_TOKEN_SECRET=your_jwt_refresh_token_secret_here
JWT_EXPIRES_IN=604800
EOL

# Create similar entries in other .env files
cp .env/.env.example .env/.env.development
cp .env/.env.example .env/.env.testing
cp .env/.env.example .env/.env.production


echo ""
echo "✅ RESULT: The .env.example file successfully created! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"



###################################################################################################
# Load environment variables from .env.example
echo ""
echo "🛠  ACTION: Loading environment variables from .env.example... "



export $(cat .env/.env.example)


echo ""
echo "✅ RESULT: The environment variables are successfully loaded! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"


###################################################################################################
# Create the databases on postgres if they don't exist
echo ""
echo "🛠  ACTION: Creating postgres database if they don't exit... "
echo ""



PGPASSWORD=$PG_DB_PASSWORD psql -U $PG_DB_USER -h $PG_DB_HOST postgres << EOF
CREATE DATABASE $DB_POSTGRES;
CREATE DATABASE $DB_POSTGRES_TEST;
EOF




# Check if the database creation was successful
PGPASSWORD=$PG_DB_PASSWORD psql -U $PG_DB_USER -h $PG_DB_HOST postgres -c "SELECT datname FROM pg_database WHERE datname = '$DB_POSTGRES';" | grep -q "$DB_POSTGRES"
DB_EXISTS=$?

if [ $DB_EXISTS -eq 0 ]; then
    echo ""
    echo "✅ RESULT: Databases created successfully!"
else
    echo ""
    echo "❌ RESULT: Error: Failed to create databases. Make sure PostgreSQL is running and you have the correct permissions."
    echo ""
    echo "EXITING..."
    exit 1
fi

# Wait a moment for databases to be ready
sleep 2


echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"



###################################################################################################
# Add build and startup scripts to package.json
echo ""
echo "🛠  ACTION: Creating package.json... "



cat > package.json << EOL
{
  "name": "${BACKEND_REPO_NAME}",
  "version": "1.0.0",
  "description": "TypeScript Backend Node Express PostgreSQL Sequelize AWS",
  "author": "Scott Feichter",
  "license": "MIT",
  "repository": {
        "type": "git",
        "url": "https://github.com/ScottFeichter/${BACKEND_REPO_NAME}.git"
  },
  "main": "dist/server.js",
  "scripts": {
    "copy-files": "cp -r src/database/migrations dist/database/ && cp -r src/database/seeders dist/database/",
    "build": "tsc && tsc-alias && npm run copy-files && echo 'Build Finished! 👍'",
    "prod": "node dist/server.js",
    "dev": "nodemon dist/server.js",
    "sequelize": "sequelize",
    "sequelize-cli": "sequelize-cli",
    "watch": "tsc --watch",
    "lint": "eslint . --ext .ts",
    "test": "jest",
    "db:migrate": "sequelize-cli db:migrate",
    "db:seed": "sequelize-cli db:seed:all",
    "db:migrate:undo": "sequelize-cli db:migrate:undo",
    "db:seed:undo": "sequelize-cli db:seed:undo:all"
  },
  "dependencies": {
    "bcrypt": "^5.1.1",
    "morgan": "^1.10.0",
    "helmet": "^7.1.0",
    "cors": "^2.8.5",
    "jsonwebtoken": "^9.0.2",
    "cookie-parser": "^1.4.6",
    "csurf": "^1.11.0",
    "dotenv": "^16.3.1",
    "express": "^4.18.2",
    "pg": "^8.11.3",
    "pg-hstore": "^2.3.4",
    "sequelize": "^6.35.2",
    "sequelize-typescript": "^2.1.6",
    "swagger-jsdoc": "^6.2.8",
    "swagger-ui-express": "^5.0.1",
    "tsconfig-paths": "^4.2.0",
    "winston": "^3.15.0",
    "winston-daily-rotate-file": "^5.0.0"
  },
  "devDependencies": {
    "@types/cookie-parser": "^1.4.6",
    "@types/csurf": "^1.11.4",
    "@types/bcrypt": "^5.0.2",
    "@types/morgan": "^1.9.9",
    "@types/helmet": "^4.0.0",
    "@types/cors": "^2.8.17",
    "@types/jsonwebtoken": "^9.0.7",
    "@types/express": "^4.17.21",
    "@types/express-serve-static-core": "^4.17.35",
    "@types/pg": "^8.10.9",
    "@types/node": "^20.10.5",
    "@types/jest": "^29.5.11",
    "@types/sequelize": "^4.28.20",
    "@types/swagger-jsdoc": "^6.0.4",
    "@types/swagger-ui-express": "^4.1.6",
    "@typescript-eslint/eslint-plugin": "^6.15.0",
    "@typescript-eslint/parser": "^6.15.0",
    "typescript": "^5.3.3",
    "ts-node": "^10.9.2",
    "nodemon": "^3.0.2",
    "eslint": "^8.56.0",
    "ts-jest": "^29.1.1",
    "jest": "^29.7.0",
    "sequelize-cli": "^6.6.2",
    "tsconfig-paths": "^4.2.0",
    "tsc-alias": "^1.8.10"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
EOL

echo ""
echo "✅ RESULT: package.json successfully created! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"


###################################################################################################
# Run installs
echo ""
echo "🛠  ACTION: Running npm install... "
echo ""


npm install


echo ""
echo "✅ RESULT: Install successfull! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"




###################################################################################################
# Create and configure tsconfig.json
echo ""
echo "🛠  ACTION: Creating and configuring tscongif.json... "



cat > tsconfig.json << EOL
{
  "compilerOptions": {
    /* Visit https://aka.ms/tsconfig to read more about this file */

    /* Projects */
    // "incremental": true,                              /* Save .tsbuildinfo files to allow for incremental compilation of projects. */
    // "composite": true,                                /* Enable constraints that allow a TypeScript project to be used with project references. */
    // "tsBuildInfoFile": "./.tsbuildinfo",              /* Specify the path to .tsbuildinfo incremental compilation file. */
    // "disableSourceOfProjectReferenceRedirect": true,  /* Disable preferring source files instead of declaration files when referencing composite projects. */
    // "disableSolutionSearching": true,                 /* Opt a project out of multi-project reference checking when editing. */
    // "disableReferencedProjectLoad": true,             /* Reduce the number of projects loaded automatically by TypeScript. */

    /* Language and Environment */
    "target": "es6",                                     /* Set the JavaScript language version for emitted JavaScript and include compatible library declarations. */
    // "lib": [],                                        /* Specify a set of bundled library declaration files that describe the target runtime environment. */
    // "jsx": "preserve",                                /* Specify what JSX code is generated. */
    // "libReplacement": true,                           /* Enable lib replacement. */
    "experimentalDecorators": true,                      /* Enable experimental support for legacy experimental decorators. */
    // "emitDecoratorMetadata": true,                    /* Emit design-type metadata for decorated declarations in source files. */
    // "jsxFactory": "",                                 /* Specify the JSX factory function used when targeting React JSX emit, e.g. 'React.createElement' or 'h'. */
    // "jsxFragmentFactory": "",                         /* Specify the JSX Fragment reference used for fragments when targeting React JSX emit e.g. 'React.Fragment' or 'Fragment'. */
    // "jsxImportSource": "",                            /* Specify module specifier used to import the JSX factory functions when using 'jsx: react-jsx*'. */
    // "reactNamespace": "",                             /* Specify the object invoked for 'createElement'. This only applies when targeting 'react' JSX emit. */
    // "noLib": true,                                    /* Disable including any library files, including the default lib.d.ts. */
    // "useDefineForClassFields": true,                  /* Emit ECMAScript-standard-compliant class fields. */
    // "moduleDetection": "auto",                        /* Control what method is used to detect module-format JS files. */

    /* Modules */
    "module": "commonjs",                                /* Specify what module code is generated. */
    "rootDir": "./src",                                  /* Specify the root folder within your source files. */
    "moduleResolution": "node",                          /* Specify how TypeScript looks up a file from a given module specifier. */
    "baseUrl": "./",                                     /* Specify the base directory to resolve non-relative module names. */
    "paths": { "@/*": ["src/*"] },                       /* Specify a set of entries that re-map imports to additional lookup locations. */
    // "rootDirs": [],                                   /* Allow multiple folders to be treated as one when resolving modules. */
    "typeRoots": ["./node_modules/@types"],              /* Specify multiple folders that act like './node_modules/@types'. */
    "types": ["node", "jest"],                           /* Specify type package names to be included without being referenced in a source file. */
    // "allowUmdGlobalAccess": true,                     /* Allow accessing UMD globals from modules. */
    // "moduleSuffixes": [],                             /* List of file name suffixes to search when resolving a module. */
    // "allowImportingTsExtensions": true,               /* Allow imports to include TypeScript file extensions. Requires '--moduleResolution bundler' and either '--noEmit' or '--emitDeclarationOnly' to be set. */
    // "rewriteRelativeImportExtensions": true,          /* Rewrite '.ts', '.tsx', '.mts', and '.cts' file extensions in relative import paths to their JavaScript equivalent in output files. */
    // "resolvePackageJsonExports": true,                /* Use the package.json 'exports' field when resolving package imports. */
    // "resolvePackageJsonImports": true,                /* Use the package.json 'imports' field when resolving imports. */
    // "customConditions": [],                           /* Conditions to set in addition to the resolver-specific defaults when resolving imports. */
    // "noUncheckedSideEffectImports": true,             /* Check side effect imports. */
    "resolveJsonModule": true,                           /* Enable importing .json files. */
    // "allowArbitraryExtensions": true,                 /* Enable importing files with any extension, provided a declaration file is present. */
    // "noResolve": true,                                /* Disallow 'import's, 'require's or '<reference>'s from expanding the number of files TypeScript should add to a project. */

    /* JavaScript Support */
    // "allowJs": true,                                  /* Allow JavaScript files to be a part of your program. Use the 'checkJS' option to get errors from these files. */
    // "checkJs": true,                                  /* Enable error reporting in type-checked JavaScript files. */
    // "maxNodeModuleJsDepth": 1,                        /* Specify the maximum folder depth used for checking JavaScript files from 'node_modules'. Only applicable with 'allowJs'. */

    /* Emit */
    // "declaration": true,                              /* Generate .d.ts files from TypeScript and JavaScript files in your project. */
    // "declarationMap": true,                           /* Create sourcemaps for d.ts files. */
    // "emitDeclarationOnly": true,                      /* Only output d.ts files and not JavaScript files. */
    // "sourceMap": true,                                /* Create source map files for emitted JavaScript files. */
    // "inlineSourceMap": true,                          /* Include sourcemap files inside the emitted JavaScript. */
    // "noEmit": true,                                   /* Disable emitting files from a compilation. */
    // "outFile": "./",                                  /* Specify a file that bundles all outputs into one JavaScript file. If 'declaration' is true, also designates a file that bundles all .d.ts output. */
    "outDir": "./dist",                                   /* Specify an output folder for all emitted files. */
    // "removeComments": true,                           /* Disable emitting comments. */
    // "importHelpers": true,                            /* Allow importing helper functions from tslib once per project, instead of including them per-file. */
    // "downlevelIteration": true,                       /* Emit more compliant, but verbose and less performant JavaScript for iteration. */
    // "sourceRoot": "",                                 /* Specify the root path for debuggers to find the reference source code. */
    // "mapRoot": "",                                    /* Specify the location where debugger should locate map files instead of generated locations. */
    // "inlineSources": true,                            /* Include source code in the sourcemaps inside the emitted JavaScript. */
    // "emitBOM": true,                                  /* Emit a UTF-8 Byte Order Mark (BOM) in the beginning of output files. */
    // "newLine": "crlf",                                /* Set the newline character for emitting files. */
    // "stripInternal": true,                            /* Disable emitting declarations that have '@internal' in their JSDoc comments. */
    // "noEmitHelpers": true,                            /* Disable generating custom helper functions like '__extends' in compiled output. */
    // "noEmitOnError": true,                            /* Disable emitting files if any type checking errors are reported. */
    // "preserveConstEnums": true,                       /* Disable erasing 'const enum' declarations in generated code. */
    // "declarationDir": "./",                           /* Specify the output directory for generated declaration files. */

    /* Interop Constraints */
    // "isolatedModules": true,                          /* Ensure that each file can be safely transpiled without relying on other imports. */
    // "verbatimModuleSyntax": true,                     /* Do not transform or elide any imports or exports not marked as type-only, ensuring they are written in the output file's format based on the 'module' setting. */
    // "isolatedDeclarations": true,                     /* Require sufficient annotation on exports so other tools can trivially generate declaration files. */
    // "erasableSyntaxOnly": true,                       /* Do not allow runtime constructs that are not part of ECMAScript. */
    // "allowSyntheticDefaultImports": true,             /* Allow 'import x from y' when a module doesn't have a default export. */
    "esModuleInterop": true,                             /* Emit additional JavaScript to ease support for importing CommonJS modules. This enables 'allowSyntheticDefaultImports' for type compatibility. */
    // "preserveSymlinks": true,                         /* Disable resolving symlinks to their realpath. This correlates to the same flag in node. */
    "forceConsistentCasingInFileNames": true,            /* Ensure that casing is correct in imports. */

    /* Type Checking */
    "strict": true,                                      /* Enable all strict type-checking options. */
    // "noImplicitAny": true,                            /* Enable error reporting for expressions and declarations with an implied 'any' type. */
    // "strictNullChecks": true,                         /* When type checking, take into account 'null' and 'undefined'. */
    // "strictFunctionTypes": true,                      /* When assigning functions, check to ensure parameters and the return values are subtype-compatible. */
    // "strictBindCallApply": true,                      /* Check that the arguments for 'bind', 'call', and 'apply' methods match the original function. */
    "strictPropertyInitialization": true,                /* Check for class properties that are declared but not set in the constructor. */
    // "strictBuiltinIteratorReturn": true,              /* Built-in iterators are instantiated with a 'TReturn' type of 'undefined' instead of 'any'. */
    // "noImplicitThis": true,                           /* Enable error reporting when 'this' is given the type 'any'. */
    // "useUnknownInCatchVariables": true,               /* Default catch clause variables as 'unknown' instead of 'any'. */
    // "alwaysStrict": true,                             /* Ensure 'use strict' is always emitted. */
    // "noUnusedLocals": true,                           /* Enable error reporting when local variables aren't read. */
    // "noUnusedParameters": true,                       /* Raise an error when a function parameter isn't read. */
    // "exactOptionalPropertyTypes": true,               /* Interpret optional property types as written, rather than adding 'undefined'. */
    // "noImplicitReturns": true,                        /* Enable error reporting for codepaths that do not explicitly return in a function. */
    // "noFallthroughCasesInSwitch": true,               /* Enable error reporting for fallthrough cases in switch statements. */
    // "noUncheckedIndexedAccess": true,                 /* Add 'undefined' to a type when accessed using an index. */
    // "noImplicitOverride": true,                       /* Ensure overriding members in derived classes are marked with an override modifier. */
    // "noPropertyAccessFromIndexSignature": true,       /* Enforces using indexed accessors for keys declared using an indexed type. */
    // "allowUnusedLabels": true,                        /* Disable error reporting for unused labels. */
    // "allowUnreachableCode": true,                     /* Disable error reporting for unreachable code. */

    /* Completeness */
    // "skipDefaultLibCheck": true,                      /* Skip type checking .d.ts files that are included with TypeScript. */
    "skipLibCheck": true                                 /* Skip type checking all .d.ts files. */
  },
  "include": ["src/**/*.ts"],
  "exclude": ["node_modules"]
}
EOL


echo ""
echo "✅ RESULT: tsconfig.json successfully created! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"



###################################################################################################
# Create config files for exporting
echo ""
echo "🛠  ACTION: Creating config files for exports... "


# Create a database configuration file using modules:
cat > src/config/env-module.ts << 'EOL'
import { Sequelize } from 'sequelize-typescript';
import { User } from '../database/models/User';  // Import the User model
import dotenv from 'dotenv';
dotenv.config();

export const JWT_ACCESS_TOKEN_SECRET = process.env.JWT_ACCESS_TOKEN_SECRET;

const SEQUELIZE = new Sequelize({
  dialect: 'postgres',
  host: process.env.PG_DB_HOST,
  username: process.env.PG_DB_USER,
  password: process.env.PG_DB_PASSWORD,
  database: process.env.PG_DB_NAME,
  port: parseInt(process.env.PG_DB_PORT || '5432'),
  logging: false,
  models: [User],
});

export default SEQUELIZE;
EOL




# Create a database configuration file using common (for sequelize-cli and perhaps others):
cat > src/config/env-common.ts << 'EOL'
const { config } = require('dotenv');

console.log(config({ path: '.env/.env.example'}));
console.log('Database Password:', process.env.PG_DB_PASSWORD);

type DatabaseConfig = {
  username: string;
  password: string;
  database: string;
  host: string;
  port: number;
  dialect: 'postgres';
};

const development: DatabaseConfig = {
  username: String(process.env.PG_DB_USER || 'postgres'),
  password: String(process.env.PG_DB_PASSWORD || ''), // Ensure it's a string
  database: String(process.env.PG_DB_NAME || 'db_postgres'),
  host: String(process.env.PG_DB_HOST || 'localhost'),
  port: parseInt(String(process.env.PG_DB_PORT || '5432'), 10),
  dialect: 'postgres',
};

const test: DatabaseConfig = {
  username: String(process.env.PG_DB_USER || 'postgres'),
  password: String(process.env.PG_DB_PASSWORD || ''),
  database: String(process.env.PG_DB_NAME_TEST || 'db_postgres_test'),
  host: String(process.env.PG_DB_HOST || 'localhost'),
  port: parseInt(String(process.env.PG_DB_PORT || '5432'), 10),
  dialect: 'postgres',
};

const production: DatabaseConfig = {
  username: String(process.env.PG_DB_USER || 'postgres'),
  password: String(process.env.PG_DB_PASSWORD || ''),
  database: String(process.env.PG_DB_NAME || 'db_postgres'),
  host: String(process.env.PG_DB_HOST || 'localhost'),
  port: parseInt(String(process.env.PG_DB_PORT || '5432'), 10),
  dialect: 'postgres',
};

export = { development, test, production };
EOL


echo ""
echo "✅ RESULT: Config files successfully created! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"



###################################################################################################
# Create .sequelizerc file:
echo ""
echo "🛠  ACTION: Creating .sequelizerc file... "



cat > .sequelizerc << 'EOL'
const path = require('path');

module.exports = {
  'config': path.resolve('dist/config', 'env-common.js'),
  'models-path': path.resolve('dist/database', 'models'),
  'seeders-path': path.resolve('dist/database', 'seeders'),
  'migrations-path': path.resolve('dist/database', 'migrations')
};
EOL


echo ""
echo "✅ RESULT: .sequelizerc file successfully created! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"



###################################################################################################
# Create src/middlewares/jwt.service.ts
echo ""
echo "🛠  ACTION: Creating src/middlewares/jwt.service.ts file... "




cat > src/middlewares/jwt.service.ts << EOL
import jwt from 'jsonwebtoken';

export const generateJWT = async (payload: any, secretKey: string) => {
    try {
        const token = \`Bearer \${jwt.sign(payload, secretKey)}\`;
        return token;
    } catch (error: any) {
        throw new Error(error.message);
    }
};

export const verifyJWT = async (
    token: string,
    secretKey: string,
): Promise<jwt.JwtPayload> => {
    try {
        const cleanedToken = token.replace('Bearer ', '');
        const data = jwt.verify(cleanedToken, secretKey);

        if (typeof data === 'string') {
            throw new Error('Invalid token payload');
        }

        return data as jwt.JwtPayload;
    } catch (error: any) {
        throw new Error(error.message);
    }
};
EOL


echo ""
echo "✅ RESULT: src/middlewares/jwt.service.ts file successfully created! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"




###################################################################################################
# Create src/types/interface.ts
echo ""
echo "🛠  ACTION: Creating src/types/interface.ts file... "

cat > src/types/interface.ts << EOL
import { Request as ExpressRequest } from 'express';

export interface Request extends ExpressRequest {
  csrfToken(): string;
}

export interface CSRFError extends Error {
  code?: string;
}

export interface TimeResult {
  now: Date;
}
EOL


echo ""
echo "✅ RESULT: src/types/interface.ts file successfully created! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"





###################################################################################################
# Create src/types/index.ts
echo ""
echo "🛠  ACTION: Creating src/types/index.ts file... "

cat > src/types/index.ts << EOL
export { Request, CSRFError } from './interface';
export interface TimeResult {
    now: Date;
}
EOL

echo ""
echo "✅ RESULT: src/types/index.ts file successfully created! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"





###################################################################################################
# Create src/middleware/setup-middleware.ts
echo ""
echo "🛠  ACTION: Creating src/middlewares/setup-middleware.ts file... "


cat > src/middlewares/setup-middleware.ts << EOL
import { Response, NextFunction } from 'express';
import express from 'express';
import morgan from 'morgan';
import helmet from 'helmet';
import cors from 'cors';
import cookieParser from 'cookie-parser';
import csrf from 'csurf';
import { SERVER } from '../server';
import { Request, CSRFError } from '../types';

export const setupMiddleware = () => {
  SERVER.use(morgan('development'));
  SERVER.use(cookieParser());
  SERVER.use(express.json());


  SERVER.use(cors({
    origin: ['http://localhost:5555', 'http://127.0.0.1:5555', 'file://', 'http://localhost:3000'],
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    allowedHeaders: ['Content-Type', 'Authorization', 'XSRF-Token'],
    credentials: true
  }));


  // helmet helps set a variety of headers to better secure your app
  SERVER.use(
    helmet.crossOriginResourcePolicy({
        policy: "cross-origin"
    })
  );



  const csrfProtection = csrf({
    cookie: {
      secure: process.env.NODE_ENV === 'production',
      sameSite: process.env.NODE_ENV === 'production' ? 'lax' : undefined,
      httpOnly: true
    }
  });

  SERVER.use(csrfProtection as express.RequestHandler);

  SERVER.use((err: CSRFError, req: Request, res: Response, next: NextFunction) => {
    if (err.code === 'EBADCSRFTOKEN') {
      res.status(403).json({ error: 'Invalid CSRF token' });
    } else {
      next(err);
    }
  });
};
EOL




echo ""
echo "✅ RESULT: src/middlewares/setup-middleware.ts file successfully created! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"



###################################################################################################
# Create src/database/init.ts
echo ""
echo "🛠  ACTION: Creating src/database/init.ts file... "


cat > src/database/init.ts << EOL
import SEQUELIZE from '../config/env-module';
import { User } from './models/User';

export const initDatabase = async () => {
  try {
    await SEQUELIZE.authenticate();
    console.log('Database connection established.');
    await SEQUELIZE.sync({ alter: true });
    console.log('Models synchronized.');

    const testUser = await User.findOne({
      where: { email: 'test@example.com' }
    });

    if (!testUser) {
      await User.create({
        name: 'Test User',
        email: 'test@example.com'
      });
      console.log('Test user created successfully.');
    } else {
      console.log('Test user already exists.');
    }
  } catch (error) {
    console.error('Unable to connect to database:', error);
  }
};
EOL



echo ""
echo "✅ RESULT: src/database/init.ts file successfully created! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"


###################################################################################################
# Create src/routes/setup-routes.ts
echo ""
echo "🛠  ACTION: Creating src/routes/setup-routes.ts file... "


cat > src/routes/setup-routes.ts << EOL
import { Response } from 'express';
import { QueryTypes } from 'sequelize';
import { Request, TimeResult } from '../types';
import { User } from '../database/models/User';
import SEQUELIZE from '../config/env-module';
import { SERVER } from '../server';

export const setupRoutes = () => {
  SERVER.get('/', async (req: Request, res: Response) => {
    try {
      await SEQUELIZE.authenticate();
      const [results] = await SEQUELIZE.query<TimeResult>('SELECT NOW()', {
        raw: true,
        type: QueryTypes.SELECT
      });
      res.json({
        message: 'PostgreSQL connected with Sequelize!',
        time: results.now
      });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Database connection failed' });
    }
  });

  SERVER.post('/users', async (req: Request, res: Response) => {
    try {
      const user = await User.create(req.body);
      res.json(user);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Failed to create user' });
    }
  });

  SERVER.get('/users', async (req: Request, res: Response) => {
    try {
      const users = await User.findAll();
      res.json(users);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Failed to fetch users' });
    }
  });

  SERVER.get('/api/csrf/restore', (req: Request, res: Response) => {
    res.cookie('XSRF-TOKEN', req.csrfToken());
    res.status(200).json({ message: 'CSRF token restored' });
  });
};
EOL



echo ""
echo "✅ RESULT: src/routes/setup-routes.ts file successfully created! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"



###################################################################################################
# Create the custom-error utility file:
echo ""
echo "🛠  ACTION: Creating src/utils/custom-error.ts file... "


cat > src/utils/custom-error.ts << EOL
export class CustomError extends Error {
    statusCode: number;

    constructor(message: string, statusCode: number) {
        super(message);
        this.statusCode = statusCode;
        this.name = 'CustomError';
    }
}
EOL


echo ""
echo "✅ RESULT: src/utils/custom-error.ts file successfully created! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"





###################################################################################################
# Create src/middlewares/auth-middleware.ts
echo ""
echo "🛠  ACTION: Creating src/middlewares/auth-middleware.ts file... "



cat > src/middlewares/auth-middleware.ts << EOL
import { CustomError } from '@/utils/custom-error';
import { verifyJWT } from './jwt.service';
import { JWT_ACCESS_TOKEN_SECRET } from '@/config/env-module';
import { NextFunction, Request, Response } from 'express';

const decodeToken = async (header: string | undefined) => {
    if (!header) {
        throw new CustomError('Authorization header missing', 401);
    }

    const token = header.replace('Bearer ', '');
    const payload = await verifyJWT(token, JWT_ACCESS_TOKEN_SECRET as string);

    return payload;
};

export const authMiddleware = async (
    req: Request,
    res: Response,
    next: NextFunction,
) => {
    const { method, path } = req;

    if (method === 'OPTIONS' || ['/api/auth/signin'].includes(path)) {
        return next();
    }

    try {
        const authHeader =
            req.header('Authorization') || req.header('authorization');
        req.context = await decodeToken(authHeader);
        next();
    } catch (error) {
        next(error);
    }
};
EOL

echo ""
echo "✅ RESULT: src/middlewares/auth-middleware.ts file successfully created! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"



###################################################################################################
# Create src/types/express/index.d.ts for TypeScript support
echo ""
echo "🛠  ACTION: Creating src/types/express/index.d.ts file... "



cat > src/types/express/index.d.ts << EOL
import { JwtPayload } from 'jsonwebtoken';

declare module 'express-serve-static-core' {
    interface Request {
        context?: JwtPayload;
    }
}
EOL

echo ""
echo "✅ RESULT: src/types/express/index.d.ts file successfully created! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"


###################################################################################################
# Create JWT test file
echo ""
echo "🛠  ACTION: Creating src/tests/middleware/jwt.service.test.ts file... "



cat > src/tests/middleware/jwt.service.test.ts << EOL
/// <reference types="jest" />
import jwt from 'jsonwebtoken';
import { generateJWT, verifyJWT } from '../../middlewares/jwt.service';

jest.mock('jsonwebtoken', () => ({
    sign: jest.fn(),
    verify: jest.fn(),
}));

describe('JWT Service', () => {
    const secretKey = 'test_secret';
    const payload = { userId: '123' };

    beforeEach(() => {
        jest.clearAllMocks();
    });

    test('generateJWT should return a valid token', async () => {
        (jwt.sign as jest.Mock).mockReturnValue('mockedToken');

        const token = await generateJWT(payload, secretKey);

        expect(jwt.sign).toHaveBeenCalledWith(payload, secretKey);
        expect(token).toBe('Bearer mockedToken');
    });

    test('verifyJWT should return the correct payload when token is valid', async () => {
        (jwt.verify as jest.Mock).mockReturnValue(payload);

        const result = await verifyJWT('Bearer validToken', secretKey);

        expect(jwt.verify).toHaveBeenCalledWith('validToken', secretKey);
        expect(result).toEqual(payload);
    });

    test('verifyJWT should throw an error if token is invalid', async () => {
        (jwt.verify as jest.Mock).mockImplementation(() => {
            throw new Error('Invalid token');
        });

        await expect(verifyJWT('Bearer invalidToken', secretKey)).rejects.toThrow(
            'Invalid token'
        );
    });
});
EOL

echo ""
echo "✅ RESULT: src/tests/middleware/jwt.service.test.ts file successfully created! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"



###################################################################################################
# Create sample model
echo ""
echo "🛠  ACTION: Creating src/database/models/User.ts file... "




cat > src/database/models/User.ts << 'EOL'
import { Table, Column, Model, DataType } from 'sequelize-typescript';

@Table({
  tableName: 'users',
  timestamps: true
})
export class User extends Model {
  @Column({
    type: DataType.INTEGER,
    primaryKey: true,
    autoIncrement: true
  })
  id!: number;

  @Column({
    type: DataType.STRING,
    allowNull: false
  })
  name!: string;

  @Column({
    type: DataType.STRING,
    allowNull: false,
    unique: true
  })
  email!: string;
}
EOL


echo ""
echo "✅ RESULT: src/database/models/User.ts file successfully created! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"



###################################################################################################
# Create an example migration
# Note that migrations and seeders remain as JavaScript files because Sequelize CLI doesn't directly support TypeScript files.
# However, they include TypeScript type annotations through JSDoc comments.
echo ""
echo "🛠  ACTION: Creating example migration file... "



cat > src/database/migrations/$(date +%Y%m%d%H%M%S)-create-users.js << 'EOL'
'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('users', {
      id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER
      },
      name: {
        type: Sequelize.STRING,
        allowNull: false
      },
      email: {
        type: Sequelize.STRING,
        allowNull: false,
        unique: true
      },
      createdAt: {
        allowNull: false,
        type: Sequelize.DATE
      },
      updatedAt: {
        allowNull: false,
        type: Sequelize.DATE
      }
    });
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('users');
  }
};
EOL

echo ""
echo "✅ RESULT: Example migration file successfully created! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"



###################################################################################################
# Create an example seeder
# Note that migrations and seeders remain as JavaScript files because Sequelize CLI doesn't directly support TypeScript files.
# However, they include TypeScript type annotations through JSDoc comments.
echo ""
echo "🛠  ACTION: Creating example seeder file... "



cat > src/database/seeders/$(date +%Y%m%d%H%M%S)-demo-users.js << 'EOL'
'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.bulkInsert('users', [{
      name: 'Demo User',
      email: 'demo-user@example.com',
      createdAt: new Date(),
      updatedAt: new Date()
    }], {});
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.bulkDelete('users', null, {});
  }
};
EOL


echo ""
echo "✅ RESULT: Example seeder file successfully created! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"



###################################################################################################
# Establish a PostgreSQL connection using the pg library
echo ""
echo "🛠  ACTION: Establishing a PostgreSQL connection using the pg library... "




cat > src/postgres.ts << 'EOL'
import { Pool } from 'pg';
import dotenv from 'dotenv';
dotenv.config();

const POSTGRES = new Pool({
  host: process.env.PG_DB_HOST,
  user: process.env.PG_DB_USER,
  password: process.env.PG_DB_PASSWORD,
  database: process.env.PG_DB_NAME,
  port: parseInt(process.env.PG_DB_PORT || '5432'),
});

export default POSTGRES;
EOL


echo ""
echo "✅ RESULT: Established a PostgreSQL connection using the pg library! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"


###################################################################################################
# Set up a Express server to handle requests
echo ""
echo "🛠  ACTION: Creating server src/server.ts file... "




cat > src/server.ts << 'EOL'
import { setupMiddleware } from './middlewares/setup-middleware';
import { setupRoutes } from './routes/setup-routes';
import { initDatabase } from './database/init';
import express, { Application } from 'express';
import dotenv from 'dotenv';

dotenv.config();

export const SERVER: Application = express();
export const port = process.env.SERVER_PORT || 5555;

const start = async () => {
  try {
    setupMiddleware();
    setupRoutes();
    await initDatabase();

    SERVER.listen(port, () => {
      console.log("");
      console.log(`✅ RESULT: Server is running on port ${port}`);
      console.log("");
    });
  } catch (error) {
    console.log("");
    console.error('❌ RESULT: Failed to start server:', error);
    process.exit(1);
  }
};

start();
EOL


echo ""
echo "✅ RESULT: Created server src/server.ts file! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"



###################################################################################################
# Create logger via Winston
echo ""
echo "🛠  ACTION: Creating logger.ts... "


cat > src/utils/logger.ts << EOL
import winston from 'winston';
import 'winston-daily-rotate-file';
import path from 'path';

// Folder paths for logs
const logDir = path.join(__dirname, '../logs');

const logFormatter = winston.format.printf(info => {
    const { timestamp, level, stack, message } = info;
    const errorMessage = stack || message;

    const symbols = Object.getOwnPropertySymbols(info);
    if (info[symbols[0]] !== 'error') {
        return `[\${timestamp}] - \${level}: \${message}`;
    }

    return `[\${timestamp}] \${level}: \${errorMessage}`;
});

// Daily Rotate File for debug logs
const debugTransport = new winston.transports.DailyRotateFile({
    filename: `\${logDir}/debug/debug-%DATE%.log`,
    datePattern: 'YYYY-MM-DD',
    level: 'debug',
    maxFiles: '14d', // Keep logs for 14 days
});

// Daily Rotate File for error logs
const errorTransport = new winston.transports.DailyRotateFile({
    filename: `\${logDir}/error/error-%DATE%.log`,
    datePattern: 'YYYY-MM-DD',
    level: 'error',
    maxFiles: '30d', // Keep error logs for 30 days
});

// Console transport for development
const consoleTransport = new winston.transports.Console({
    format: winston.format.combine(winston.format.colorize(), logFormatter),
});

// Winston Logger Configuration
const logger = winston.createLogger({
    level: process.env.NODE_ENV === 'production' ? 'info' : 'debug',
    format: winston.format.combine(
        winston.format.timestamp(),
        winston.format.printf(({ timestamp, level, message }) => {
            return `[\${timestamp}] \${level.toUpperCase()}: \${message}`;
        }),
    ),
    transports: [consoleTransport, debugTransport, errorTransport],
});

export default logger;


EOL


echo ""
echo "✅ RESULT: Created logger.ts! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"




###################################################################################################
# Create LICENSE
echo ""
echo "🛠  ACTION: Creating LICENSE... "



cat > misc/LICENSE << EOL
MIT License

Copyright (c) 2025 Scott Feichter

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOL


echo ""
echo "✅ RESULT: Created misc/LICENSE! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"



###################################################################################################
# Compile ts and build
echo ""
echo "🛠  ACTION: Compiling ts and building... "
echo ""

npm run build


echo ""
echo "✅ RESULT: Compile and build complete! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"


###################################################################################################
# Run migros and seeders
echo ""
echo "🛠  ACTION: Running migrations and seeders... "
echo ""


# Run migrations
npm run db:migrate

# Run seeders
npm run db:seed


echo ""
echo "✅ RESULT: Migrations and seeders ran! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"



###################################################################################################
# Final git pull stage add push
echo ""
echo "🛠  ACTION: Pulling, Staging, Committing, Pushing..."
echo ""


# Pull from main into Production, Development, and Staging
branches=("Production" "Development" "Staging")
for branch in "${branches[@]}"; do
    echo "Pulling latest changes from main into $branch..."
    git checkout $branch
    git pull origin main
    git push origin $branch
done

git checkout main

git add -A
git commit -m "Backend install and setup complete"
git push



echo ""
echo "✅ RESULT: Add, commit, push finsished! "
echo ""
read -p "⏸️  PAUSE: Press Enter to finish backend 🏁 and create AWS services..."
echo ""
echo "-------------------------------------------------------------------"


###################################################################################################
echo " "
echo "-------------------------------------------------------------------"
echo "📣 UPDATE: BACKEND SETUP COMPLETE! 🙌  "
echo "-------------------------------------------------------------------"
#endregion
#region AWS Create
#########################################################################################################################
#########################################################################################################################
# AWS: CREATING SERVICES AND CI/CD
#########################################################################################################################
#########################################################################################################################
echo ""
echo "-------------------------------------------------------------------"
echo "📣 UPDATE: CREATING AWS SERVICES AND CI/CD..."
echo "-------------------------------------------------------------------"




###################################################################################################
# Create VPC on AWS...
echo ""
echo "🛠  ACTION: Create VPC on AWS...  "
echo ""


# Here's a script that creates a VPC and attaches an Internet Gateway to it. The script includes error checking and outputs the created resource IDs
#######################################################################################
# To make the script executable:

    # chmod +x create-vpc-w-gateway.sh


#######################################################################################
# THIS SCRIPT TAKES AN ARGUMENT - TO RUN IT:

    # ./create-vpc-w-gateway.sh $some-vpc-name-of-your-choice


#######################################################################################

# The script will:

        # Create a VPC with CIDR block 10.0.0.0/16

        # Enable DNS hostnames and DNS support

        # Create an Internet Gateway

        # Attach the Internet Gateway to the VPC

        # Add appropriate name tags to resources

        # Output the resource IDs for reference

# Important notes:

        # Make sure you have AWS CLI installed and configured

        # Adjust the REGION variable to your desired AWS region

        # Modify the CIDR block if needed

        # The VPC will be named "MyAppVPC" (change VPC_NAME if desired)

        # The script includes error checking at critical steps

        # Resources created will incur AWS charges

# This creates the basic VPC infrastructure needed before creating subnets, route tables, and other resources.



# Set variables
VPC_NAME="$1-$CREATE_DATE-$REPO_VERSION"
VPC_CIDR="10.0.0.0/16"
REGION="us-east-1"  # Change this to your desired region

echo "Creating VPC..."
VPC_ID=$(aws ec2 create-vpc \
  --cidr-block $VPC_CIDR \
  --region $REGION \
  --output text \
  --query 'Vpc.VpcId')

if [ -z "$VPC_ID" ]; then
    echo "VPC creation failed"
    exit 1
fi

# Add Name tag to VPC
aws ec2 create-tags \
  --resources $VPC_ID \
  --tags Key=Name,Value=$VPC_NAME

# Enable DNS hostname support for the VPC
aws ec2 modify-vpc-attribute \
  --vpc-id $VPC_ID \
  --enable-dns-hostnames "{\"Value\":true}"

# Enable DNS support for the VPC
aws ec2 modify-vpc-attribute \
  --vpc-id $VPC_ID \
  --enable-dns-support "{\"Value\":true}"

echo "VPC created with ID: $VPC_ID"

# Create Internet Gateway
echo "Creating Internet Gateway..."
IGW_ID=$(aws ec2 create-internet-gateway \
  --output text \
  --query 'InternetGateway.InternetGatewayId')

if [ -z "$IGW_ID" ]; then
    echo "Internet Gateway creation failed"
    exit 1
fi

# Add Name tag to Internet Gateway
aws ec2 create-tags \
  --resources $IGW_ID \
  --tags Key=Name,Value="${VPC_NAME}-IGW"

echo "Internet Gateway created with ID: $IGW_ID"

# Attach Internet Gateway to VPC
echo "Attaching Internet Gateway to VPC..."
aws ec2 attach-internet-gateway \
  --vpc-id $VPC_ID \
  --internet-gateway-id $IGW_ID

if [ $? -eq 0 ]; then
    echo "Internet Gateway successfully attached to VPC"
else
    echo "Failed to attach Internet Gateway to VPC"
    exit 1
fi

echo "VPC Setup Complete!"
echo "VPC ID: $VPC_ID"
echo "Internet Gateway ID: $IGW_ID"



echo ""
echo "✅ RESULT: VPC finsished! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue..."
echo ""
echo "-------------------------------------------------------------------"




###################################################################################################
# Create Subnets for VPC on AWS...
echo ""
echo "🛠  ACTION: Subnets for VPC on AWS...  "
echo ""


########################################################################################################################################################

        # The script will:

                # 1.  Create 1 public and 2 private subnets

                # 2.  Enable auto-assign public IP for public subnet

                # 3.  Create public route table with route to Internet Gateway

                # 4.  Create private route table

                # 5.  Create security groups with appropriate rules:

                        #     *   Public SG: Allows HTTP, HTTPS, and SSH from anywhere

                        #     *   Private SG: Allows all traffic from public security group

                # 6.  Tag all resources for easy identification

                #7.   Create CIDRs


        # Important notes:

                # *   Ensure your VPC has an Internet Gateway attached

                # *   CIDR blocks must be within your VPC's CIDR range

                # *   Security group rules can be modified based on your needs

                # *   The script assumes you're using the first availability zone in your region

                # *   All resources are properly tagged for easier management


########################################################################################################################################################



# Set initial variables

REGION=$(aws configure get region)  # Get region from AWS CLI configuration

# Verify VPC exists and get VPC CIDR
if ! VPC_CIDR=$(aws ec2 describe-vpcs \
    --vpc-ids $VPC_ID \
    --query 'Vpcs[0].CidrBlock' \
    --output text 2>/dev/null); then
    echo "Error: VPC $VPC_ID not found"
    exit 1
fi

echo "Using VPC: $VPC_ID with CIDR: $VPC_CIDR"

# Calculate subnet CIDRs based on VPC CIDR
# Example: If VPC is 10.0.0.0/16, create /24 subnets
VPC_PREFIX=$(echo $VPC_CIDR | cut -d'.' -f1,2)  # Get first two octets (e.g., 10.0)
PUBLIC_CIDR="${VPC_PREFIX}.1.0/24"    # 10.0.1.0/24
PRIVATE_CIDR_1="${VPC_PREFIX}.2.0/24" # 10.0.2.0/24
PRIVATE_CIDR_2="${VPC_PREFIX}.3.0/24" # 10.0.3.0/24

# Get available AZs in the region and select first two
AVAILABLE_AZS=$(aws ec2 describe-availability-zones \
    --filters "Name=state,Values=available" \
    --query 'AvailabilityZones[].ZoneName' \
    --output text)

AZ1=$(echo $AVAILABLE_AZS | cut -d' ' -f1)
AZ2=$(echo $AVAILABLE_AZS | cut -d' ' -f2)

# Verify we have enough AZs
if [ -z "$AZ1" ] || [ -z "$AZ2" ]; then
    echo "Error: Need at least 2 availability zones"
    exit 1
fi


# Print configuration for verification
echo "----------------------------------------"
echo "Configuration:"
echo "VPC ID: $VPC_ID"
echo "Region: $REGION"
echo "VPC CIDR: $VPC_CIDR"
echo "Public Subnet CIDR: $PUBLIC_CIDR"
echo "Private Subnet 1 CIDR: $PRIVATE_CIDR_1"
echo "Private Subnet 2 CIDR: $PRIVATE_CIDR_2"
echo "Availability Zone 1: $AZ1"
echo "Availability Zone 2: $AZ2"
echo "----------------------------------------"

# Verify subnet CIDRs don't already exist in VPC
EXISTING_CIDRS=$(aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$VPC_ID" \
    --query 'Subnets[].CidrBlock' \
    --output text)

for CIDR in "$PUBLIC_CIDR" "$PRIVATE_CIDR_1" "$PRIVATE_CIDR_2"; do
    if echo "$EXISTING_CIDRS" | grep -q "$CIDR"; then
        echo "Error: CIDR $CIDR already exists in VPC"
        exit 1
    fi
done


#! I am turning this confirmaion off as it appears to be unnecessary
# # Ask for confirmation before proceeding
# read -p "Do you want to proceed with this configuration? (y/n) " -n 1 -r
# echo
# if [[ ! $REPLY =~ ^[Yy]$ ]]; then
#     echo "Operation cancelled"
#     exit 1
# fi


# Set AWS CLI output format
export AWS_DEFAULT_OUTPUT="json"
export AWS_PAGER=""

echo "Creating subnets and networking components..."
echo "----------------------------------------"

# Create public subnet in AZ1
echo "Creating public subnet in ${AZ1}..."
PUBLIC_SUBNET_ID=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block $PUBLIC_CIDR \
    --availability-zone $AZ1 \
    --query 'Subnet.SubnetId' \
    --output text)

if [ -z "$PUBLIC_SUBNET_ID" ]; then
    echo "Failed to create public subnet"
    exit 1
fi

# Tag public subnet
aws ec2 create-tags \
    --resources $PUBLIC_SUBNET_ID \
    --tags Key=Name,Value=Public-Subnet

# Enable auto-assign public IP for public subnet
aws ec2 modify-subnet-attribute \
    --subnet-id $PUBLIC_SUBNET_ID \
    --map-public-ip-on-launch

echo "Public subnet created: $PUBLIC_SUBNET_ID"

# Create first private subnet in AZ1
echo "Creating first private subnet in ${AZ1}..."
PRIVATE_SUBNET_ID_1=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block $PRIVATE_CIDR_1 \
    --availability-zone $AZ1 \
    --query 'Subnet.SubnetId' \
    --output text)

if [ -z "$PRIVATE_SUBNET_ID_1" ]; then
    echo "Failed to create first private subnet"
    exit 1
fi

# Tag first private subnet
aws ec2 create-tags \
    --resources $PRIVATE_SUBNET_ID_1 \
    --tags Key=Name,Value=Private-Subnet-1

# Create second private subnet in AZ2
echo "Creating second private subnet in ${AZ2}..."
PRIVATE_SUBNET_ID_2=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block $PRIVATE_CIDR_2 \
    --availability-zone $AZ2 \
    --query 'Subnet.SubnetId' \
    --output text)

if [ -z "$PRIVATE_SUBNET_ID_2" ]; then
    echo "Failed to create second private subnet"
    exit 1
fi

# Tag second private subnet
aws ec2 create-tags \
    --resources $PRIVATE_SUBNET_ID_2 \
    --tags Key=Name,Value=Private-Subnet-2

echo "Private subnets created: $PRIVATE_SUBNET_ID_1, $PRIVATE_SUBNET_ID_2"

# Create public route table
echo "Creating public route table..."
PUBLIC_RT_ID=$(aws ec2 create-route-table \
    --vpc-id $VPC_ID \
    --query 'RouteTable.RouteTableId' \
    --output text)

# Tag public route table
aws ec2 create-tags \
    --resources $PUBLIC_RT_ID \
    --tags Key=Name,Value=Public-RT

# Get Internet Gateway ID
IGW_ID=$(aws ec2 describe-internet-gateways \
    --filters "Name=attachment.vpc-id,Values=$VPC_ID" \
    --query 'InternetGateways[0].InternetGatewayId' \
    --output text)

# Create route to Internet Gateway in public route table
aws ec2 create-route \
    --route-table-id $PUBLIC_RT_ID \
    --destination-cidr-block 0.0.0.0/0 \
    --gateway-id $IGW_ID

# Associate public subnet with public route table
aws ec2 associate-route-table \
    --subnet-id $PUBLIC_SUBNET_ID \
    --route-table-id $PUBLIC_RT_ID

echo "Public route table created and associated: $PUBLIC_RT_ID"

# Create private route table
echo "Creating private route table..."
PRIVATE_RT_ID=$(aws ec2 create-route-table \
    --vpc-id $VPC_ID \
    --query 'RouteTable.RouteTableId' \
    --output text)

# Tag private route table
aws ec2 create-tags \
    --resources $PRIVATE_RT_ID \
    --tags Key=Name,Value=Private-RT

# Associate both private subnets with private route table
aws ec2 associate-route-table \
    --subnet-id $PRIVATE_SUBNET_ID_1 \
    --route-table-id $PRIVATE_RT_ID

aws ec2 associate-route-table \
    --subnet-id $PRIVATE_SUBNET_ID_2 \
    --route-table-id $PRIVATE_RT_ID

echo "Private route table created and associated: $PRIVATE_RT_ID"

# Create security group for public subnet
echo "Creating public security group..."
PUBLIC_SG_ID=$(aws ec2 create-security-group \
    --group-name "Public-SG" \
    --description "Security group for public subnet" \
    --vpc-id $VPC_ID \
    --query 'GroupId' \
    --output text)

# Tag public security group
aws ec2 create-tags \
    --resources $PUBLIC_SG_ID \
    --tags Key=Name,Value=Public-SG

# Add inbound rules for public security group
aws ec2 authorize-security-group-ingress \
    --group-id $PUBLIC_SG_ID \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
    --group-id $PUBLIC_SG_ID \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
    --group-id $PUBLIC_SG_ID \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0

# Create security group for private subnet (RDS)
echo "Creating private security group for RDS..."
PRIVATE_SG_ID=$(aws ec2 create-security-group \
    --group-name "Private-RDS-SG" \
    --description "Security group for RDS in private subnet" \
    --vpc-id $VPC_ID \
    --query 'GroupId' \
    --output text)

# Tag private security group
aws ec2 create-tags \
    --resources $PRIVATE_SG_ID \
    --tags Key=Name,Value=Private-RDS-SG

# Add inbound rule for PostgreSQL from public security group only
aws ec2 authorize-security-group-ingress \
    --group-id $PRIVATE_SG_ID \
    --protocol tcp \
    --port 5432 \
    --source-group $PUBLIC_SG_ID

echo "Security groups created and configured:"


echo "----------------------------------------"
echo "Setup Complete!"
echo "Public Subnet ID: $PUBLIC_SUBNET_ID"
echo "Private Subnet 1 ID (AZ1): $PRIVATE_SUBNET_ID_1"
echo "Private Subnet 2 ID (AZ2): $PRIVATE_SUBNET_ID_2"
echo "Public Route Table ID: $PUBLIC_RT_ID"
echo "Private Route Table ID: $PRIVATE_RT_ID"
echo "Public Security Group (EC2): $PUBLIC_SG_ID"
echo "Private Security Group (RDS): $PRIVATE_SG_ID"


echo ""
echo "✅ RESULT: Subnets finished! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue..."
echo ""
echo "-------------------------------------------------------------------"



#######################################################################################
# Create EC2 on AWS...
echo ""
echo "🛠  ACTION: EC2 on AWS...  "
echo ""




# Disable AWS CLI pager to prevent requiring 'q' to continue
export AWS_PAGER=""

# Exit if any command fails
set -e

# Variables
ECC_NAME_ARG=$1-ec2
CREATE_DATE=$(date '+%m-%d-%Y')
EC2_INSTANCE_VERSION_EXISTS=false
INSTANCE_VERSION=1
MOST_RECENT_INSTANCE_VERSION="none"

# Check if instance with similar name exists
if aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=${ECC_NAME_ARG}*" \
    --query "Reservations[*].Instances[*].[InstanceId]" \
    --output text | grep -q .; then
    EC2_INSTANCE_VERSION_EXISTS=true
    echo "Recent version found..."

    # ADD DEBUGGING OUTPUT HERE - START
    echo "Debug: Listing all matching instance names:"
    aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=${ECC_NAME_ARG}-${CREATE_DATE}*" \
        --query "Reservations[*].Instances[*].Tags[?Key=='Name'].Value" \
        --output text

    echo "Debug: Attempting to extract version numbers:"
    aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=${ECC_NAME_ARG}-${CREATE_DATE}*" \
        --query "Reservations[*].Instances[*].Tags[?Key=='Name'].Value" \
        --output text | grep -o '[0-9]*$'
    # ADD DEBUGGING OUTPUT HERE - END

    # Get the highest version number from existing instances
    MOST_RECENT_INSTANCE_VERSION=$(aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=${ECC_NAME_ARG}-${CREATE_DATE}*" \
        --query "Reservations[*].Instances[*].Tags[?Key=='Name'].Value" \
        --output text | grep -o '[0-9]*$' | sort -nr | head -n 1)

    if [ -n "$MOST_RECENT_INSTANCE_VERSION" ]; then
        echo "Instance with similar name exists: Version $MOST_RECENT_INSTANCE_VERSION"
        echo "Incrementing version..."
        INSTANCE_VERSION=$((MOST_RECENT_INSTANCE_VERSION + 1))
    else
        echo "Found instance but couldn't determine version, using default version 1"
    fi
else
    echo "No instance with name including $1 is found..."
fi

echo "Ready to generate instance..."
INSTANCE_NAME="$ECC_NAME_ARG-$CREATE_DATE-$REPO_VERSION-v-$INSTANCE_VERSION"

# Print the variables (for verification)
echo "Name Argument: $ECC_NAME_ARG"
echo "Creation Date: $CREATE_DATE"
echo "Instance Exists: $EC2_INSTANCE_VERSION_EXISTS"
echo "Instance Version: $INSTANCE_VERSION"
echo "Final Instance Name: $INSTANCE_NAME"

KEY_PAIR_NAME="${INSTANCE_NAME}-key-pair"

INSTANCE_TYPE="t2.micro"
AMI_ID="ami-0440d3b780d96b29d"  # Amazon Linux 2023 AMI (adjust for your region)




# Verify VPC and Subnet exist
if [ -z "$VPC_ID" ] || [ "$VPC_ID" = "None" ]; then
    echo "Error: No VPC found"
    exit 1
fi

if [ -z "$PUBLIC_SUBNET_ID" ] || [ "$PUBLIC_SUBNET_ID" = "None" ]; then
    echo "Error: No subnet found in VPC $VPC_ID"
    exit 1
fi








# Verify network configuration
echo "Verifying network configuration..."
aws ec2 describe-subnets --subnet-ids "$PUBLIC_SUBNET_ID" || {
    echo "Error: Invalid subnet ID"
    exit 1
}

aws ec2 describe-vpcs --vpc-ids "$VPC_ID" || {
    echo "Error: Invalid VPC ID"
    exit 1
}

echo "Using VPC: $VPC_ID"
echo "Using Subnet: $PUBLIC_SUBNET_ID"

echo "Checking for existing key pair..."
if aws ec2 describe-key-pairs --key-names "$KEY_PAIR_NAME" 2>&1 | grep -q 'does not exist'; then
    echo "Creating new key pair..."
    # Create key pair and save private key
    aws ec2 create-key-pair \
        --key-name "$KEY_PAIR_NAME" \
        --query "KeyMaterial" \
        --output text > "${KEY_PAIR_NAME}.pem"

    # Set correct permissions for private key
    chmod 400 "${KEY_PAIR_NAME}.pem"
    echo "Key pair created successfully"
else
    echo "Key pair $KEY_PAIR_NAME already exists"
    if [ ! -f "${KEY_PAIR_NAME}.pem" ]; then
        echo "Warning: Key pair exists in AWS but .pem file not found locally..."
        echo "    You may want to delete the key pair in AWS and run again to create a new key pair:"
        echo "        - You can do this in the AWS EC2 console"
        echo "        - In the left navigation pane click Key Pairs under Network & Security"
        exit 1
    fi
fi



# Launch EC2 instance with public IP
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id "$AMI_ID" \
    --instance-type "$INSTANCE_TYPE" \
    --key-name "$KEY_PAIR_NAME" \
    --security-group-ids "$PUBLIC_SG_ID" \
    --subnet-id "$PUBLIC_SUBNET_ID" \
    --associate-public-ip-address \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_NAME}]" \
    --query 'Instances[0].InstanceId' \
    --output text)

echo "Waiting for instance to be running..."
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"

# Get public IP address
PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)

echo "                                             "
echo "EC2 instance has been created successfully!!!"
echo "Please secure your .pem file and keys!"
echo "                                             "
echo "Instance ID: $INSTANCE_ID"
echo "Public IP: $PUBLIC_IP"
echo "                                             "
echo "To connect to your instance:"
echo "ssh -i ${KEY_PAIR_NAME}.pem ec2-user@${PUBLIC_IP}"




echo ""
echo "✅ RESULT: EC2 finished! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue..."
echo ""
echo "-------------------------------------------------------------------"


#######################################################################################
# Create EBS on AWS...
echo ""
echo "🛠  ACTION: EBS on AWS...  "
echo ""

# This script creates an EBS volume and attaches it to an existing EC2 instance

#######################################################################################
# Before running the script, make sure to:

    # 1. Replace i-1234567890abcdef0 with your actual EC2 instance ID

    # 2. Adjust the VOLUME_SIZE according to your needs

    # 3. Modify the VOLUME_TYPE if you want a different type of EBS volume [2]

    # 4. Ensure you have AWS CLI installed and configured with appropriate credentials

    # 5. Verify that your IAM user/role has the necessary permissions to create and attach EBS volumes


#######################################################################################
# After the volume is attached, you'll need to:

    # 1. Connect to your EC2 instance

    # 2. Format the volume (if it's new)

    # 3. Create a mount point

    # 4. Mount the volume

    # 5. (Optional) Configure automatic mounting on system restart

#######################################################################################


#######################################################################################
# EBS SCRIPT

# Environment variables that need to be set
EC2_INSTANCE_ID=$INSTANCE_ID  # Replace with your EC2 instance ID
VOLUME_SIZE=30  # Size in GB
VOLUME_TYPE="gp3"  # Volume type (gp3, gp2, io1, etc.)
AVAILABILITY_ZONE="us-east-1a"  # Must be the same AZ as your EC2 instance
DEVICE_NAME="/dev/xvdf"  # Device name for attachment

# Optional performance configurations for gp3 if you need more than baseline
IOPS="3000"  # Default is 3000, can go up to 16000
THROUGHPUT="125"  # Default is 125, can go up to 1000

# Get the availability zone of the instance
INSTANCE_AZ=$(aws ec2 describe-instances \
    --instance-ids $EC2_INSTANCE_ID \
    --query 'Reservations[0].Instances[0].Placement.AvailabilityZone' \
    --output text)

    AVAILABILITY_ZONE=$INSTANCE_AZ

if [ $? -ne 0 ]; then
    echo "Error: Failed to get instance availability zone"
    exit 1
fi


# Create the EBS volume
echo "Creating EBS volume..."
EBS_VOLUME_ID=$(aws ec2 create-volume \
    --size $VOLUME_SIZE \
    --volume-type $VOLUME_TYPE \
    --iops $IOPS \
    --throughput $THROUGHPUT \
    --availability-zone $AVAILABILITY_ZONE \
    --query 'VolumeId' \
    --output text)

if [ $? -ne 0 ]; then
    echo "Error: Failed to create EBS volume"
    exit 1
fi

echo "Volume created: $EBS_VOLUME_ID"

# Wait for volume to become available
echo "Waiting for volume to become available..."
aws ec2 wait volume-available --volume-ids $EBS_VOLUME_ID

# Attach the volume to the EC2 instance
echo "Attaching volume to instance..."
aws ec2 attach-volume \
    --volume-id $EBS_VOLUME_ID \
    --instance-id $EC2_INSTANCE_ID \
    --device $DEVICE_NAME

if [ $? -ne 0 ]; then
    echo "Error: Failed to attach volume"
    exit 1
fi

echo "Volume successfully created and attached to the instance"
echo "Volume ID: $EBS_VOLUME_ID"
echo "Instance ID: $EC2_INSTANCE_ID"
echo "Device Name: $DEVICE_NAME"





echo ""
echo "✅ RESULT: EBS finished! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue..."
echo ""
echo "-------------------------------------------------------------------"



#######################################################################################
# Create RDS on AWS...
echo ""
echo "🛠  ACTION: RDS on AWS...  "
echo ""



# Disable AWS CLI pager
export AWS_PAGER=""

# Exit if any command fails
set -e

# Read from .env file
if [ -f .env/.env.production ]; then
    # Read PG_DB_PASSWORD from .env file
    DB_PASSWORD=$(grep '^PG_DB_PASSWORD=' .env/.env.production | cut -d '=' -f2)
    # Export it for use in the script
    export DB_PASSWORD
else
    echo "Error: .env file not found"
    exit 1
fi

# Validate that DB_PASSWORD was loaded
if [ -z "$DB_PASSWORD" ]; then
    echo "Error: DB_PASSWORD not found in .env file"
    exit 1
fi

# Keep the existing password validation checks
if [ ${#DB_PASSWORD} -lt 8 ] || [ ${#DB_PASSWORD} -gt 41 ]; then
    echo "Error: DB_PASSWORD must be between 8 and 41 characters long"
    exit 1
fi

# Check for whitespace
if echo "$DB_PASSWORD" | grep -q "[[:space:]]"; then
    echo "Error: DB_PASSWORD cannot contain whitespace characters"
    exit 1
fi

#

# Variables
DB_IDENTIFIER="$ARG-$CREATE_DATE-$REPO_VERSION-postgres-db"
SUBNET_GROUP_NAME="$ARG-$CREATE_DATE-$REPO_VERSION-db-subnet-group"



# Verify VPC exists
if [ -z "$VPC_ID" ] || [ "$VPC_ID" = "None" ]; then
    echo "Error: No VPC found"
    exit 1
fi

echo "Using VPC: $VPC_ID"

echo "PRIVATE_SUBNET_ID_1:"
echo $PRIVATE_SUBNET_ID_1
echo "PRIVATE_SUBNET_ID_2:"
echo $PRIVATE_SUBNET_ID_2

# Create DB subnet group
echo "Creating DB subnet group..."
aws rds create-db-subnet-group \
    --db-subnet-group-name "$SUBNET_GROUP_NAME" \
    --db-subnet-group-description "Subnet group for PostgreSQL RDS" \
    --subnet-ids ${PRIVATE_SUBNET_ID_1} ${PRIVATE_SUBNET_ID_2}
    # --subnet-ids '["'${PRIVATE_SUBNET_ID_1}'","'${PRIVATE_SUBNET_ID_2}'"]'
    # --subnet-ids "[\"${PRIVATE_SUBNET_ID_1}\",\"${PRIVATE_SUBNET_ID_2}\"]"





# Create RDS instance
echo "Creating RDS instance..."
aws rds create-db-instance \
    --db-instance-identifier "$DB_IDENTIFIER" \
    --db-instance-class db.t3.micro \
    --engine postgres \
    --engine-version 15.10 \
    --master-username postgres \
    --master-user-password "${DB_PASSWORD}" \
    --allocated-storage 20 \
    --storage-type gp3 \
    --vpc-security-group-ids "$PRIVATE_SG_ID" \
    --db-subnet-group-name "$SUBNET_GROUP_NAME" \
    --no-publicly-accessible \
    --port 5432 \
    --backup-retention-period 7 \
    --no-multi-az \
    --auto-minor-version-upgrade \
    --deletion-protection \
    --storage-encrypted \
    --tags "Key=Name,Value=$DB_IDENTIFIER"

echo "Waiting for RDS instance to be available..."
aws rds wait db-instance-available --db-instance-identifier "$DB_IDENTIFIER"

# Get instance details
INSTANCE_INFO=$(aws rds describe-db-instances \
    --db-instance-identifier "$DB_IDENTIFIER" \
    --query 'DBInstances[0].[Endpoint.Address,Endpoint.Port,DBInstanceStatus]' \
    --output text)

ENDPOINT=$(echo $INSTANCE_INFO | cut -d' ' -f1)
PORT=$(echo $INSTANCE_INFO | cut -d' ' -f2)
STATUS=$(echo $INSTANCE_INFO | cut -d' ' -f3)

echo "----------------------------------------"
echo "RDS Instance Created Successfully!"
echo "Endpoint: $ENDPOINT"
echo "Port: $PORT"
echo "Status: $STATUS"
echo "----------------------------------------"
echo "Connection string format:"
echo "postgresql://postgres:${DB_PASSWORD}@${ENDPOINT}:${PORT}/postgres"
echo "----------------------------------------"
echo "Note: This RDS instance is in private subnets."
echo "To connect, you'll need to be in the VPC (e.g., through a bastion host or VPN)"



echo ""
echo "✅ RESULT: RDS finished! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue..."
echo ""
echo "-------------------------------------------------------------------"

###################################################################################################
echo ""
echo "-------------------------------------------------------------------"
echo "📣 UPDATE: AWS services created! 🙌  "
echo "-------------------------------------------------------------------"
#endregion
#region app information logging and delete script
###################################################################################################
echo ""
echo "-------------------------------------------------------------------"
echo "📣 UPDATE: Collecting app information and creating delete script  "
echo "-------------------------------------------------------------------"



#######################################################################################
# Log AWS infrastctucture...
echo ""
echo "🛠  ACTION: Logging AWS infrastructure and project information...  "
echo ""

cd ../$ADMIEND_REPO_NAME

# Log repository names
update_config "ADMIEND_REPO_NAME" "$ADMIEND_REPO_NAME"
update_config "FRONTEND_REPO_NAME" "$FRONTEND_REPO_NAME"
update_config "BACKEND_REPO_NAME" "$BACKEND_REPO_NAME"
update_config "CREATE_DATE" "$CREATE_DATE"
update_config "REPO_VERSION" "$REPO_VERSION"

# Log AWS Amplify information
update_service_config "amplify" "app_id" "$APP_ID"
update_service_config "amplify" "app_url" "https://${APP_ID}.amplifyapp.com"

# Log S3 information
update_service_config "s3" "bucket_name" "$BUCKET_NAME"
update_service_config "s3" "region" "$AWS_REGION"

# Log EC2 information
update_service_config "ec2" "instance_id" "$EC2_INSTANCE_ID"
update_service_config "ec2" "public_ip" "$EC2_PUBLIC_IP"
update_service_config "ec2" "private_ip" "$EC2_PRIVATE_IP"

# Log EBS information
update_service_config "ebs" "volume_id" "$EBS_VOLUME_ID"
update_service_config "ebs" "volume_size" "$VOLUME_SIZE"
update_service_config "ebs" "volume_type" "$VOLUME_TYPE"
update_service_config "ebs" "device_name" "$DEVICE_NAME"
update_service_config "ebs" "iops" "$IOPS"
update_service_config "ebs" "throughput" "$THROUGHPUT"
update_service_config "ebs" "availability_zone" "$AVAILABILITY_ZONE"
update_service_config "ebs" "attached_instance" "$EC2_INSTANCE_ID"

# Log VPC information
update_service_config "vpc" "vpc_id" "$VPC_ID"
update_service_config "vpc" "subnet_ids" "$SUBNET_IDS"
update_service_config "vpc" "security_group_id" "$SECURITY_GROUP_ID"
update_service_config "vpc" "subnet_group_name" "$SUBNET_GROUP_NAME"

# Log RDS information
update_service_config "rds" "db_identifier" "$DB_IDENTIFIER"
update_service_config "rds" "endpoint" "$RDS_ENDPOINT"
update_service_config "rds" "database_name" "$DB_NAME"
update_service_config "rds" "port" "$DB_PORT"

# Log PostgreSQL database information
update_service_config "postgres" "db_name" "$PG_DB_NAME"
update_service_config "postgres" "db_user" "$PG_DB_USER"
update_service_config "postgres" "db_port" "$PG_DB_PORT"
update_service_config "postgres" "db_host" "$PG_DB_HOST"
update_service_config "postgres" "test_db_name" "$PG_DB_NAME_TEST"


# At the end of your script, you might want to copy this file to your admiend repo
copy_config_to_admiend() {
    if [ -d "$ADMIEND_REPO_NAME" ]; then
        cp "$CONFIG_FILE" "$ADMIEND_REPO_NAME/aws_infrastructure_config.json"
        cd "$ADMIEND_REPO_NAME"
        git add aws_infrastructure_config.json
        git commit -m "Update AWS infrastructure configuration"
        git push
        cd ..
    else
        echo "Error: ADMIEND repository directory not found"
    fi
}





echo ""
echo "✅ RESULT: Logging finished! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue..."
echo ""
echo "-------------------------------------------------------------------"


# #######################################################################################
# # Create app delte script...
# echo ""
# echo "🛠  ACTION: Creating app delete script...  "
# echo ""


# cat > scripts/delete-$APP_PROJECT_DIR_NAME-script.sh << EOL
# #!/bin/bash
# export AWS_PAGER=""
# #######################    NOTE ABOUT APP CLEANUP    ##########################

#                 # WHEN YOU WANT TO DELTE AN APP'S AWS RESOURCES:

#                         # 1. Run the VPC deletion script first (handles all networking/compute)
#                         # 2. Then clean up any non-VPC resources your app uses

#                 # Recourses NOT deleted with the VPC:

#                         # 1. EBS Volumes
#                         # 2. DynamoDB Tables
#                         # 3. IAM Roles/Users/Policies
#                         # 4. Route 53 DNS Records
#                         # 5. CloudFront Distributions
#                         # 6. ECR Repositories
#                         # 7. CloudWatch Logs
#                         # 8. Lambda Functions (unless VPC-connected)
#                         # 9. Certificates (ACM)
#                         # 10. Amplify Applications
#                         # 11. S3 Buckets
#                         # 12. Local Postrgres
#                         # 13. Github Repos
#                         # 14. Local Files


# #######################    DELETE SCRIPT CONFIRMATION   ######################
# echo " "
# echo "-------------------------------------------------------------------"
# echo "⚠️ ACHTUNG: THIS SCRIPT WILL DELETE THE ENTIRE APP INCLUDING AWS SERVICES, GH REPOS, AND LOCAL FILES!!!!!!! ⚠️"
# echo "-------------------------------------------------------------------"
# echo " "
# echo "🚽  LOO FLUSH: This script attempts to delete everything in sequence..."
# echo "💥  DATA LOSS: You will LOSE DATA that is associated with this app..."
# echo " "
# echo "-------------------------------------------------------------------"


# # Prompt to user to continue
# echo ""
# read -p "💣 CONFIRM: Are you sure you want to proceed with app deletion? (y/n): " user_input

# # Check the user's response
# if [[ "$user_input" =~ ^[Yy]$ ]]; then

# #######################    DELETE VPC START    ###############################
# echo ""
# echo "🛠  ACTION: Deleting VPC... "
# echo ""


# # List of VPCs to delete
# VPC_LIST=(
#     "$vpc_id"
# # Add more VPC IDs as needed
# )

# delete_vpc() {
#     local vpc_id=$1
#     echo "Processing VPC: $vpc_id"

#     # Check if VPC exists
#     vpc_state=$(aws ec2 describe-vpcs \
#         --vpc-ids "$vpc_id" \
#         --query 'Vpcs[0].State' \
#         --output text 2>/dev/null) || {
#         echo "  VPC does not exist: $vpc_id"
#         echo "----------------------------------------"
#         return 1
#     }

#     # Function to wait for RDS instance deletion
#     wait_for_rds_deletion() {
#         local db_identifier=$1
#         local start_time=$(date +%s)
#         echo "Waiting for RDS instance $db_identifier to be deleted..."
#         echo "This could take 5-30 minutes depending on the instance size."

#         while aws rds describe-db-instances --db-instance-identifier "$db_identifier" 2>/dev/null; do
#             local current_time=$(date +%s)
#             local elapsed_time=$((current_time - start_time))
#             local minutes=$((elapsed_time / 60))
#             local seconds=$((elapsed_time % 60))
#             echo "Still waiting... Time elapsed: ${minutes}m ${seconds}s"
#             sleep 30
#         done

#         local total_time=$(($(date +%s) - start_time))
#         local total_minutes=$((total_time / 60))
#         local total_seconds=$((total_time % 60))
#         echo "RDS instance deleted. Total time: ${total_minutes}m ${total_seconds}s"
#     }

#     # Delete RDS instances
#     echo "  Checking for RDS instances..."
#     RDS_INSTANCES=$(aws rds describe-db-instances \
#         --query "DBInstances[?DBSubnetGroup.VpcId=='${vpc_id}'].DBInstanceIdentifier" \
#         --output text)

#     if [ ! -z "$RDS_INSTANCES" ] && [ "$RDS_INSTANCES" != "None" ]; then
#         for db in $RDS_INSTANCES; do
#             echo "  Processing RDS instance: $db"

#             # Disable deletion protection
#             echo "  Disabling deletion protection for RDS instance: $db"
#             aws rds modify-db-instance \
#                 --db-instance-identifier "$db" \
#                 --no-deletion-protection \
#                 --apply-immediately

#             # Wait for the modification to complete
#             echo "  Waiting for modification to complete..."
#             aws rds wait db-instance-available --db-instance-identifier "$db"

#             # Delete the instance
#             echo "  Now deleting RDS instance: $db"
#             aws rds delete-db-instance \
#                 --db-instance-identifier "$db" \
#                 --skip-final-snapshot \
#                 --delete-automated-backups

#             # Wait for deletion to complete
#             wait_for_rds_deletion "$db"
#         done
#     else
#         echo "  No RDS instances found in VPC"
#     fi

#     # Terminate EC2 instances
#     echo "  Checking for and terminating EC2 instances..."
#     instance_ids=$(aws ec2 describe-instances \
#         --filters "Name=vpc-id,Values=$vpc_id" \
#         --query 'Reservations[].Instances[].InstanceId' \
#         --output text)

#     if [ ! -z "$instance_ids" ] && [ "$instance_ids" != "None" ]; then
#         echo "  Terminating instances: $instance_ids"
#         aws ec2 terminate-instances --instance-ids $instance_ids
#         echo "  Waiting for instances to terminate..."
#         aws ec2 wait instance-terminated --instance-ids $instance_ids
#     fi

#     # Delete NAT Gateways
#     echo "  Checking for NAT Gateways..."
#     nat_gateway_ids=$(aws ec2 describe-nat-gateways \
#         --filter "Name=vpc-id,Values=$vpc_id" \
#         --query 'NatGateways[].NatGatewayId' \
#         --output text)

#     if [ ! -z "$nat_gateway_ids" ] && [ "$nat_gateway_ids" != "None" ]; then
#         for nat_id in $nat_gateway_ids; do
#             echo "  Deleting NAT Gateway: $nat_id"
#             aws ec2 delete-nat-gateway --nat-gateway-id $nat_id
#         done
#         echo "  Waiting for NAT Gateways to delete (30 seconds)..."
#         sleep 30
#     fi

#     # Delete VPC Endpoints
#     echo "  Checking for VPC Endpoints..."
#     vpc_endpoint_ids=$(aws ec2 describe-vpc-endpoints \
#         --filters "Name=vpc-id,Values=$vpc_id" \
#         --query 'VpcEndpoints[].VpcEndpointId' \
#         --output text)

#     if [ ! -z "$vpc_endpoint_ids" ] && [ "$vpc_endpoint_ids" != "None" ]; then
#         echo "  Deleting VPC Endpoints: $vpc_endpoint_ids"
#         aws ec2 delete-vpc-endpoints --vpc-endpoint-ids $vpc_endpoint_ids
#         echo "  Waiting for VPC Endpoints to delete (30 seconds)..."
#         sleep 30
#     fi

#     # Check for and delete Internet Gateway
#     echo "  Checking for Internet Gateway..."
#     igw_id=$(aws ec2 describe-internet-gateways \
#         --filters "Name=attachment.vpc-id,Values=$vpc_id" \
#         --query 'InternetGateways[].InternetGatewayId' \
#         --output text)

#     if [ ! -z "$igw_id" ] && [ "$igw_id" != "None" ]; then
#         echo "  Detaching and deleting Internet Gateway: $igw_id"
#         aws ec2 detach-internet-gateway --internet-gateway-id "$igw_id" --vpc-id "$vpc_id"
#         aws ec2 delete-internet-gateway --internet-gateway-id "$igw_id"
#     fi

#     # Wait for NAT Gateways to be deleted (they take time)
#     if [ ! -z "$nat_gateway_ids" ]; then
#         echo "Waiting for NAT Gateways to be deleted..."
#         sleep 60  # NAT Gateways take time to delete
#     fi

#     # Check for and delete Network Interfaces
#     echo "  Checking for Network Interfaces..."
#     eni_ids=$(aws ec2 describe-network-interfaces \
#         --filters "Name=vpc-id,Values=$vpc_id" \
#         --query 'NetworkInterfaces[].NetworkInterfaceId' \
#         --output text)

#     for eni_id in $eni_ids; do
#         if [ ! -z "$eni_id" ] && [ "$eni_id" != "None" ]; then
#             echo "    Processing ENI: $eni_id"

#             # Get detailed ENI information
#             eni_info=$(aws ec2 describe-network-interfaces \
#                 --network-interface-ids "$eni_id" \
#                 --query 'NetworkInterfaces[0].[Description,Status,Attachment.AttachmentId]' \
#                 --output text)

#             description=$(echo "$eni_info" | cut -f1)
#             status=$(echo "$eni_info" | cut -f2)
#             attachment_id=$(echo "$eni_info" | cut -f3)

#             echo "    Description: $description"
#             echo "    Status: $status"

#             if [ ! -z "$attachment_id" ] && [ "$attachment_id" != "None" ]; then
#                 echo "    Attempting to detach ENI..."
#                 aws ec2 detach-network-interface --attachment-id "$attachment_id" --force || \
#                 echo "    Warning: Could not detach ENI"
#                 sleep 10
#             fi

#             echo "    Attempting to delete ENI..."
#             aws ec2 delete-network-interface --network-interface-id "$eni_id" || \
#             echo "    Warning: Could not delete ENI. It may be managed by another service."
#         fi
#     done


#     # Get all security group IDs for the VPC
#     echo "Getting security groups for VPC $VPC_ID..."
#     SECURITY_GROUP_IDS=$(aws ec2 describe-security-groups \
#         --filters "Name=vpc-id,Values=$VPC_ID" \
#         --query 'SecurityGroups[].GroupId' \
#         --output text)

#     if [ -z "$SECURITY_GROUP_IDS" ]; then
#         echo "No security groups found for VPC $VPC_ID"
#     else
#         echo "Found security groups: $SECURITY_GROUP_IDS"

#         # Process each security group
#         for sg_id in $SECURITY_GROUP_IDS; do
#             # Check if this is the default security group
#             SG_NAME=$(aws ec2 describe-security-groups --group-ids $sg_id --query 'SecurityGroups[0].GroupName' --output text)

#             if [ "$SG_NAME" = "default" ]; then
#                 echo "Skipping default security group: $sg_id (This will be deleted automatically with the VPC)"
#                 continue
#             fi

#             echo "Checking dependencies for Security Group: $sg_id"

#             # Remove all inbound rules
#             echo "Removing inbound rules for $sg_id"
#             aws ec2 describe-security-group-rules \
#                 --filters Name=group-id,Values=$sg_id Name=is-egress,Values=false \
#                 --query 'SecurityGroupRules[].SecurityGroupRuleId' \
#                 --output text | tr '\t' '\n' | while read rule_id; do
#                 if [ ! -z "$rule_id" ]; then
#                     aws ec2 revoke-security-group-rules \
#                         --group-id $sg_id \
#                         --security-group-rule-ids $rule_id
#                 fi
#             done

#             # Remove all outbound rules
#             echo "Removing outbound rules for $sg_id"
#             aws ec2 describe-security-group-rules \
#                 --filters Name=group-id,Values=$sg_id Name=is-egress,Values=true \
#                 --query 'SecurityGroupRules[].SecurityGroupRuleId' \
#                 --output text | tr '\t' '\n' | while read rule_id; do
#                 if [ ! -z "$rule_id" ]; then
#                     aws ec2 revoke-security-group-rules \
#                         --group-id $sg_id \
#                         --security-group-rule-ids $rule_id
#                 fi
#             done

#             # Try to delete the non-default security group
#             echo "Attempting to delete security group: $sg_id"
#             if aws ec2 delete-security-group --group-id $sg_id; then
#                 echo "Successfully deleted security group: $sg_id"
#             else
#                 echo "Failed to delete security group: $sg_id"
#                 echo "Checking what's still referencing this security group..."

#                 # Check for ENIs using this security group
#                 aws ec2 describe-network-interfaces \
#                     --filters "Name=group-id,Values=$sg_id" \
#                     --query 'NetworkInterfaces[].[NetworkInterfaceId,Description]' \
#                     --output table
#             fi
#         done
#     fi


#     # Delete non-default security groups
#     echo "  Checking for Security Groups..."
#     sg_ids=$(aws ec2 describe-security-groups \
#         --filters "Name=vpc-id,Values=$vpc_id" \
#         --query 'SecurityGroups[?GroupName!=`default`].GroupId' \
#         --output text)

#     for sg_id in $sg_ids; do
#         if [ ! -z "$sg_id" ] && [ "$sg_id" != "None" ]; then
#             echo "  Processing Security Group: $sg_id"
#             aws ec2 delete-security-group --group-id "$sg_id" || \
#             echo "  Warning: Could not delete Security Group"
#         fi
#     done

#     # Delete Subnets
#     echo "  Checking for Subnets..."
#     subnet_ids=$(aws ec2 describe-subnets \
#         --filters "Name=vpc-id,Values=$vpc_id" \
#         --query 'Subnets[].SubnetId' \
#         --output text)

#     for subnet_id in $subnet_ids; do
#         if [ ! -z "$subnet_id" ] && [ "$subnet_id" != "None" ]; then
#             echo "  Deleting Subnet: $subnet_id"
#             aws ec2 delete-subnet --subnet-id "$subnet_id" || \
#             echo "  Warning: Could not delete Subnet"
#         fi
#     done

#     # Delete Route Tables
#     echo "  Checking for Route Tables..."
#     rt_ids=$(aws ec2 describe-route-tables \
#         --filters "Name=vpc-id,Values=$vpc_id" \
#         --query 'RouteTables[?Associations[0].Main!=`true`].RouteTableId' \
#         --output text)

#     for rt_id in $rt_ids; do
#         if [ ! -z "$rt_id" ] && [ "$rt_id" != "None" ]; then
#             echo "  Deleting Route Table: $rt_id"
#             aws ec2 delete-route-table --route-table-id "$rt_id" || \
#             echo "  Warning: Could not delete Route Table"
#         fi
#     done

#     # Final wait before VPC deletion
#     echo "  Waiting for all deletions to complete..."
#     sleep 30

#     # Try to delete the VPC
#     echo "  Attempting to delete VPC..."
#     if aws ec2 delete-vpc --vpc-id "$vpc_id"; then
#         echo "  Successfully deleted VPC: $vpc_id"
#     else
#         echo "  Failed to delete VPC: $vpc_id"
#         echo "  Checking for remaining dependencies..."

#         # List remaining ENIs
#         remaining_enis=$(aws ec2 describe-network-interfaces \
#             --filters "Name=vpc-id,Values=$vpc_id" \
#             --query 'NetworkInterfaces[].NetworkInterfaceId' \
#             --output text)

#         if [ ! -z "$remaining_enis" ]; then
#             echo "  Found remaining ENIs: $remaining_enis"
#         fi

#         # List any remaining security groups
#         remaining_sgs=$(aws ec2 describe-security-groups \
#             --filters "Name=vpc-id,Values=$vpc_id" \
#             --query 'SecurityGroups[].GroupId' \
#             --output text)

#         if [ ! -z "$remaining_sgs" ]; then
#             echo "  Found remaining Security Groups: $remaining_sgs"
#         fi
#     fi
#     echo "----------------------------------------"
# }

# # Main execution
# echo "Starting VPC deletion process..."
# echo "Found ${#VPC_LIST[@]} VPCs to process"

# read -p "Do you want to proceed with deletion of these VPCs? (y/n): " confirm
# if [[ ! $confirm =~ ^[Yy]$ ]]; then
#     echo "Operation cancelled"
#     exit 0
# fi

# # Process each VPC in the list
# for vpc_id in "${VPC_LIST[@]}"; do
#     delete_vpc "$vpc_id"
# done

# echo "VPC deletion process completed"





# echo ""
# echo "✅ RESULT: VPC delete process finished! "
# echo ""
# read -p "⏸️  PAUSE: Press Enter to continue... "
# echo ""
# echo "-------------------------------------------------------------------"
# #######################    DELETE VPC END    ###############################
# #######################    DELETE SUBNETS START   ###############################
# echo ""
# echo "🛠  ACTION: Deleting Subnets... "
# echo ""



# # Array of subnet group names - change them to suit your needs
# SUBNET_GROUPS=(
# "$SUBNET_GROUP_NAME"
# )

# # Function to delete an RDS subnet group
# delete_subnet_group() {
#     local subnet_group_name=$1
#     echo "Processing subnet group: $subnet_group_name"

#     # Check if subnet group exists
#     if ! aws rds describe-db-subnet-groups \
#         --db-subnet-group-name "$subnet_group_name" \
#         --query 'DBSubnetGroups[0].DBSubnetGroupName' \
#         --output text 2>/dev/null; then
#         echo "  Subnet group does not exist: $subnet_group_name"
#         echo "----------------------------------------"
#         return 1
#     fi

#     # Check if subnet group is in use by any RDS instances
#     if db_instances=$(aws rds describe-db-instances \
#         --query "DBInstances[?DBSubnetGroup.DBSubnetGroupName=='${subnet_group_name}'].DBInstanceIdentifier" \
#         --output text); then
#         if [ ! -z "$db_instances" ]; then
#             echo "  Warning: Subnet group $subnet_group_name is currently used by these instances:"
#             echo "  $db_instances"
#             read -p "  Cannot delete subnet group while in use. Press Enter to continue..."
#             echo "----------------------------------------"
#             return 1
#         fi
#     fi

#     # Delete the subnet group
#     echo "  Deleting subnet group..."
#     if aws rds delete-db-subnet-group \
#         --db-subnet-group-name "$subnet_group_name"; then
#         echo "  Successfully deleted subnet group: $subnet_group_name"

#         # Verify deletion
#         echo "  Verifying deletion..."
#         if ! aws rds describe-db-subnet-groups \
#             --db-subnet-group-name "$subnet_group_name" \
#             >/dev/null 2>&1; then
#             echo "  Deletion verified for subnet group: $subnet_group_name"
#         else
#             echo "  Warning: Subnet group may still exist: $subnet_group_name"
#         fi
#     else
#         echo "  Failed to delete subnet group: $subnet_group_name"
#     fi
#     echo "----------------------------------------"
# }

# # Main execution
# echo "Starting RDS subnet group deletion process..."
# echo "----------------------------------------"

# # Check if subnet groups array is empty
# if [ ${#SUBNET_GROUPS[@]} -eq 0 ]; then
#     echo "No subnet groups specified for deletion"
#     exit 1
# fi

# # Confirm deletion
# echo "The following RDS subnet groups will be deleted:"
# printf '%s\n' "${SUBNET_GROUPS[@]}"
# read -p "Are you sure you want to proceed? (y/n): " confirm

# if [[ $confirm == [Yy]* ]]; then
#     for subnet_group in "${SUBNET_GROUPS[@]}"; do
#         delete_subnet_group "$subnet_group"
#     done
#     echo "Subnet group deletion process complete!"
# else
#     echo "Operation cancelled"
# fi



# echo ""
# echo "✅ RESULT: Subnet delete process finished! "
# echo ""
# read -p "⏸️  PAUSE: Press Enter to continue... "
# echo ""
# echo "-------------------------------------------------------------------"
# #######################    DELETE SUBNETS END    ###############################
# #######################    DELETE RDS START    ###############################
# echo ""
# echo "🛠  ACTION: Deleting RDS... "
# echo ""




# # Array of RDS instance identifiers - change them to suit your needs
# RDS_INSTANCES=(
# "$DB_IDENTIFIER"
# )

# # Function to delete an RDS instance
# delete_rds() {
#     local db_identifier=$1
#     echo "Processing RDS instance: $db_identifier"

#     # Check if instance exists and get its status
#     db_status=$(aws rds describe-db-instances \
#         --db-instance-identifier "$db_identifier" \
#         --query 'DBInstances[0].DBInstanceStatus' \
#         --output text 2>/dev/null) || {
#         echo "  RDS instance does not exist: $db_identifier"
#         echo "----------------------------------------"
#         return 1
#     }

#     # Check if instance has deletion protection enabled
#     deletion_protection=$(aws rds describe-db-instances \
#         --db-instance-identifier "$db_identifier" \
#         --query 'DBInstances[0].DeletionProtection' \
#         --output text)

#     if [ "$deletion_protection" == "true" ]; then
#         echo "  Warning: Deletion protection is enabled for $db_identifier"
#         read -p "  Do you want to disable deletion protection? (y/n): " disable_protection
#         if [[ $disable_protection == [Yy]* ]]; then
#             echo "  Disabling deletion protection..."
#             aws rds modify-db-instance \
#                 --db-instance-identifier "$db_identifier" \
#                 --no-deletion-protection \
#                 --apply-immediately

#             echo "  Waiting for modification to complete..."
#             aws rds wait db-instance-available --db-instance-identifier "$db_identifier"
#         else
#             echo "  Skipping instance deletion"
#             echo "----------------------------------------"
#             return 1
#         fi
#     fi

#     # Prompt for final snapshot
#     read -p "  Do you want to create a final snapshot? (y/n): " create_snapshot
#     if [[ $create_snapshot == [Yy]* ]]; then
#         snapshot_identifier="${db_identifier}-final-$(date +%Y%m%d-%H%M%S)"
#         echo "  Creating final snapshot: $snapshot_identifier"

#         aws rds delete-db-instance \
#             --db-instance-identifier "$db_identifier" \
#             --final-db-snapshot-identifier "$snapshot_identifier"
#     else
#         echo "  Proceeding without final snapshot..."
#         aws rds delete-db-instance \
#             --db-instance-identifier "$db_identifier" \
#             --skip-final-snapshot
#     fi

#     # Wait for deletion to complete
#     echo "  Waiting for instance deletion to complete..."
#     if aws rds wait db-instance-deleted --db-instance-identifier "$db_identifier"; then
#         echo "  Successfully deleted RDS instance: $db_identifier"
#     else
#         echo "  Failed to verify deletion of RDS instance: $db_identifier"
#     fi
#     echo "----------------------------------------"
# }

# # Main execution
# echo "Starting RDS instance deletion process..."
# echo "----------------------------------------"

# # Check if instances array is empty
# if [ ${#RDS_INSTANCES[@]} -eq 0 ]; then
#     echo "No RDS instances specified for deletion"
#     exit 1
# fi

# # Confirm deletion
# echo "The following RDS instances will be deleted:"
# printf '%s\n' "${RDS_INSTANCES[@]}"
# echo "WARNING: This action cannot be undone if you choose to skip final snapshots!"
# read -p "Are you sure you want to proceed? (y/n): " confirm

# if [[ $confirm == [Yy]* ]]; then
#     for instance in "${RDS_INSTANCES[@]}"; do
#         delete_rds "$instance"
#     done
#     echo "RDS instance deletion process complete!"
# else
#     echo "Operation cancelled"
# fi



# echo ""
# echo "✅ RESULT: RDS delete process finished! "
# echo ""
# read -p "⏸️  PAUSE: Press Enter to continue... "
# echo ""
# echo "-------------------------------------------------------------------"

# #######################    DELETE RDS END    #################################
# #######################    DELETE EC2 START    ###############################
# echo ""
# echo "🛠  ACTION: Deleting EC2... "
# echo ""




# # Array of EC2 instance IDs - change them to suit your needs
# INSTANCES=(
#     # !Replace with your instance IDs
# "$EC2_INSTANCE_ID"

# )

# # Function to delete an EC2 instance
# delete_instance() {
#     local instance_id=$1
#     echo "Processing EC2 instance: $instance_id"

#     # Check if instance exists by trying to get its details
#     if aws ec2 describe-instances --instance-ids "$instance_id" &>/dev/null; then
#         echo "  Instance exists, checking state..."

#         # Get instance state
#         instance_state=$(aws ec2 describe-instances \
#             --instance-ids "$instance_id" \
#             --query 'Reservations[].Instances[].State.Name' \
#             --output text)

#         echo "  Current instance state: $instance_state"

#         # If instance is running or stopped, terminate it
#         if [ "$instance_state" != "terminated" ]; then
#             echo "  Terminating instance..."

#             # Check if instance has termination protection
#             termination_protection=$(aws ec2 describe-instance-attribute \
#                 --instance-id "$instance_id" \
#                 --attribute disableApiTermination \
#                 --query 'DisableApiTermination.Value' \
#                 --output text)

#             if [ "$termination_protection" == "true" ]; then
#                 echo "  Disabling termination protection..."
#                 aws ec2 modify-instance-attribute \
#                     --instance-id "$instance_id" \
#                     --no-disable-api-termination
#             fi

#             # Terminate the instance
#             aws ec2 terminate-instances --instance-ids "$instance_id"

#             echo "  Waiting for instance termination..."
#             aws ec2 wait instance-terminated --instance-ids "$instance_id"

#             if [ $? -eq 0 ]; then
#                 echo "  Successfully terminated instance: $instance_id"
#             else
#                 echo "  Failed to terminate instance: $instance_id"
#             fi
#         else
#             echo "  Instance is already terminated"
#         fi
#     else
#         echo "  Instance does not exist: $instance_id"
#     fi
#     echo "----------------------------------------"
# }

# # Main execution
# echo "Starting EC2 instance termination process..."
# echo "----------------------------------------"

# # Get instance names for confirmation
# echo "The following instances will be terminated:"
# for instance in "${INSTANCES[@]}"; do
#     name=$(aws ec2 describe-tags \
#         --filters "Name=resource-id,Values=$instance" "Name=key,Values=Name" \
#         --query 'Tags[].Value' \
#         --output text)
#     echo "Instance ID: $instance (Name: ${name:-No name tag})"
# done

# # Ask for confirmation
# read -p "Are you sure you want to terminate these instances? (y/n): " confirm
# if [[ $confirm != [Yy]* ]]; then
#     echo "Operation cancelled"
#     exit 1
# fi

# # Process each instance
# for instance in "${INSTANCES[@]}"; do
#     delete_instance "$instance"
# done

# echo "Instance termination process complete!"
# echo "--------------------------------------"
# echo "                                         "
# echo "PLEASE DELETE ANY ASSOCIATED KEY PAIRS AND SECURITY GROUPS!!!"
# echo "                                         "
# echo "Look in AWS EC2 Console at left under Network & Security you can find them."
# echo "Also delete associated .pem files."


# echo ""
# echo "✅ RESULT: EC2 delete process finished! "
# echo ""
# read -p "⏸️  PAUSE: Press Enter to continue... "
# echo ""
# echo "-------------------------------------------------------------------"
# #######################    DELETE EC2 END    #################################
# #######################    DELETE EBS START    ###############################
# echo ""
# echo "🛠  ACTION: Deleting EBS... "
# echo ""



# # Array of volume IDs - change them to suit your needs
# VOLUMES=(
# "$EBS_VOLUME_ID"
# )

# # Function to delete an EBS volume
# delete_volume() {
#     local volume_id=$1
#     echo "Processing volume: $volume_id"

#     # Check if volume exists and get its state
#     volume_state=$(aws ec2 describe-volumes \
#         --volume-ids "$volume_id" \
#         --query 'Volumes[0].State' \
#         --output text 2>/dev/null) || {
#         echo "  Volume does not exist: $volume_id"
#         echo "----------------------------------------"
#         return 1
#     }

#     # Check if volume is in-use
#     if [ "$volume_state" == "in-use" ]; then
#         echo "  Warning: Volume $volume_id is currently attached to an instance"
#         read -p "  Do you want to force detach and delete this volume? (y/n): " force_delete
#         if [[ $force_delete == [Yy]* ]]; then
#             echo "  Detaching volume..."
#             aws ec2 detach-volume --volume-id "$volume_id" --force

#             # Wait for volume to become available
#             echo "  Waiting for volume to detach..."
#             aws ec2 wait volume-available --volume-ids "$volume_id"
#         else
#             echo "  Skipping volume deletion"
#             echo "----------------------------------------"
#             return 1
#         fi
#     fi

#     # Delete the volume
#     echo "  Deleting volume..."
#     if aws ec2 delete-volume --volume-id "$volume_id"; then
#         echo "  Successfully deleted volume: $volume_id"

#         # Wait to confirm deletion
#         echo "  Verifying deletion..."
#         if aws ec2 wait volume-deleted --volume-ids "$volume_id" 2>/dev/null; then
#             echo "  Deletion verified for volume: $volume_id"
#         fi
#     else
#         echo "  Failed to delete volume: $volume_id"
#     fi
#     echo "----------------------------------------"
# }

# # Main execution
# echo "Starting volume deletion process..."
# echo "----------------------------------------"

# # Check if volumes array is empty
# if [ ${#VOLUMES[@]} -eq 0 ]; then
#     echo "No volumes specified for deletion"
#     exit 1
# fi

# # Confirm deletion
# echo "The following volumes will be deleted:"
# printf '%s\n' "${VOLUMES[@]}"
# read -p "Are you sure you want to proceed? (y/n): " confirm

# if [[ $confirm == [Yy]* ]]; then
#     for volume in "${VOLUMES[@]}"; do
#         delete_volume "$volume"
#     done
#     echo "Volume deletion process complete!"
# else
#     echo "Operation cancelled"
# fi



# echo ""
# echo "✅ RESULT: EBS delete process finished! "
# echo ""
# read -p "⏸️  PAUSE: Press Enter to continue... "
# echo ""
# echo "-------------------------------------------------------------------"
# #######################    DELETE EBS END    ###############################
# #######################    DELETE S3 START    ###############################
# echo ""
# echo "🛠  ACTION: Deleting S3... "
# echo ""



# # Array of bucket names
# BUCKETS=(
# "$BUCKET_NAME"
# )

# delete_bucket_contents() {
#     local bucket="$1"
#     local batch_count=0
#     local max_attempts=50  # Maximum number of deletion attempts

#     echo "Emptying bucket: $bucket"

#     # First remove current objects
#     echo "Removing current objects..."
#     aws s3 rm "s3://$bucket" --recursive

#     # Then handle versions and delete markers
#     while [ $batch_count -lt $max_attempts ]; do
#         ((batch_count++))
#         echo "Deletion attempt $batch_count of $max_attempts"

#         # Get versions and delete markers
#         versions=$(aws s3api list-object-versions \
#             --bucket "$bucket" \
#             --max-items 1000 \
#             --output json 2>/dev/null)

#         # Check if we got any data
#         if [ -z "$versions" ] || [ "$versions" = "null" ]; then
#             echo "No more objects found"
#             return 0
#         fi

#         # Create delete JSON
#         tmp_file=$(mktemp)
#         echo "$versions" | jq -r '{
#             Objects: ([.Versions[]?, .DeleteMarkers[]?] | map({Key: .Key, VersionId: .VersionId})),
#             Quiet: true
#         }' > "$tmp_file"

#         # Check if we have objects to delete
#         object_count=$(jq -r '.Objects | length' "$tmp_file")
#         if [ -z "$object_count" ] || [ "$object_count" = "null" ] || [ "$object_count" = "0" ]; then
#             rm -f "$tmp_file"
#             echo "No more objects to delete"
#             return 0
#         fi

#         echo "Deleting batch of $object_count objects (attempt $batch_count)..."

#         # Delete objects
#         if aws s3api delete-objects \
#             --bucket "$bucket" \
#             --delete "file://$tmp_file" > /dev/null; then
#             echo "Successfully deleted batch $batch_count"
#         else
#             echo "Error deleting batch $batch_count"
#             rm -f "$tmp_file"
#             return 1
#         fi

#         rm -f "$tmp_file"
#         sleep 2  # Increased delay between batches
#     done

#     echo "Warning: Reached maximum deletion attempts ($max_attempts)"
#     return 1
# }

# delete_bucket() {
#     local bucket="$1"
#     echo "Processing bucket: $bucket"
#     echo "----------------------------------------"

#     # Check if bucket exists
#     if ! aws s3api head-bucket --bucket "$bucket" 2>/dev/null; then
#         echo "Bucket does not exist or no access: $bucket"
#         return 1
#     fi

#     # Empty the bucket
#     if ! delete_bucket_contents "$bucket"; then
#         echo "Failed to empty bucket: $bucket"
#         return 1
#     fi

#     # Verify bucket is empty
#     echo "Verifying bucket is empty..."
#     if aws s3api list-object-versions --bucket "$bucket" --max-items 1 &>/dev/null; then
#         versions_count=$(aws s3api list-object-versions --bucket "$bucket" --output json | jq -r '.Versions | length')
#         if [ "$versions_count" != "null" ] && [ "$versions_count" != "0" ]; then
#             echo "Bucket still contains objects after deletion attempts"
#             return 1
#         fi
#     fi

#     # Delete the bucket
#     echo "Deleting bucket: $bucket"
#     if aws s3api delete-bucket --bucket "$bucket"; then
#         echo "Successfully deleted bucket: $bucket"
#         return 0
#     else
#         echo "Failed to delete bucket: $bucket"
#         return 1
#     fi
# }

# # Main script
# echo "Starting bucket deletion process..."
# echo "Found ${#BUCKETS[@]} buckets to process"
# echo "----------------------------------------"

# # Print list of buckets
# echo "Buckets to be deleted:"
# for bucket in "${BUCKETS[@]}"; do
#     echo "- $bucket"
# done
# echo "----------------------------------------"

# # Confirm before proceeding
# read -p "Continue with deletion? (y/n): " confirm
# if [[ ! $confirm =~ ^[Yy]$ ]]; then
#     echo "Operation cancelled"
#     exit 0
# fi

# # Process buckets
# success=0
# failed=0

# for bucket in "${BUCKETS[@]}"; do
#     if delete_bucket "$bucket"; then
#         ((success++))
#     else
#         ((failed++))
#     fi
#     echo "----------------------------------------"
# done

# # Summary
# echo "Deletion process complete!"
# echo "Summary:"
# echo "- Successfully deleted: $success buckets"
# echo "- Failed to delete: $failed buckets"
# echo "----------------------------------------"

# if [ $failed -gt 0 ]; then
#     exit 1
# fi




# echo ""
# echo "✅ RESULT: S3 delete process finished! "
# echo ""
# read -p "⏸️  PAUSE: Press Enter to continue... "
# echo ""
# echo "-------------------------------------------------------------------"
# #######################    DELETE S3 END    ###############################
# #######################    DELETE AMPLIFY START    ###############################
# echo ""
# echo "🛠  ACTION: Deleting Amplify... "
# echo ""



# # Array of Amplify app IDs - change them to suit your needs
# APPS=(
# "$APP_ID"
# )

# # Function to delete an Amplify app
# delete_app() {
#     local app_id=$1
#     echo "Processing Amplify app: $app_id"

#     # Check if app exists by trying to get its details
#     if aws amplify get-app --app-id "$app_id" &>/dev/null; then
#         echo "  Deleting app..."
#         aws amplify delete-app --app-id "$app_id"

#         if [ $? -eq 0 ]; then
#             echo "Successfully deleted app: $app_id"
#         else
#             echo "Failed to delete app: $app_id"
#         fi
#     else
#         echo "App does not exist: $app_id"
#     fi
#     echo "----------------------------------------"
# }

# # Main execution
# echo "Starting Amplify app deletion process..."
# echo "----------------------------------------"

# for app in "${APPS[@]}"; do
#     delete_app "$app"
# done

# echo "App deletion process complete!"



# echo ""
# echo "✅ RESULT: Amplify delete process finished! "
# echo ""
# read -p "⏸️  PAUSE: Press Enter to continue... "
# echo ""
# echo "-------------------------------------------------------------------"
# #######################    DELETE AMPLIFY END    ###############################
# #######################    DELETE LOCAL POSTGRES START    ####################
# echo ""
# echo "🛠  ACTION: Deleting local Postgres... "
# echo ""



# # Database connection parameters - these should be set as environment variables
# DB_HOST=${PGHOST:-"localhost"}
# DB_PORT=${PGPORT:-"5432"}
# DB_USER=${PGUSER:-"postgres"}
# DB_PASSWORD=${PGPASSWORD:-""}

# # Array of database names to delete
# DATABASES=(
#     # BE SURE TO REPLACE THESE WITH THE NAMES YOU WANT TO DELETE
#     # ALSO BE SURE YOU HAVE AT LEAST ONE NAME IN HERE OR IT MIGHT BE DANGEROUS
#     # YOU DON'T NEED THESE TO BE ENCLOSED IN QUOTES
# "$PG_DB_NAME"
# )

# # Function to delete a PostgreSQL database
# delete_database() {
#     local db_name=$1
#     echo "Processing database: $db_name"

#     # Export password for all psql commands
#     export PGPASSWORD="$DB_PASSWORD"

#     # Check if database exists
#     if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -lqt | cut -d \| -f 1 | grep -qw "$db_name"; then
#         echo "  Database exists. Proceeding with deletion..."

#         # Check if database is being accessed
#         local connections=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -t -c \
#             "SELECT count(*) FROM pg_stat_activity WHERE datname = '$db_name';")

#         if [ "$connections" -gt "0" ]; then
#             echo "  Warning: Database has active connections. Forcing disconnection..."
#             # Force disconnect all users
#             psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -c \
#                 "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$db_name';" &>/dev/null
#         fi

#         # Delete the database
#         if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -c "DROP DATABASE \"$db_name\";" &>/dev/null; then
#             echo "  Successfully deleted database: $db_name"
#         else
#             echo "  Failed to delete database: $db_name"
#         fi
#     else
#         echo "  Database does not exist: $db_name"
#     fi
#     echo "----------------------------------------"
# }


# # Main execution
# echo "Starting PostgreSQL database deletion process..."
# echo "----------------------------------------"

# # Verify psql is installed
# if ! command -v psql &>/dev/null; then
#     echo "Error: psql is not installed. Please install it first."
#     exit 1
# fi

# # Test database connection
# if ! psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -c "SELECT 1;" &>/dev/null; then
#     echo "Error: Cannot connect to PostgreSQL. Please check your credentials and connection."
#     exit 1
# fi


# # Display all databases that will be deleted
# echo "The following databases will be deleted:"
# for db in "${DATABASES[@]}"; do
#     echo "  - $db"
# done
# echo "----------------------------------------"

# # Single confirmation prompt
# read -p "Are you sure you want to delete these databases? (y/n): " confirm
# if [[ $confirm == [yY] ]]; then
#     # Process each database
#     for db in "${DATABASES[@]}"; do
#         delete_database "$db"
#     done
#     echo "Database deletion process complete!"
# else
#     echo "Operation cancelled. No databases were deleted."
# fi



# echo ""
# echo "✅ RESULT: Postgres delete process finished! "
# echo ""
# read -p "⏸️  PAUSE: Press Enter to continue... "
# echo ""
# echo "-------------------------------------------------------------------"
# #######################    DELETE LOCAL POSTGRES END    ######################
# #######################    DELETE GITHUB REPOS START    ###############################
# echo ""
# echo "🛠  ACTION: Deleting Github repos... "
# echo ""



# # Array of repository names - change them to suit your needs
# REPOS=(

#     # BE SURE TO REPLACE THESE WITH THE NAMES YOU WANT TO DELETE
#     # ALSO BE SURE YOU HAVE AT LEAST ON NAME IN HERE OR IT MIGHT DELETE EVERY REPO!!!!!!!!!!!!
#     # YOU DON'T NEED THESE TO BE ENCLOSED IN QUOTES
# "$ADMIEND_REPO_NAME"
# "$FRONTEND_REPO_NAME"
# "$BACKEND_REPO_NAME"
# )

# # Function to delete a GitHub repository
# delete_repo() {
#     local repo_name=$1
#     echo "Processing GitHub repository: $repo_name"

#     # Check if repo exists by trying to get its details
#     if gh repo view "$repo_name" &>/dev/null; then
#         echo "  Repository exists. Requesting deletion..."

#         # Prompt for confirmation
#         read -p "  Are you sure you want to delete $repo_name? (y/n): " confirm
#         if [[ $confirm == [yY] ]]; then
#             echo "  Deleting repository..."
#             gh repo delete "$repo_name" --confirm

#             if [ $? -eq 0 ]; then
#                 echo "  Successfully deleted repository: $repo_name"
#             else
#                 echo "  Failed to delete repository: $repo_name"
#             fi
#         else
#             echo "  Skipping deletion of: $repo_name"
#         fi
#     else
#         echo "  Repository does not exist: $repo_name"
#     fi
#     echo "----------------------------------------"
# }

# # Main execution
# echo "Starting GitHub repository deletion process..."
# echo "----------------------------------------"

# # Verify GitHub CLI is installed and authenticated
# if ! command -v gh &>/dev/null; then
#     echo "GitHub CLI (gh) is not installed. Please install it first."
#     exit 1
# fi

# if ! gh auth status &>/dev/null; then
#     echo "Not authenticated with GitHub. Please run 'gh auth login' first."
#     exit 1
# fi

# # Process each repository
# for repo in "${REPOS[@]}"; do
#     delete_repo "$repo"
# done

# echo "Repository deletion process complete!"



# echo ""
# echo "✅ RESULT: Github repo delete process finished! "
# echo ""
# read -p "⏸️  PAUSE: Press Enter to continue... "
# echo ""
# echo "-------------------------------------------------------------------"
# #######################    DELETE GITHUB REPOS END    ###############################
# #######################    DELETE LOCAL FILES START    ####################
# echo ""
# echo "🛠  ACTION: Deleting local files/fodlers... "
# echo ""


# # Directories to delete
# dirs=("$ADMIEND_REPO_NAME" "$FRONTEND_REPO_NAME" "$BACKEND_REPO_NAME" "$APP_PROJECT_DIR_NAME")

# # Iterate through each directory and delete if it exists
# for dir in "${dirs[@]}"; do
#     if [ -n "$dir" ] && [ -d "$dir" ]; then
#         echo "Deleting directory: $dir"
#         rm -rf "$dir"
#         wait # Ensure deletion is complete before proceeding
#     else
#         echo "Skipping: $dir (does not exist or is not set)"
#     fi
# done



# echo ""
# echo "✅ RESULT: Local files/folders delete process finished! "
# echo ""
# read -p "⏸️  PAUSE: Press Enter to continue... "
# echo ""
# echo "-------------------------------------------------------------------"

# #######################    DELETE LOCAL FILES END    ######################
# #############################################################################
# echo " "
# echo "-------------------------------------------------------------------"
# echo "📣 UPDATE: YOU HAVE FINISHED THE ENTIRE DELETE SCRIPT!!!!!!!!!!!!!!!!!!!!"
# echo "-------------------------------------------------------------------"
# echo " "
# echo "🗑️ REGRET: You may be able to recover local files in your trash bin..."
# echo "⚰️ TERMINATED: Your AWS services and Github repos are terminated!"
# echo " "
# echo "-------------------------------------------------------------------"
# echo ""
# echo "👋 GOODBYE: Program finished!"
# echo ""
# exit 0

# else
#   echo "👋 GOODBYE: Program finished!"
#   exit 0
# fi
# EOL







# echo ""
# echo "✅ RESULT: App delete script successfully created! "
# echo ""
# echo "📂 LOCATION: scripts/delete-${APP_PROJECT_DIR_NAME}-script.sh"
# echo ""
# read -p "⏸️  PAUSE: Press Enter to continue..."
# echo ""
# echo "-------------------------------------------------------------------"



######################################
# Final git stage commit push
echo ""
echo "🛠  ACTION: Staging, Committing, Pushing..."
echo ""

git add -A
git commit -m "Created and logging json and delete script"
git push

cd ../$BACKEND_REPO_NAME

echo ""
echo "✅ RESULT: Admiend up to date! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue..."
echo ""
echo "-------------------------------------------------------------------"




###################################################################################################
echo ""
echo "-------------------------------------------------------------------"
echo "📣 UPDATE: COLLECTED APP INFO AND CREATED DELETE SCRIPT 🙌  "
echo "-------------------------------------------------------------------"
#endregion
#region AWS Configuring
#########################################################################################################################
#########################################################################################################################
# AWS: LOGING IN TO EC2, MOUNTING EBS, INSTALLING NVM AND NODE.JS
#########################################################################################################################
#########################################################################################################################
echo " "
echo "-------------------------------------------------------------------"
echo "📣 UPDATE: Logging in to EC2, mounting EBS, installing NVM and NODE.JS..."
echo "-------------------------------------------------------------------"


#######################################################################################
# Log in to EC2...
echo ""
echo "🛠  ACTION: Logging in to EC2...  "
echo ""


#######################################################################################
# Exit on any error
set -e

# Check if environment variables are set
if [ -z "$KEY_PAIR_NAME" ] || [ -z "$PUBLIC_IP" ]; then
    echo "Error: KEY_PAIR_NAME and PUBLIC_IP environment variables must be set"
    exit 1
fi

# Check if key pair file exists
if [ ! -f "${KEY_PAIR_NAME}.pem" ]; then
    echo "Error: ${KEY_PAIR_NAME}.pem not found"
    exit 1
fi

echo "Connecting to EC2 instance and executing setup..."

ssh -o "StrictHostKeyChecking=no" -i "${KEY_PAIR_NAME}.pem" "ec2-user@${PUBLIC_IP}" << 'EOF'
#!/bin/bash

# Exit on any error
set -e

echo "Starting setup process..."

# Check for attached volume
echo "Checking attached volumes..."
lsblk
sleep 2

# Check if volume exists
if [ ! -e /dev/xvdf ]; then
    echo "Error: Volume /dev/xvdf not found"
    exit 1
fi

# Check volume status
echo "Checking volume status..."
volume_status=$(sudo file -s /dev/xvdf)
echo "Volume status: $volume_status"

# Format the volume (only if new)
if ! echo "$volume_status" | grep -q "XFS"; then
    echo "Formatting volume with XFS..."
    sudo mkfs -t xfs /dev/xvdf
    # Wait for format to complete
    sleep 5
    echo "Volume formatting completed"
fi

# Create mount point if needed
echo "Setting up mount point..."
if [ ! -d /app ]; then
    sudo mkdir /app
    echo "Created /app directory"
fi

# Mount the volume
echo "Mounting volume..."
sudo mount /dev/xvdf /app

# Check mount
if ! mountpoint -q /app; then
    echo "Error: Failed to mount volume"
    exit 1
fi

# Add to fstab if needed
echo "Configuring persistent mount..."
if ! grep -q "/dev/xvdf /app" /etc/fstab; then
    echo "/dev/xvdf /app xfs defaults,nofail 0 2" | sudo tee -a /etc/fstab
    echo "Added mount configuration to fstab"
fi

# Set appropriate permissions
echo "Setting directory permissions..."
sudo chown ec2-user:ec2-user /app
sudo chmod 755 /app

# Install nvm
echo "Installing nvm..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# Ensure nvm is loaded
echo "Loading nvm..."
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Verify nvm installation
if ! command -v nvm &> /dev/null; then
    echo "Error: nvm installation failed"
    exit 1
fi

echo "NVM Version:"
nvm --version

# Install Node.js
echo "Installing Node.js LTS version..."
nvm install --lts
sleep 5  # Wait for installation to complete

# Verify Node.js installation
if ! command -v node &> /dev/null; then
    echo "Error: Node.js installation failed"
    exit 1
fi

# Verify installations and versions
echo "Verifying installations..."
echo "Node Version:"
node --version
echo "NPM Version:"
npm --version

# Add node and npm to PATH permanently
echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc
echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.bashrc

echo "Setup completed successfully!"




#######################################################################################
# Creating .env on EBS...
echo ""
echo "🛠  ACTION: Creating .env on EBS in AWS...  "
echo ""

# Navigate to the mounted EBS volume directory
cd /app

# Create the .env directory and .env.production file
mkdir -p .env

cat > .env/.env.production << EOL
SERVER_PORT=5555
NODE_ENV=development

DB_DIALECT=postgres
DB_USER=postgres
DB_PASSWORD=postgres
DB_NAME=$DB_POSTGRES
DB_PORT=5432
DB_HOST=localhost

PG_DB_NAME_TEST=$DB_POSTGRES_TEST

JWT_ACCESS_TOKEN_SECRET=your_jwt_access_token_secret_here
JWT_REFRESH_TOKEN_SECRET=your_jwt_refresh_token_secret_here
JWT_EXPIRES_IN=604800
EOL

# Set proper permissions
chmod 600 .env

echo ""
echo "✅ RESULT: Created .env on EBS! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue..."
echo ""
echo "-------------------------------------------------------------------"





# Exit the SSH session
exit
EOF


#######################################################################################
# Check if SSH command was successful
if [ $? -eq 0 ]; then
    echo "Successfully completed setup on EC2 instance"
else
    echo "Error: Setup on EC2 instance failed"
    exit 1
fi
echo " "
echo "Script completed. SSH session terminated."



echo ""
echo "✅ RESULT: EC2 connected to EBS and installed NODE.JS! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue..."
echo ""
echo "-------------------------------------------------------------------"





########################################################################################################################################################
echo " "
echo "-------------------------------------------------------------------"
echo "📣 UPDATE: YOU HAVE FINISHED THE ENTIRE SETUP SCRIPT!!!!!!!!!!!!!!!!!!!!"
echo "-------------------------------------------------------------------"
echo " "
echo "Next steps: Set up CI/CD:"
echo "Use AWS GitHub Actions, AWS CodeDeploy, or AWS CodePipeline to connect your EC2/EBS to GitHub repo"
echo " "
echo "-------------------------------------------------------------------"



#endregion

###################################################################################################
# Prompt to launch the server
echo ""
read -p "Do you want to launch the development server? (y/n): " user_input

# Check the user's response
if [[ "$user_input" =~ ^[Yy]$ ]]; then
  echo ""
  echo "🛠  ACTION: Launching the server... 🚀  "
  echo ""

  # Run the server
  npm run dev
else
  echo "👋 GOODBYE: Program finished!"
  exit 0
fi
