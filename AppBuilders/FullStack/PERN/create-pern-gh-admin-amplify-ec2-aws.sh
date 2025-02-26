#!/bin/bash
export AWS_PAGER=""

#########################################################################################################################
#########################################################################################################################
# REPO_NAME: CREATE REPO NAME FOR ADMIN, FRONTEND, BACKEND WITH DATE AND VERSION
#########################################################################################################################
#########################################################################################################################

# Check if repo name is provided
if [ -z "$1" ]; then
    echo "Please try again and provide a repo name as argument..."
    echo "Usage: ./create-pern-gh-admin-amplify-ec2-aws.sh my-repo"
    exit 1
fi


echo "CREATING ADMIN..."
ARG=$1
ADMIN_NAME_ARG=admiend-$1
FRONTEND_NAME_ARG=frontend-$1
BACKEND_NAME_ARG=backend-$1
CREATE_DATE=$(date '+%m-%d-%Y')
REPO_VERSION=1


# Function to check if repository exists and get latest version
check_repo_version() {
    local base_name="$ADMIN_NAME_ARG-$CREATE_DATE"
    local highest_version=0  # Initialize to 0 instead of 1

    # Check GitHub repositories
    local existing_repos=$(gh repo list ScottFeichter --json name --limit 100 | grep -o "\"name\":\"$base_name-[0-9]*\"")

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
        local dir_version=$(echo "$existing_dirs" | grep -o "$base_name-[0-9]*$" | grep -o '[0-9]*$' | sort -n | tail -1)
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
echo "Checking for version..."
check_repo_version








#########################################################################################################################
#########################################################################################################################
# ADMIEND: CREATE ADMIN REPO LOCAL AND REMOTE WITH STARTER FILES AND DIRECTORIES AND PUSH
#########################################################################################################################
#########################################################################################################################
# Create the final repo name with the appropriate version
ADMIN_REPO_NAME="$ADMIN_NAME_ARG-$CREATE_DATE-$REPO_VERSION"


# Create directory
echo "Creating project admin directory and structure..."
mkdir "$ADMIN_REPO_NAME"
cd "$ADMIN_REPO_NAME"


# Create admin file structure
mkdir -p api-docs comporables draw-io images images/products images/banners images/icons misc postman questions requirements redux schema sequelize sounds thumbnails uploads wireframes

echo "Created admin file structure:"
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

# Create starter files
echo "Creating starter files..."

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
    echo "LIST SUBJECT TO CHANGE - CHECK PROD ENV FOR MOST CURRENT"
    echo "npm init -y"          >> $ARG-backend-requirements.txt
	echo "" 					>> $ARG-backend-requirements.txt
	echo "# npm install for:" 	>> $ARG-backend-requirements.txt
	echo cookie-parser 			>> $ARG-backend-requirements.txt;
	echo cors 				    >> $ARG-backend-requirements.txt;
	echo csurf 					>> $ARG-backend-requirements.txt;
	echo dotenv 				>> $ARG-backend-requirements.txt;
	echo express 				>> $ARG-backend-requirements.txt;
	echo express-async-errors 	>> $ARG-backend-requirements.txt;
	echo helmet 				>> $ARG-backend-requirements.txt;
	echo jsonwebtoken 			>> $ARG-backend-requirements.txt;
	echo morgan 				>> $ARG-backend-requirements.txt;
	echo per-env 				>> $ARG-backend-requirements.txt;
	echo sequelize@6 			>> $ARG-backend-requirements.txt;
	echo sequelize-cli@6 		>> $ARG-backend-requirements.txt;
	echo pg						>> $ARG-backend-requirements.txt;
	echo "" 					>> $ARG-backend-requirements.txt;

	echo "#npm install -D for:" >> $ARG-backend-requirements.txt;
	echo sqlite3 				>> $ARG-backend-requirements.txt;
	echo dotenv-cli				>> $ARG-backend-requirements.txt;
	echo nodemon				>> $ARG-backend-requirements.txt;
	wait;






touch schema/$ARG-schema.png

touch sequelize/seeders.js
touch sequelize/commands.md
touch sequelize/migrations.js

touch README.md
	echo "# [$ADMIN_REPO_NAME]">> README.md;
	echo "! [db-schema ]">> README.md;
	echo "[db-schema]: ./schema/[$ARG]-schema.png">> README.md



# Initialize repository local and remote and push
echo "Initializing admin git local w github remote and pushing..."
git init
touch README.md
git add .
git commit -m "initial (msg via shell)"

git branch Production
git branch Staging
git branch Development

gh repo create "$ADMIN_REPO_NAME" --public

git remote add origin "https://github.com/ScottFeichter/$ADMIN_REPO_NAME.git"
git branch -M main
git push -u origin main









#########################################################################################################################
#########################################################################################################################
# ADMIEND: CREATE AND CONNECT S3 BUCKET TO ADMIEND
#########################################################################################################################
#########################################################################################################################
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
# THE SCRIPT:

# Check if repository name is provided as argument
if [ -z "$1" ]; then
    echo "Please provide a GitHub repository name as argument"
    echo "Usage: ./create-s3-from-repo.sh <repository-name> [--with-cloudfront]"
    exit 1
fi


SETUP_CLOUDFRONT=false

# Check for optional CloudFront flag
if [ "$2" = "--with-cloudfront" ]; then
    SETUP_CLOUDFRONT=true
fi




# Generate bucket name with timestamp and random string
TIMESTAMP=$(date +%Y%m%d%H%M%S)
RANDOM_STRING=$(openssl rand -hex 4)
BUCKET_NAME="${ADMIN_REPO_NAME}-${TIMESTAMP}-${RANDOM_STRING}"

# Convert bucket name to lowercase (S3 requirement)
BUCKET_NAME=$(echo "$BUCKET_NAME" | tr '[:upper:]' '[:lower:]')

# Remove any invalid characters (S3 only allows lowercase letters, numbers, dots, and hyphens)
BUCKET_NAME=$(echo "$BUCKET_NAME" | sed 's/[^a-z0-9.-]/-/g')


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





#########################################################################################################################
#########################################################################################################################
# ADMIEND: CREATE GIT HOOK TO SEND TO S3 ON PUSH
#########################################################################################################################
#########################################################################################################################

######################################################################################################
echo "Creating hook for Git/GitHub/S3..."

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


# Final git add push
echo "Staging, commiting, pushing..."
git add -A
git commit -m "Admin Setup Complete"
git push

cd ..

echo ""
echo "Admiend setup complete!"
echo ""





#########################################################################################################################
#########################################################################################################################
# FRONTEND: CREATES REACT FRONTEND THEN CREATES GIT LOCAL AND REMOTE AND PUSHES
#########################################################################################################################
#########################################################################################################################
echo " "
echo "CREATING FRONTEND..."
echo " "


# Create the final repo name with the appropriate version
FRONTEND_REPO_NAME="$FRONTEND_NAME_ARG-$CREATE_DATE-$REPO_VERSION"


# Initialize project with Vite
echo "Creating React w Vite project: $FRONTEND_REPO_NAME..."
npm create vite@latest $FRONTEND_REPO_NAME -- --template react-ts -- --skip-git

cd $FRONTEND_REPO_NAME




# Initialize repository
echo "Initializing git local and remote..."
git init
cat > README.md << EOL
react front end for $FRONTEND_REPO_NAME
EOL
git add .
git commit -m "initial (msg via shell)"

git branch Production
git branch Staging
git branch Development

# Create GitHub repository
gh repo create "$FRONTEND_REPO_NAME" --public

# Configure remote and push
git remote add origin "https://github.com/ScottFeichter/$FRONTEND_REPO_NAME.git"
git branch -M main
git push -u origin main

# Push other branches
git push origin Production
git push origin Staging
git push origin Development

echo "Repository initialized local and remote pushed"




# Install core dependencies
echo "Installing core dependencies..."
npm install

# Install TypeScript and type definitions first
echo "Installing TypeScript and type definitions..."
npm install --save-dev typescript @types/react @types/react-dom @types/node
npx tsc --init


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


# Create project structure
echo "Creating project structure..."
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




# Create basic files
echo "Creating basic files..."

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



#########################################################################################################################
#########################################################################################################################
# FRONTEND: CREATE AND CONNECT AMPLIFY APP TO FRONTEND REPO
#########################################################################################################################
#########################################################################################################################

#########################################################################################################################
# Check if gh cli is installed

    # Final git add push
    echo "Staging, commiting, pushing..."
    git add -A
    git commit -m "Frontend Setup Complete"
    git push



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



    # Print results
    echo " "
    echo "Repository Information:"
    echo "======================"
    echo "Name: $FRONTEND_REPO_NAME"
    echo "URL: $FRONTEND_REPO_URL"
    echo " "
    echo " "
    echo "Token: $TOKEN"
    echo " "
    echo " "




#########################################################################################################################
# CREATES AMPLIFY APP FROM REPO
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

# Get the current timestamp for unique app name




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


# Create main branch
echo "Creating branch..."
aws amplify create-branch \
    --app-id "${APP_ID}" \
    --branch-name "main"

echo "You need to adjust via the AWS Amplify Console for this app to use gh app instead of oauth..."
echo "After this adjustment is made you then need to run the deploy as it will have been paused..."

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

cd ..

echo " "
echo "Frontend setup complete! "
echo " "





#########################################################################################################################
#########################################################################################################################
# BACKEND: CREATES NODE BACKENDEND THEN CREATES GIT LOCAL AND REMOTE AND PUSHES
#########################################################################################################################
#########################################################################################################################


# Create the final repo name with the appropriate version
echo "CREATING BACKEND..."
BACKEND_REPO_NAME="$BACKEND_NAME_ARG-$CREATE_DATE-$REPO_VERSION"
echo " "


###################################################################################################

# Create directory and initialize repository
echo "Creating project directory and git local and remote..."
mkdir "$BACKEND_REPO_NAME"
cd "$BACKEND_REPO_NAME"

git init
touch README.md
git add .
git commit -m "initial (msg via shell)"

git branch Production
git branch Staging
git branch Development

gh repo create "$BACKEND_REPO_NAME" --public

git remote add origin "https://github.com/ScottFeichter/$BACKEND_REPO_NAME.git"
git branch -M main
git push -u origin main


###################################################################################################

# Create directory and file structure
echo "Creating directory and file structure..."
mkdir src
  mkdir src/bin
    touch www

  mkdir src/config
    touch src/config/database.js
    touch src/config/index.ts
    touch src/config/sequelize-cli.js

  mkdir src/database
    mkdir src/database/migrations
    mkdir src/database/models
    mkdir src/database/seeders
    touch src/database/index.ts

  mkdir src/dist
    touch src/app.js
    touch src/psql-setup-script.js

  mkdir src/docs
    mkdir src/docs/schema
    touch src/docs/auth.yaml
    touch src/docs/user.yaml
      touch src/docs/schema/auth.schema.yaml
      touch src/docs/schema/user.schema.yaml

  mkdir src/interfaces
    touch src/interfaces/user.interfaces.ts

  mkdir src/logs
  mkdir src/middlewares
    touch src/uath.middleware.ts
    touch src/jwt.service.ts

  mkdir src/modules
    mkdir src/modules/auth
      touch src/modules/auth.controller.ts
      touch src/modules/auth.repo.ts
      touch src/modules/auth.routes.ts
      touch src/modules/auth.service.ts
      touch src/modules/auth.validator.ts
    mkdir src/modules/user
      touch src/modules/user.controller.ts
      touch src/modules/user.repo.ts
      touch src/modules/user.routes.ts
      touch src/modules/user.service.ts
      touch src/modules/user.validator.ts
    mkdir src/modules/etc

  mkdir src/routes
    touch src/routs/index.ts
    touch src/routs/routes.ts DONT THINK I NEED BOTH WILL CHECK

  mkdir src/types
    mkdir src/express
      touch src/types/express/index.d.ts

  mkdir src/utils
    touch src/utils/custom-error.ts
    touch src/utils/error-handler.ts
    touch src/utils/logger.ts
    touch src/utils/swagger.ts


  touch src/server.js

  mkdir tests
    mkdir tests/middleware
      touch src/tests/middleware/auth.middleware.test.ts
      touch src/tests/middleware/jwt.service.test.ts
    mkdir tests/modules
      mkdir auth
        touch src/tests/modules/auth/auth.controller.test.ts
        touch src/tests/modules/auth/auth.service.test.ts
      mkdir user
        touch src/tests/modules/user/user.controller.test.ts
        touch src/tests/modules/user/user.service.test.ts

touch env.example
touch env.testing
touch env.development
touch env.production

touch .eslintignnore
touch .eslintrc

touch .gitignore
touch .npmignore

touch .prettierrc.json
touch .sequelizerc

touch jest.config.js
touch LICENSE

touch nodemon.json
touch buildspec.yml
touch tsconfig.json


###################################################################################################

# Creating www
echo "Creating src/bin/www and making it executable..."
cat > src/bin/www << EOL
#!/usr/bin/env node

import { port } from '../config/index.js';
import app from '../app';
import db from '../db/models';

async function startServer() {
    try {
        await db.sequelize.authenticate();
        console.log('Database connection success! Sequelize is ready to use...');
        app.listen(port, () => console.log(`Listening on port ${port}...`));
    } catch (err) {
        console.log('Database connection failure.');
        console.error(err);
    }
}

startServer();
EOL

# Make www executable
chmod +x src/bin/www


###################################################################################################

# Creating src/config/database.js
echo "Creating src/config/database.js ..."
cat < src/config/database.js << EOL
{
  "development": {
    "username": "root",
    "password": null,
    "database": "database_development",
    "host": "127.0.0.1",
    "dialect": "mysql"
  },
  "testing": {
    "username": "root",
    "password": null,
    "database": "database_test",
    "host": "127.0.0.1",
    "dialect": "mysql"
  },
  "production": {
    "username": "root",
    "password": null,
    "database": "database_production",
    "host": "127.0.0.1",
    "dialect": "mysql"
  }
}
EOL


###################################################################################################

# Creating src/config/index.ts
echo "Creating src/config/index.ts ..."
cat < src/config/index.ts << EOL
import { config } from 'dotenv';

const envFile = `.env.${process.env.NODE_ENV || 'development'}`;
config({ path: envFile });

export const {
    PORT,
    NODE_ENV,
    BASE_URL,
    JWT_ACCESS_TOKEN_SECRET,
    JWT_REFRESH_TOKEN_SECRET,
} = process.env;

export const {
    DB_PORT,
    DB_USERNAME,
    DB_PASSWORD,
    DB_NAME,
    DB_HOST,
    DB_DIALECT,
} = process.env;
EOL


###################################################################################################

# Creating src/config/sequelize-cli.js
echo "Creating src/config/sequelize-cli.js ..."
cat < src/config/sequelize-cli.js << EOL
const { config } = require('dotenv');
config({ path: `.env.${process.env.NODE_ENV || 'development'}` });

const { DB_PORT, DB_USERNAME, DB_PASSWORD, DB_NAME, DB_HOST, DB_DIALECT } =
    process.env;

module.exports = {
    username: DB_USERNAME,
    password: DB_PASSWORD,
    database: DB_NAME,
    port: DB_PORT,
    host: DB_HOST,
    dialect: DB_DIALECT,
    migrationStorageTableName: 'sequelize_migrations',
    seederStorageTableName: 'sequelize_seeds',
};
EOL



###################################################################################################

# Creating src/database/migrations/20241025023422-create-user.js
echo "Creating src/database/migrations/20241025023422-create-user.js..."
cat < src/database/migrations/20241025023422-create-user.js << EOL
'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
    async up(queryInterface, Sequelize) {
        await queryInterface.createTable('users', {
            id: {
                type: Sequelize.UUID,
                defaultValue: Sequelize.literal('uuid_generate_v4()'),
                primaryKey: true,
            },
            email: {
                type: Sequelize.STRING(45),
                allowNull: false,
                unique: true,
            },
            name: {
                type: Sequelize.STRING(45),
                allowNull: false,
            },
            username: {
                type: Sequelize.STRING(45),
                allowNull: true,
                unique: true,
            },
            password: {
                type: Sequelize.STRING(255),
                allowNull: false,
            },
            created_at: {
                type: Sequelize.DATE,
                allowNull: false,
                defaultValue: Sequelize.NOW,
            },
            updated_at: {
                type: Sequelize.DATE,
                allowNull: false,
                defaultValue: Sequelize.NOW,
            },
        });
    },

    async down(queryInterface, Sequelize) {
        await queryInterface.dropTable('users');
    },
};
EOL

###################################################################################################

# Create src/database/models/user.model.ts
echo "Creating src/database/models/user.model.ts..."
cat > src/database/models/user.model.ts << EOL
import { User } from '@/interfaces/user.interfaces';
import { Sequelize, DataTypes, Model, Optional } from 'sequelize';

export type UserCreationAttributes = Optional<
    User,
    'id' | 'username'
>;

export class UserModel
    extends Model<User, UserCreationAttributes>
    implements User
{
    public id!: string;
    public email!: string;
    public name!: string;
    public username!: string;
    public password!: string;
    public created_at: string | undefined;
    public updated_at: string | undefined;

    public readonly createdAt!: Date;
    public readonly updatedAt!: Date;
}

export default function (sequelize: Sequelize): typeof UserModel {
    UserModel.init(
        {
            id: {
                primaryKey: true,
                type: DataTypes.UUIDV4,
                defaultValue: DataTypes.UUIDV4,
            },
            email: {
                allowNull: false,
                type: DataTypes.STRING,
                unique: true,
            },
            name: {
                allowNull: false,
                type: DataTypes.STRING,
            },
            username: {
                allowNull: true,
                type: DataTypes.STRING,
                unique: true,
            },
            password: {
                allowNull: false,
                type: DataTypes.STRING(255),
            },
            created_at: DataTypes.DATE,
            updated_at: DataTypes.DATE,
        },
        {
            tableName: 'users',
            sequelize,
            createdAt: 'created_at',
            updatedAt: 'updated_at',
            timestamps: true,
        },
    );

    return UserModel;
}
EOL

###################################################################################################

# Create database/index.ts
echo "Creating database/index.ts..."
cat > src/database/index.ts << EOL
import { User } from '@/interfaces/user.interfaces';
import { Sequelize, DataTypes, Model, Optional } from 'sequelize';

export type UserCreationAttributes = Optional<
    User,
    'id' | 'username'
>;

export class UserModel
    extends Model<User, UserCreationAttributes>
    implements User
{
    public id!: string;
    public email!: string;
    public name!: string;
    public username!: string;
    public password!: string;
    public created_at: string | undefined;
    public updated_at: string | undefined;

    public readonly createdAt!: Date;
    public readonly updatedAt!: Date;
}

export default function (sequelize: Sequelize): typeof UserModel {
    UserModel.init(
        {
            id: {
                primaryKey: true,
                type: DataTypes.UUIDV4,
                defaultValue: DataTypes.UUIDV4,
            },
            email: {
                allowNull: false,
                type: DataTypes.STRING,
                unique: true,
            },
            name: {
                allowNull: false,
                type: DataTypes.STRING,
            },
            username: {
                allowNull: true,
                type: DataTypes.STRING,
                unique: true,
            },
            password: {
                allowNull: false,
                type: DataTypes.STRING(255),
            },
            created_at: DataTypes.DATE,
            updated_at: DataTypes.DATE,
        },
        {
            tableName: 'users',
            sequelize,
            createdAt: 'created_at',
            updatedAt: 'updated_at',
            timestamps: true,
        },
    );

    return UserModel;
}
EOL



###################################################################################################

# Create src/docs/schema/auth.schema.yaml
echo "Creating src/docs/schema/auth.schema.yaml..."
cat > src/docs/schema/auth.schema.yaml << EOL
components:
    schemas:
        signup:
            type: object
            required:
                - name
                - email
                - password
            properties:
                name:
                    type: string
                    example: Full Name
                email:
                    type: string
                    example: email@example.com
                password:
                    type: string
                    example: password

        signin:
            type: object
            required:
                - email
                - password
            properties:
                email:
                    type: string
                    example: email@example.com
                password:
                    type: string
                    example: password
EOL


###################################################################################################

# Create src/docs/auth.yaml
echo "Creating src/docs/auth.yaml..."
cat > src/docs/auth.yaml << EOL
# [POST] signup
/auth/signup:
    post:
        tags:
            - Auth
        summary: Sign Up
        requestBody:
            description: Sign Up
            required: true
            content:
                application/json:
                    schema:
                        $ref: '#/components/schemas/signup'
        responses:
            201:
                description: 'OK'
            400:
                description: 'Bad Request'
            409:
                description: 'Conflict'
            500:
                description: 'Internal server error'

# [POST] signin
/auth/signin:
    post:
        tags:
            - Auth
        summary: Sign In
        requestBody:
            description: Sign In
            required: true
            content:
                application/json:
                    schema:
                        $ref: '#/components/schemas/signin'
        responses:
            201:
                description: 'OK'
            400:
                description: 'Bad Request'
            401:
                description: 'Unauthorized'
            409:
                description: 'Conflict'
            500:
                description: 'Internal server error'
EOL


###################################################################################################

# Create src/docs/user.yaml
echo "Creating src/docs/user.yaml..."
cat > src/docs/user.yaml << EOL
# [GET] Get User Profile
/user/profile:
    get:
        tags:
            - User
        summary: Get user profile by decoded ID from token
        responses:
            404:
                descriptiom: 'User not found'
            401:
                description: 'Unauthorized'
            500:
                description: 'Internal server error'
        security:
            - bearerAuth: []

securityDefinitions:
    bearerAuth:
        type: apiKey
        name: Authorization
        in: header
        description: 'JWT Bearer token for authorization. Example: "Bearer {token}"'
EOL

###################################################################################################
# Create src/interfaces/user.interfaces.ts
echo "Creating src/interfaces/user.interfaces.ts..."
cat > src/interfaces/user.interfaces.ts << EOL
export interface User {
    id?: string;
    email: string;
    name: string;
    username: string;
    password: string;
    created_at: string | undefined;
    updated_at: string | undefined;
}
EOL



###################################################################################################
# Create src/middlewares/auth.middleware.ts
echo "Creating src/middlewares/auth.middleware.ts..."
cat > src/middlewares/auth.middleware.ts << EOL
import { CustomError } from '@/utils/custom-error';
import { verifyJWT } from './jwt.service';
import { JWT_ACCESS_TOKEN_SECRET } from '@/config';
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


###################################################################################################

# Create src/middlewares/jwt.service.ts
echo "Creating src/middlewares/jwt.service.ts..."
cat > src/middlewares/jwt.service.ts << EOL
import jwt from 'jsonwebtoken';

export const generateJWT = async (payload: any, secretKey: string) => {
    try {
        const token = `Bearer ${jwt.sign(payload, secretKey)}`;
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

###################################################################################################

# Create src/modules/auth/auth.controller.ts
echo "Creating src/modules/auth/auth.controller.ts..."
cat > src/modules/auth/auth.controller.ts << EOL
import { NextFunction, Request, Response } from 'express';
import { signInService, signUpService } from './auth.service';

export const signUpController = async (
    req: Request,
    res: Response,
    next: NextFunction,
): Promise<void> => {
    try {
        const userData = req.body;
        const response = await signUpService(userData);

        res.status(201).json({
            message: 'Successfully signed up',
            data: response.user,
        });
    } catch (error) {
        next(error);
    }
};

export const signInController = async (
    req: Request,
    res: Response,
    next: NextFunction,
): Promise<void> => {
    try {
        const userData = req.body;
        const response = await signInService(userData);

        res.status(200).json({
            message: 'Successfully signed in',
            data: response,
        });
    } catch (error) {
        next(error);
    }
};
EOL

###################################################################################################

# Create src/modules/auth/auth.repo.ts
echo "Creating src/modules/auth/auth.repo.ts..."
cat > src/modules/auth/auth.repo.ts << EOL
import { DB } from '@/database';
import { User } from '@/interfaces/user.interfaces';

const repo = {
    findUserByEmail: async (email: string): Promise<User | null> => {
        return await DB.Users.findOne({ where: { email } });
    },

    createUser: async (userData: User): Promise<User> => {
        return await DB.Users.create(userData);
    },
};

export default repo;
EOL

###################################################################################################

# Create src/modules/auth/auth.routes.ts
echo "Creating src/modules/auth/auth.routes.ts..."
cat > src/modules/auth/auth.routes.ts << EOL
import express from 'express';
import { signInController, signUpController } from './auth.controller';

const authRouter = express.Router();

authRouter.post('/signup', signUpController);
authRouter.post('/signin', signInController);

export default authRouter;
EOL

###################################################################################################

# Create src/modules/auth/auth.service.ts
echo "Creating src/modules/auth/auth.service.ts..."
cat > src/modules/auth/auth.service.ts << EOL
import { User } from '@/interfaces/user.interfaces';
import { validateSignIn, validateSignUp } from './auth.validator';
import repo from './auth.repo';
import { compareSync, hash } from 'bcrypt';
import { generateJWT } from '@/middlewares/jwt.service';
import { JWT_ACCESS_TOKEN_SECRET } from '@/config';
import { CustomError } from '@/utils/custom-error';

export const signUpService = async (userData: User) => {
    const { error } = validateSignUp(userData);
    if (error) {
        throw new CustomError(error.details[0].message, 400);
    }

    const findUser = await repo.findUserByEmail(userData.email);
    if (findUser) {
        throw new CustomError(`Email ${userData.email} already exists`, 409);
    }

    const randomId = (Date.now() + Math.floor(Math.random() * 100)).toString(
        36,
    );
    const username = `${userData.email.split('@')[0]}-${randomId}`;
    const hashedPassword = await hash(userData.password, 10);
    const newUserData = await repo.createUser({
        ...userData,
        username,
        password: hashedPassword,
    });

    return { user: newUserData };
};

export const signInService = async (userData: User) => {
    const { error } = validateSignIn(userData);
    if (error) {
        throw new CustomError(error.details[0].message, 400);
    }

    const user = await repo.findUserByEmail(userData.email);
    if (!user) {
        throw new CustomError('Email or password is invalid', 401);
    }

    const validPassword = compareSync(userData.password, user.password);
    if (!validPassword) {
        throw new CustomError('Email or password is invalid', 401);
    }

    const payload = {
        userId: user.id,
    };

    const accessToken = await generateJWT(
        payload,
        JWT_ACCESS_TOKEN_SECRET as string,
    );

    return { user, accessToken };
};
EOL

###################################################################################################

# Create src/modules/auth/auth.validator.ts
echo "Creating src/modules/auth/auth.validator.ts..."
cat > src/modules/auth/auth.validator.ts << EOL
import Joi from 'joi';

const options = {
    errors: {
        wrap: {
            label: '',
        },
    },
};

export const validateSignUp = (userData: any) => {
    const schema = Joi.object({
        id: Joi.string()
            .guid({ version: 'uuidv4' })
            .optional()
            .messages({ 'string.guid': 'User ID must be in UUID format' }),
        email: Joi.string().email().required().messages({
            'string.email': 'Email format is invalid',
            'any.required': 'Email is required',
        }),
        name: Joi.string().min(1).required().messages({
            'string.min': 'Name should at least minimum 1 character',
            'any.required': 'Name is required',
        }),
        username: Joi.string().optional(),
        password: Joi.string()
            .min(8)
            .pattern(
                new RegExp(
                    '^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[^a-zA-Z\\d]).+$',
                ),
            )
            .required()
            .messages({
                'string.min': 'Password must have at least 8 characters.',
                'string.pattern.base':
                    'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character.',
                'any.required': 'Password is required.',
            }),
    });

    return schema.validate(userData, options);
};

export const validateSignIn = (userData: any) => {
    const schema = Joi.object({
        email: Joi.string().email().required().messages({
            'string.email': 'Email format is invalid',
            'any.required': 'Email is required',
        }),
        password: Joi.string().required(),
    });

    return schema.validate(userData, options);
};
EOL


###################################################################################################

# Create src/modules/user/user.controller.ts
echo "Creating src/modules/user/user.controller.ts..."
cat > src/modules/user/user.controller.ts << EOL
import { NextFunction, Request, Response } from 'express';
import { getUserProfileService } from './user.service';

export const getUserProfileController = async (
    req: Request,
    res: Response,
    next: NextFunction,
): Promise<void> => {
    try {
        const authorization = req.headers.authorization;
        if (!authorization) {
            res.status(404).json({ message: 'User not found' });
            return;
        }

        const accessToken = authorization.split(' ')[1];
        const response = await getUserProfileService(accessToken);

        res.status(200).json({ message: 'User data fetched', data: response });
    } catch (error) {
        next(error);
    }
};
EOL

###################################################################################################

# Create src/modules/user/user.repo.ts
echo "Creating src/modules/user/user.repo.ts..."
cat > src/modules/user/user.repo.ts << EOL
import { DB } from '@/database';
import { User } from '@/interfaces/user.interfaces';

export const repo = {
    getUserProfile: async (
        userId: string | undefined,
    ): Promise<User | null> => {
        return await DB.Users.findOne({ where: { id: userId } });
    },
};
EOL

###################################################################################################

# Create src/modules/user/user.routes.ts
echo "Creating src/modules/user/user.routes.ts..."
cat > src/modules/user/user.routes.ts << EOL
import express from 'express';
import { getUserProfileController } from './user.controller';
import { authMiddleware } from '@/middlewares/auth.middleware';

const userRouter = express.Router();

userRouter.get('/profile', authMiddleware, getUserProfileController);

export default userRouter;
EOL

###################################################################################################

# Create src/modules/user/user.service.ts
echo "Creating src/modules/user/user.service.ts..."
cat > src/modules/user/user.service.ts << EOL
import { repo } from './user.repo';
import { CustomError } from '@/utils/custom-error';
import { verifyJWT } from '@/middlewares/jwt.service';
import { JWT_ACCESS_TOKEN_SECRET } from '@/config';

export const getUserProfileService = async (accessToken: string) => {
    const decodeToken = await verifyJWT(
        accessToken,
        JWT_ACCESS_TOKEN_SECRET as string,
    );

    const userId = decodeToken.userId;

    const user = await repo.getUserProfile(userId);
    if (!user) {
        throw new CustomError('User not found', 404);
    }

    return user;
};
EOL

###################################################################################################

# Create src/modules/user/user.validator.ts
echo "Creating src/modules/user/user.validator.ts..."
cat > src/modules/user/user.validator.ts << EOL
import Joi from 'joi';

const options = {
    errors: {
        wrap: {
            label: '',
        },
    },
};
EOL


###################################################################################################

# Create src/routes/routes.ts
echo "Creating src/routes/routes.ts..."
cat > src/routes/routes.ts << EOL
import authRouter from '@/modules/auth/auth.routes';
import userRouter from '@/modules/user/user.routes';
import express from 'express';

const router = express.Router();

router.use('/auth', authRouter);
router.use('/user', userRouter);

export default router;
EOL

###################################################################################################

# Create src/types/express/index.d.ts
echo "Creating src/types/express/index.d.ts..."
cat > src/types/express/index.d.ts << EOL
import { JwtPayload } from 'jsonwebtoken';

declare module 'express-serve-static-core' {
    interface Request {
        context?: JwtPayload;
    }
}
EOL

###################################################################################################

# Create utils/custom-error.ts
echo "Creating utils/custom-error.ts..."
cat > src/utils/custom-error.ts << EOL
export class CustomError extends Error {
    public statusCode: number;

    constructor(message: string, statusCode: number) {
        super(message);
        this.statusCode = statusCode;
        Error.captureStackTrace(this, this.constructor);
    }
}
EOL

###################################################################################################

# Create src/utils/error-handler.ts
echo "Creating src/utils/error-handler.ts..."
cat > src/utils/error-handler.ts << EOL
import { Request, Response, NextFunction } from 'express';
import { CustomError } from './custom-error';

export const errorHandler = (
    err: Error | CustomError,
    req: Request,
    res: Response,
    next: NextFunction,
) => {
    const statusCode = err instanceof CustomError ? err.statusCode : 500;
    const message = err.message || 'Internal Server Error';

    res.status(statusCode).json({ error: message });
};
EOL

###################################################################################################

# Create src/utils/logger.ts
echo "Creating src/utils/logger.ts..."
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
        return `[${timestamp}] - ${level}: ${message}`;
    }

    return `[${timestamp}] ${level}: ${errorMessage}`;
});

// Daily Rotate File for debug logs
const debugTransport = new winston.transports.DailyRotateFile({
    filename: `${logDir}/debug/debug-%DATE%.log`,
    datePattern: 'YYYY-MM-DD',
    level: 'debug',
    maxFiles: '14d', // Keep logs for 14 days
});

// Daily Rotate File for error logs
const errorTransport = new winston.transports.DailyRotateFile({
    filename: `${logDir}/error/error-%DATE%.log`,
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
            return `[${timestamp}] ${level.toUpperCase()}: ${message}`;
        }),
    ),
    transports: [consoleTransport, debugTransport, errorTransport],
});

export default logger;
EOL

###################################################################################################

# Create src/utils/swagger.ts
echo "Creating src/utils/swagger.ts..."
cat > src/utils/swagger.ts << EOL
import { BASE_URL } from '@/config';
import swaggerJSDoc from 'swagger-jsdoc';
import swaggerUi from 'swagger-ui-express';

const options = {
    swaggerDefinition: {
        openapi: '3.0.0',
        info: {
            title: 'My API',
            version: '1.0.0',
            description: 'API documentation for my application',
        },
        servers: [
            {
                url: BASE_URL,
            },
        ],
        components: {
            securitySchemes: {
                bearerAuth: {
                    type: 'http',
                    scheme: 'bearer',
                    bearerFormat: 'JWT',
                },
            },
        },
        security: [
            {
                bearerAuth: [],
            },
        ],
    },
    apis: ['./src/docs/*.yaml', './src/docs/schema/*.yaml'],
};

const swaggerSpec = swaggerJSDoc(options);

export { swaggerUi, swaggerSpec };
EOL



###################################################################################################

# Create src/tests/middlewate/auth.middleware.test.ts
echo "Creating src/tests/middlewate/auth.middleware.test.ts..."
cat > src/tests/middlewate/auth.middleware.test.ts << EOL
import { authMiddleware } from '../../src/middlewares/auth.middleware';
import { verifyJWT } from '../../src/middlewares/jwt.service';
import { CustomError } from '../../src/utils/custom-error';
import { Request, Response, NextFunction } from 'express';

jest.mock('../../src/middlewares/jwt.service', () => ({
    verifyJWT: jest.fn(),
}));

interface CustomRequest extends Request {
    context?: any;
}

describe('authMiddleware', () => {
    let req: Partial<CustomRequest>;
    let res: Partial<Response>;
    let next: NextFunction;

    beforeEach(() => {
        req = {
            method: 'GET',
            url: '',
            header: jest.fn(),
            context: {},
        };
        res = {};
        next = jest.fn();
    });

    test('Should bypass middleware if the request method is OPTIONS', async () => {
        req.method = 'OPTIONS';

        await authMiddleware(req as Request, res as Response, next);
        expect(next).toHaveBeenCalled();
    });

    test('Should bypass middleware for /api/auth/signin route', async () => {
        req.method = 'POST';
        req.url = '/api/auth/signin';

        await authMiddleware(req as Request, res as Response, next);
        expect(next).toHaveBeenCalled();
    });

    test('Should throw an error if Authorization header is missing', async () => {
        req.url = '/api/protected-route';
        (req.header as jest.Mock).mockReturnValue(undefined);

        await authMiddleware(req as Request, res as Response, next);

        expect(next).toHaveBeenCalledWith(
            new CustomError('Authorization header missing', 401),
        );
    });

    test('Should proceed if the token is valid', async () => {
        req.url = '/api/protected-route';
        const mockPayload = { userId: '123' };

        (req.header as jest.Mock).mockReturnValue('Bearer validToken');
        (verifyJWT as jest.Mock).mockResolvedValue(mockPayload);

        await authMiddleware(req as Request, res as Response, next);

        expect(req.context).toEqual(mockPayload);
        expect(next).toHaveBeenCalled();
    });

    test('Should throw an error if the token is invalid', async () => {
        req.url = '/api/protected-route';

        (req.header as jest.Mock).mockReturnValue('Bearer invalidToken');
        (verifyJWT as jest.Mock).mockRejectedValue(new Error('Invalid token'));

        await authMiddleware(req as Request, res as Response, next);

        expect(next).toHaveBeenCalledWith(new Error('Invalid token'));
    });
});
EOL

###################################################################################################

# Create src/tests/middleware/jwt.service.test.ts
echo "Creating src/tests/middleware/jwt.service.test.ts..."
cat > src/tests/middleware/jwt.service.test.ts << EOL
import jwt from 'jsonwebtoken';
import { generateJWT, verifyJWT } from '../../src/middlewares/jwt.service';

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

    test('verifyJWT should throw an error if payload is a string', async () => {
        (jwt.verify as jest.Mock).mockReturnValue('InvalidPayload');

        await expect(verifyJWT('Bearer validToken', secretKey)).rejects.toThrow(
            'Invalid token payload'
        );
    });
});
EOL

###################################################################################################

# Create src/tests/modules/auth/auth.controller.test.ts
echo "Creating src/tests/modules/auth/auth.controller.test.ts..."
cat > src/tests/modules/auth/auth.controller.test.ts << EOL
import { Request, Response, NextFunction } from 'express';
import { signUpController, signInController } from '../../../src/modules/auth/auth.controller';
import { signUpService, signInService } from '../../../src/modules/auth/auth.service';

jest.mock('../../../src/modules/auth/auth.service', () => ({
    signUpService: jest.fn(),
    signInService: jest.fn(),
}));

beforeEach(() => {
    jest.clearAllMocks();
});

describe('signUpController', () => {
    let req: Partial<Request>;
    let res: Partial<Response>;
    let next: NextFunction;

    beforeEach(() => {
        req = { body: { email: 'new@example.com', password: 'password' } };
        res = {
            status: jest.fn().mockReturnThis(),
            json: jest.fn(),
        };
        next = jest.fn();
    });

    it('should return 201 and response data on successful sign-up', async () => {
        const mockUser = { id: 1, email: 'new@example.com', username: 'newuser' };
        (signUpService as jest.Mock).mockResolvedValue({ user: mockUser });

        await signUpController(req as Request, res as Response, next);

        expect(signUpService).toHaveBeenCalledWith(req.body);
        expect(res.status).toHaveBeenCalledWith(201);
        expect(res.json).toHaveBeenCalledWith({
            message: 'Successfully signed up',
            data: mockUser,
        });
    });

    it('should call next with error if service throws an error', async () => {
        const error = new Error('Service error');
        (signUpService as jest.Mock).mockRejectedValue(error);

        await signUpController(req as Request, res as Response, next);

        expect(next).toHaveBeenCalledWith(error);
    });
});

describe('signInController', () => {
    let req: Partial<Request>;
    let res: Partial<Response>;
    let next: NextFunction;

    beforeEach(() => {
        req = { body: { email: 'test@example.com', password: 'password' } };
        res = {
            status: jest.fn().mockReturnThis(),
            json: jest.fn(),
        };
        next = jest.fn();
    });

    it('should return 200 and response data on successful sign-in', async () => {
        const mockResponse = {
            user: { id: 1, email: 'test@example.com', username: 'testuser' },
            accessToken: 'mocked_access_token',
        };
        (signInService as jest.Mock).mockResolvedValue(mockResponse);

        await signInController(req as Request, res as Response, next);

        expect(signInService).toHaveBeenCalledWith(req.body);
        expect(res.status).toHaveBeenCalledWith(200);
        expect(res.json).toHaveBeenCalledWith({
            message: 'Successfully signed in',
            data: mockResponse,
        });
    });

    it('should call next with error if service throws an error', async () => {
        const error = new Error('Invalid credentials');
        (signInService as jest.Mock).mockRejectedValue(error);

        await signInController(req as Request, res as Response, next);

        expect(next).toHaveBeenCalledWith(error);
    });
});
EOL

###################################################################################################

# Create src/tests/modules/auth/auth.service.test.ts
echo "Creating src/tests/modules/auth/auth.service.test.ts..."
cat > src/tests/modules/auth/auth.service.test.ts << EOL
import {
    signUpService,
    signInService,
} from '../../../src/modules/auth/auth.service';
import { CustomError } from '../../../src/utils/custom-error';
import repo from '../../../src/modules/auth/auth.repo';
import { User } from '../../../src/interfaces/user.interfaces';
import { DB } from '../../../src/database';
import { hash, compareSync } from 'bcrypt';
import { validateSignUp, validateSignIn } from '../../../src/modules/auth/auth.validator';
import { generateJWT } from '../../../src/middlewares/jwt.service';

jest.mock('../../../src/modules/auth/auth.repo');
jest.mock('../../../src/database', () => ({
    DB: {
        sequelize: {
            close: jest.fn(),
            authenticate: jest.fn(),
        },
    },
}));

jest.mock('bcrypt', () => ({
    hash: jest.fn(() => Promise.resolve('hashedPassword')),
    compareSync: jest.fn(() => true),
}));

jest.mock('../../../src/modules/auth/auth.validator', () => ({
    validateSignUp: jest.fn(),
    validateSignIn: jest.fn(() => ({ error: null })),
}));

jest.mock('../../../src/middlewares/jwt.service');

afterAll(async () => {
    await DB.sequelize.close();
});

describe('signUpService', () => {
    it('should throw error if email already exists', async () => {
        const userData: User = {
            email: 'existing@example.com',
            name: 'Existing User',
            username: 'existinguser',
            password: 'Password123!',
            created_at: undefined,
            updated_at: undefined,
        };

        (repo.findUserByEmail as jest.Mock).mockResolvedValue({
            id: 1,
            email: 'existing@example.com',
        });

        (validateSignUp as jest.Mock).mockReturnValue({ error: null });

        await expect(signUpService(userData)).rejects.toThrow(
            new CustomError(`Email ${userData.email} already exists`, 409),
        );
    });

    it('should throw error if validation fails', async () => {
        const userData: User = {
            email: 'invalid-email',
            name: 'Invalid User',
            username: 'invaliduser',
            password: 'Password123!',
            created_at: undefined,
            updated_at: undefined,
        };

        const validationError = {
            details: [{ message: 'Email format is invalid' }],
        };
        (validateSignUp as jest.Mock).mockReturnValue({
            error: validationError,
        });

        await expect(signUpService(userData)).rejects.toThrow(
            new CustomError('Email format is invalid', 400),
        );
    });

    it('should create new user if email is available', async () => {
        const userData: User = {
            email: 'new@example.com',
            name: 'New User',
            username: 'newuser',
            password: 'Password123!',
            created_at: undefined,
            updated_at: undefined,
        };

        (repo.findUserByEmail as jest.Mock).mockResolvedValue(null);
        (validateSignUp as jest.Mock).mockReturnValue({ error: null });

        const newUser = {
            id: 1,
            email: 'new@example.com',
            username: 'new-username',
            password: 'hashedPassword',
        };

        (repo.createUser as jest.Mock).mockResolvedValue(newUser);

        const result = await signUpService(userData);
        expect(result).toEqual({ user: newUser });
        expect(hash).toHaveBeenCalledWith(userData.password, 10);
    });
});

describe('signInService', () => {
    const mockUser: User = {
        email: 'test@example.com',
        name: 'Test User',
        username: 'testuser',
        password: 'hashed_password',
        created_at: undefined,
        updated_at: undefined,
    };

    it('should return user and accessToken if credentials are correct', async () => {
        (repo.findUserByEmail as jest.Mock).mockResolvedValue(mockUser);
        (generateJWT as jest.Mock).mockResolvedValue('mocked_access_token');
        jest.spyOn(require('bcrypt'), 'compareSync').mockReturnValue(true);

        const result = await signInService({
            email: 'test@example.com',
            password: 'correct_password',
            name: 'Test User',
            username: 'testuser',
            created_at: undefined,
            updated_at: undefined,
        });

        expect(repo.findUserByEmail).toHaveBeenCalledWith('test@example.com');
        expect(generateJWT).toHaveBeenCalled();
        expect(result).toEqual({
            user: mockUser,
            accessToken: 'mocked_access_token',
        });
    });

    it('should throw 401 error if user is not found', async () => {
        (repo.findUserByEmail as jest.Mock).mockResolvedValue(null);

        await expect(
            signInService({
                email: 'test@example.com',
                password: 'wrong_password',
                name: 'Test User',
                username: 'testuser',
                created_at: undefined,
                updated_at: undefined,
            }),
        ).rejects.toThrow('Email or password is invalid');
    });

    it('should throw 401 error if password is incorrect', async () => {
        (repo.findUserByEmail as jest.Mock).mockResolvedValue(mockUser);
        jest.spyOn(require('bcrypt'), 'compareSync').mockReturnValue(false);

        await expect(
            signInService({
                email: 'test@example.com',
                password: 'wrong_password',
                name: 'Test User',
                username: 'testuser',
                created_at: undefined,
                updated_at: undefined,
            }),
        ).rejects.toThrow('Email or password is invalid');
    });

    it('should throw 400 error if validation fails', async () => {
        (validateSignIn as jest.Mock).mockReturnValue({
            error: { details: [{ message: 'Email and password are required' }] }
        });

        await expect(
            signInService({
                email: '',
                password: '',
                name: '',
                username: '',
                created_at: undefined,
                updated_at: undefined,
            }),
        ).rejects.toThrow('Email and password are required');
    });

});
EOL

###################################################################################################

# Create src/tests/modules/user/user.controller.test.ts
echo "Creating src/tests/modules/user/user.controller.test.ts..."
cat > src/tests/modules/user/user.controller.test.ts << EOL
import { Request, Response, NextFunction } from 'express';
import { getUserProfileController } from '../../../src/modules/user/user.controller';
import { getUserProfileService } from '../../../src/modules/user/user.service';
import { CustomError } from '../../../src/utils/custom-error';

jest.mock('../../../src/modules/user/user.service', () => ({
    getUserProfileService: jest.fn(),
}));

beforeEach(() => {
    jest.clearAllMocks();
});

describe('getUserProfileController', () => {
    let req: Partial<Request>;
    let res: Partial<Response>;
    let next: NextFunction;

    beforeEach(() => {
        req = {
            headers: {
                authorization: 'Bearer mockAccessToken',
            },
        };

        res = {
            status: jest.fn().mockReturnThis(),
            json: jest.fn(),
        };

        next = jest.fn();

        jest.clearAllMocks();
    });

    it('should return user profile when accessToken is valid', async () => {
        const mockUser = {
            id: 'user123',
            email: 'user@example.com',
            username: 'user',
        };
        (getUserProfileService as jest.Mock).mockResolvedValue(mockUser);

        await getUserProfileController(req as Request, res as Response, next);

        expect(getUserProfileService).toHaveBeenCalledWith('mockAccessToken');
        expect(res.status).toHaveBeenCalledWith(200);
        expect(res.json).toHaveBeenCalledWith({
            message: 'User data fetched',
            data: mockUser,
        });
    });

    it('should return 404 if authorization header is missing', async () => {
        req.headers!.authorization = undefined;

        await getUserProfileController(req as Request, res as Response, next);

        expect(res.status).toHaveBeenCalledWith(404);
        expect(res.json).toHaveBeenCalledWith({ message: 'User not found' });
        expect(getUserProfileService).not.toHaveBeenCalled();
    });

    it('should call next with error if getUserProfileService throws an error', async () => {
        const error = new CustomError('Invalid token', 401);
        (getUserProfileService as jest.Mock).mockRejectedValue(error);

        await getUserProfileController(req as Request, res as Response, next);

        expect(getUserProfileService).toHaveBeenCalledWith('mockAccessToken');
        expect(next).toHaveBeenCalledWith(error);
        expect(res.status).not.toHaveBeenCalled();
        expect(res.json).not.toHaveBeenCalled();
    });
});
EOL

###################################################################################################

# Create src/tests/modules/user/user.service.test.ts
echo "Creating src/tests/modules/user/user.service.test.ts..."
cat > src/tests/modules/user/user.service.test.ts << EOL
import { getUserProfileService } from '../../../src/modules/user/user.service';
import { verifyJWT } from '../../../src/middlewares/jwt.service';
import { repo } from '../../../src/modules/user/user.repo';
import { CustomError } from '../../../src/utils/custom-error';
import { JWT_ACCESS_TOKEN_SECRET } from '../../../src/config/index';

jest.mock('../../../src/middlewares/jwt.service');
jest.mock('../../../src/modules/user/user.repo');
jest.mock('../../../src/database', ()=>({
    DB: {
        sequelize: {
            close: jest.fn(),
            authenticate: jest.fn(),
        }
    }
}));

jest.mock('../../../src/config/index', () => ({
    JWT_ACCESS_TOKEN_SECRET: 'mock_secret_key'
}));

beforeEach(() => {
    jest.clearAllMocks();
});

describe('getUserProfileService', () => {
    const mockAccessToken = 'mockAccessToken';
    const mockUserId = 'user123';
    const mockUser = { id: mockUserId, email: 'user@example.com', username: 'user' };

    it('should return user profile when accessToken is valid', async () => {
        (verifyJWT as jest.Mock).mockResolvedValue({ userId: mockUserId });
        (repo.getUserProfile as jest.Mock).mockResolvedValue(mockUser);

        const result = await getUserProfileService(mockAccessToken);

        expect(verifyJWT).toHaveBeenCalledWith(mockAccessToken, JWT_ACCESS_TOKEN_SECRET);
        expect(repo.getUserProfile).toHaveBeenCalledWith(mockUserId);
        expect(result).toEqual(mockUser);
    });

    it('should throw an error if user is not found', async () => {
        (verifyJWT as jest.Mock).mockResolvedValue({ userId: mockUserId });
        (repo.getUserProfile as jest.Mock).mockResolvedValue(null);

        await expect(getUserProfileService(mockAccessToken)).rejects.toThrow(
            new CustomError('User not found', 404),
        );

        expect(verifyJWT).toHaveBeenCalledWith(mockAccessToken, expect.any(String));
        expect(repo.getUserProfile).toHaveBeenCalledWith(mockUserId);
    });

    it('should throw an error if token verification fails', async () => {
        (verifyJWT as jest.Mock).mockRejectedValue(new Error('Invalid token'));

        await expect(getUserProfileService(mockAccessToken)).rejects.toThrow('Invalid token');

        expect(verifyJWT).toHaveBeenCalledWith(mockAccessToken, expect.any(String));
        expect(repo.getUserProfile).not.toHaveBeenCalled();
    });

});
EOL





###################################################################################################

# Create server.ts
echo "Creating server.ts..."
cat > src/server.ts << EOL
// =================IMPORTS START======================//
import express from 'express';
import cors from 'cors';
import morgan from 'morgan';
import csurf from 'csurf';
import helmet from 'helmet';
import cookieParser from 'cookie-parser';
import { environment } from './config';
import routes from './routes';
import { ValidationError } from 'sequelize';


import router from '@routes/routes';
import logger from '@utils/logger';
import { DB } from '@database/index';
import { PORT } from './config';
import { errorHandler } from './utils/error-handler';
import { swaggerSpec, swaggerUi } from './utils/swagger';



// =================VARIABLES START======================//

const isProduction = environment === 'production';
const isDevelopment = environment === 'development';
const isTesting = environment === 'testing';

const appServer = express();
const port = PORT;

const corsOptions = {
    origin: '*',
    optionsSuccessStatus: 200,
};


// =================MIDDLE WARE START======================//


// morgan and cookieParser
appServer.use(morgan('dev'));
appServer.use(cookieParser());


// Enable CORS if productions
if (!isProduction) {
    appServer.use(cors(corsOptions));
    appServer.options('*', cors(corsOptions));
}


// helmet and csurf
appServer.use(helmet.crossOriginResourcePolicy({ policy: "cross-origin" }));
appServer.use(
    csurf({
        cookie: {
            secure: isProduction,
            sameSite: isProduction && "Lax",
            httpOnly: true,
        },
    })
);


// routes
appServer.use(routes);


// Middleware for parsing JSON and URL-encoded bodies
appServer.use(express.json());
appServer.use(express.urlencoded({ extended: true }));

appServer.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));


// Use the router with the /api prefix
appServer.use('/api', router);
appServer.use(errorHandler);

appServer.all('*', (req, res) => {
    res.status(404).json({ message: 'Sorry! Page not found' });
});




// =================ROUTES START======================//


appServer.use((req, res, next) => {
    const startTime = Date.now();

    res.on('finish', () => {
        const duration = Date.now() - startTime;
        const message = `${req.method} ${req.originalUrl} ${res.statusCode} - ${duration}ms`;

        if (res.statusCode >= 500) {
            logger.error(message);
        } else if (res.statusCode >= 400) {
            logger.warn(message);
        } else {
            logger.info(message);
        }
    });

    next();
});






appServer.use((_req, _res, next) => {
    const err: any = new Error("The requested resource couldn't be found.");
    err.title = "Resource Not Found";
    err.errors = ["The requested resource couldn't be found."];
    err.status = 404;
    next(err);
});

appServer.use((err: any, _req, _res, next) => {
    if (err instanceof ValidationError) {
        err.errors = err.errors.map((e) => e.message);
        err.title = 'Validation error';
    }
    next(err);
});

appServer.use((err: any, _req, res, _next) => {
    res.status(err.status || 500);
    console.error(err);
    res.json({
        title: err.title || 'Server Error',
        message: err.message,
        errors: err.errors,
        stack: isProduction ? null : err.stack,
    });
});




// =================SEQUELIZE CONNECT START======================//


DB.sequelize
    .authenticate()
    .then(() => {
        logger.info('Database connected successfully!');
        appServer.listen(port, () => {
            logger.info(`Server is running on http://localhost:${port}`);
        });
    })
    .catch(error => {
        logger.error('Unable to connect to the database:', error);
    });



export default appServer;
EOL





###################################################################################################

# Create .env.example
echo "Creating .env.example..."
cat > .env.example << EOL
PORT=5000
NODE_ENV=env
BASE_URL=base_url

#postgres configuration
DB_PORT=db_port
DB_USERNAME=db_username
DB_PASSWORD=db_password
DB_NAME=db_name
DB_HOST=host
DB_DIALECT=dialect

JWT_ACCESS_TOKEN_SECRET=JWT secret
JWT_EXPIRES_IN=604800
EOL



###################################################################################################

# Function to generate a secure password
generate_secure_password() {
    # Generate base password components
    local uppers=$(openssl rand -base64 32 | tr -dc 'A-Z' | head -c 5)
    local lowers=$(openssl rand -base64 32 | tr -dc 'a-z' | head -c 5)
    local numbers=$(openssl rand -base64 32 | tr -dc '0-9' | head -c 5)
    local specials=$(openssl rand -base64 32 | tr -dc '!@#$%^&()_+{}[]:<>?.' | head -c 5)

    # Combine all components
    local password="${uppers}${lowers}${numbers}${specials}"

    # Shuffle the password
    # Using fold and shuf to properly shuffle the string
    password=$(echo "$password" | fold -w1 | shuf | tr -d '\n')

    # Return exactly 20 characters
    echo "${password:0:20}"
}

# Generate secure password
SECURE_DB_PASSWORD_BASE=$(generate_secure_password)
SECURE_DB_PASSWORD=$SECURE_DB_PASSWORD_BASE


# Create .env.testing file with secure password
echo "Creating .env.testing..."
cat > .env.testing << EOL
PORT=5000
NODE_ENV=testing
BASE_URL=http://localhost:5000/api

#postgres configuration
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=${SECURE_DB_PASSWORD}
DB_NAME=dbtest
DB_HOST=localhost

#Sequelize needs to know what RDBMS we use by reading it as dialect. In this case, we use Postgres.
DB_DIALECT=postgres

# test jwt
JWT_ACCESS_TOKEN_SECRET=1ZelYsfP1o1s0MphEr2R5f3r7pwYto7RJj
JWT_EXPIRES_IN=604800
EOL




###################################################################################################

# Create .eslintignore
echo "Creating .eslintignore..."
cat > .eslintignore << EOL
dist/*
coverage/*
**/*.d.ts
/src/public/
/src/types/
EOL





###################################################################################################

# Create .eslintrc
echo "Creating .eslintrc..."
cat > .eslintrc << EOL
{
    "parser": "@typescript-eslint/parser",
    "extends": [
        "prettier",
        "plugin:@typescript-eslint/recommended",
        "plugin:prettier/recommended"
    ],
    "parserOptions": {
        "ecmaVersion": 2018,
        "sourceType": "module"
    },
    "rules": {
        "@typescript-eslint/explicit-member-accessibility": 0,
        "@typescript-eslint/explicit-function-return-type": 0,
        "@typescript-eslint/no-parameter-properties": 0,
        "@typescript-eslint/interface-name-prefix": 0,
        "@typescript-eslint/explicit-module-boundary-types": 0,
        "@typescript-eslint/no-explicit-any": "off",
        "@typescript-eslint/ban-types": "off",
        "@typescript-eslint/no-var-requires": "off",
        "prettier/prettier": [
            "error",
            {
                "endOfLine": "auto"
            }
        ]
    }
}
EOL


###################################################################################################

# Create .gitignore
echo "Creating .gitignore..."
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
.env.development
.env.production
.env.testing

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







###################################################################################################

# Create .npmignore
echo "Creating .npmignore..."
cat > .npmignore << EOL
# Logs
logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*
.pnpm-debug.log*

# Coverage and testing related
coverage/
*.lcov
.nyc_output/

# Build and distribution folders
build/
dist/
.cache/
out/
.next/
.nuxt/
.vuepress/dist/
.serverless/
.fusebox/
.dynamodb/

# Miscellaneous
node_modules/
jspm_packages/
web_modules/

# Editor specific
.vscode/

# Package manager cache
.npm/
.yarn/
.pnp.*

# Environment files
.env
.env.development
.env.production

# Misc
*.tsbuildinfo
*.tgz
EOL



###################################################################################################

# Create .prettierrc.json
echo "Creating .prettierrc.json..."
cat > .prettierrc.json << EOL
{
  "arrowParens": "avoid",
  "bracketSameLine": true,
  "bracketSpacing": true,
  "tabWidth": 4,
  "singleQuote": true,
  "trailingComma": "all"
}
EOL





###################################################################################################

# Create .sequelizerc
echo "Creating .sequelizerc..."
cat > .sequelizerc << EOL
const path = require('path');

module.exports = {
  config: path.resolve('src/config', 'sequelize-cli.js'),
  'models-path': path.resolve('src/database', 'models'),
  'seeders-path': path.resolve('src/database', 'seeders'),
  'migrations-path': path.resolve('src/database',  'migrations'),
};
EOL



###################################################################################################

# Create buildspec.yml for AWS CodeBuild
echo "Creating buildspec.yml for AWS CodeBuild"
cat > buildspec.yml << EOL
version: 0.2

phases:
  install:
    runtime-versions:
      nodejs: 18
    commands:
      - npm install
  build:
    commands:
      - npm run build
  post_build:
    commands:
      - echo Build completed
artifacts:
  files:
    - '**/*'
EOL



###################################################################################################

# Create jest.config.js
echo "Creating jest.config.js..."
cat > jest.config.js << EOL
module.exports = {
    preset: "ts-jest",
    testEnvironment: "node",
    moduleFileExtensions: ["ts", "js"],
    transform: {
        "^.+\\.ts$": "ts-jest",
    },
    moduleNameMapper: {
        "^@/(.*)$": "<rootDir>/src/$1",
    },
};
EOL




###################################################################################################

# Create LICENSE
echo "Creating LICENSE..."
cat > LICENSE << EOL
MIT License

Copyright (c) 2025 Pius Restiantoro with modifications by Scott Feichter

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




###################################################################################################

# Create nodemon.json
echo "Creating nodemon.json..."
cat > nodemon.json << EOL
{
    "watch": ["src", ".env"],
    "ext": "js,ts,json,yaml",
    "ignore": ["src/logs/*", "src/**/*.{spec,test}.ts"],
    "exec": "ts-node -r tsconfig-paths/register --transpile-only src/server.ts"
}
EOL




###################################################################################################

# Create package.json with scripts and dependencies
echo "Creating package.json..."
cat > package.json << EOL
{
    "name": "${BACKEND_REPO_NAME}",
    "version": "1.0.0",
    "description": "Express-Typescript-Postgres-Sequelize-AWSRDS",
    "main": "server.ts",
    "scripts": {
        "test": "jest",
        "test:watch": "jest --watch",
        "sequelize": "sequelize",
        "sequelize-cli": "sequelize-cli",
        "start": "npm run build && node dist/server.js",
        "dev": "nodemon",
        "start:development": "nodemon ./src/bin/www",
        "start:production": "node ./dist/bin/www",
        "build": "tsc && tsc-alias && echo 'Build Finished! 👍'",
        "lint": "eslint --ignore-path .gitignore --ext .ts src/",
        "lint:fix": "npm run lint -- --fix",
        "migration:generate": "sequelize migration:generate --name",
        "migration": "sequelize db:migrate"
    },
    "author": "Pius Restiantoro and Scott Feichter",
    "license": "MIT",
    "repository": {
        "type": "git",
        "url": "https://github.com/pius706975/express-typescript-sequelize-boilerplate.git"
    },
    "dependencies": {
        "bcrypt": "^5.1.1",
        "cors": "^2.8.5",
        "dotenv": "^16.4.5",
        "express": "^4.21.1",
        "joi": "^17.13.3",
        "jsonwebtoken": "^9.0.2",
        "pg": "^8.13.0",
        "pg-hstore": "^2.3.4",
        "sequelize": "^6.37.4",
        "sequelize-typescript": "^2.1.6",
        "swagger-jsdoc": "^6.2.8",
        "swagger-ui-express": "^5.0.1",
        "tsconfig-paths": "^4.2.0",
        "winston": "^3.15.0",
        "winston-daily-rotate-file": "^5.0.0"
    },
    "devDependencies": {
        "@types/bcrypt": "^5.0.2",
        "@types/cors": "^2.8.17",
        "@types/express": "^5.0.0",
        "@types/jest": "^29.5.14",
        "@types/jsonwebtoken": "^9.0.7",
        "@types/node": "^22.10.5",
        "@types/pg": "^8.11.10",
        "@types/sequelize": "^4.28.20",
        "@types/swagger-jsdoc": "^6.0.4",
        "@types/swagger-ui-express": "^4.1.6",
        "@typescript-eslint/eslint-plugin": "^5.29.0",
        "@typescript-eslint/parser": "^5.29.0",
        "eslint": "^8.20.0",
        "eslint-config-prettier": "^8.5.0",
        "eslint-plugin-prettier": "^4.2.1",
        "jest": "^29.7.0",
        "nodemon": "^3.1.7",
        "prettier": "^2.7.1",
        "sequelize-cli": "^6.6.2",
        "supertest": "^7.0.0",
        "ts-jest": "^29.2.5",
        "ts-node": "^10.9.2",
        "tsc-alias": "^1.8.10",
        "typescript": "^5.7.3"
    }
}
EOL

###################################################################################################

# Create README.md
echo "Creating EADME.md..."
cat > README.md << EOL
# I used Pius' backend boilerplate with some small modifications.

# Here is his README.md :


# 📦 Backend Boilerplate With Express.js - Typescript - Sequelize

This is a simple boilerplate with **Express.js** with a ready-to-use configuration for backend development. You can adjust it according to your requirements.

---

## ✨ Features
- ⚡ [**Express.js**](https://expressjs.com/) as the backend framework
- 📋 [**Swagger**](https://swagger.io/docs/) for API documentations
- 🛠 [**Typescript**](https://www.typescriptlang.org/docs/) for strong type support
- 📄 **Linting** with [**ESlint**](https://eslint.org/docs/latest/) and [**Prettier**](https://prettier.io/docs/en/)

---

## 🚀 Prerequisite

Make sure you have installed the following tools:

- **Node.js** >= v18.x.x
- **npm**

---

## 📥 Installation

1. Clone repository:

   ```bash
   git clone https://github.com/pius706975/express-typescript-sequelize-boilerplate.git
   ```

2. Install the dependencies:

   ```bash
   npm install
   ```

3. Create `.env.development` to store the environment configuration:

   ```bash
   .env.development
   ```

4. Fill the `.env.development` file based on your requirements:

   ```
    PORT = port number
    NODE_ENV = env
    BASE_URL = base url

    DB_PORT = db port
    DB_USERNAME = db username
    DB_PASSWORD = db password
    DB_NAME = db name
    DB_HOST = host
    DB_DIALECT = dialect

    JWT_ACCESS_TOKEN_SECRET = JWT secret
   ```

## 🏃 Run the server and the test

Run the server in the development mode:

```bash
npm run dev
```

Or in the production mode

```bash
npm start
```

Run the test:
- Test all function
   ```bash
   npm run test
   ```
- Test by selecting the file
   ```bash
   npm run test path-to-your-test-file/file.test.ts
   ```
---

## 🛠 Additional

- **Linting and code formatting:**

  ```bash
  npm run lint      # Linting check
  npm run lint:fix  # Formatting code with prettier
  ```

- **Creating DB table:**

  ```bash
  npm run migration:generate --name "create-table-name"
  ```
---

## 📚 API Documentation

Access swagger documentations: [http://localhost:5000/api-docs](http://localhost:5000/api-docs)

Swagger will automatically return the documentations based on route file annotation.

---

## 📂 Project structure

Let's have a look at this structure:

```
├── /node_modules
├── /src
│   ├── /config          # Base configuration such as .env key and sequelize-cli configuration
│   ├── /database
│   │   ├── /migrations  # DB migration files to migrate our DB tables
│   │   └── /models      # DB model files that will be used in the development
│   ├── /docs            # Swagger documentations
│   ├── /interfaces      # Interfaces
│   ├── /logs            # Access logs
│   ├── /middleware      # App middlewares
│   ├── /modules         # App modules
│   │   ├── /auth        #
│   │   ├── /user        # These module directories will store repo, service, controller, routes, and validator files.
│   │   └── /etc         #
│   ├── /routes          # Main route file that store all of the module routes
│   ├── /types           # typescript support
│   ├── /utils           # Utils
│   └── server.js        # Entry point of the app
├── /tests               # Unit test main folder
│   ├── /middleware      # Middleware tests
│   ├── /modules         # Modules tests
├── .env.development     # Development environment variables
├── package.json         # Dependencies and scripts
└── README.md            # Project documentation
```

---

## 🔗 The example of API Request

**POST** a request to `/api/example`:

```bash
curl --request POST   --url http://localhost:5000/api/auth/signup
```

Response:

```json
{
    "message": "Successfully signed up"
}
```

---

## 👨‍💻 Contributor

- Pius Restiantoro - [GitHub](https://github.com/pius706975)
EOL


###################################################################################################

# Create tsconfig.json
echo "Creating tsconfig.json..."
cat > tsconfig.json << EOL
{
    "compilerOptions": {
        "target": "es6",
        "module": "commonjs",
        "outDir": "./dist",
        "rootDir": "./src",
        "baseUrl": "./src",
        "paths": {
            "@/*": ["*"],
            "@routes/*": ["routes/*"],
            "@database/*": ["database/*"],
            "@utils/*": ["utils/*"],
            "@types/*": ["types/*"],
            "@modules/*": ["modules/*"]
        },
        "esModuleInterop": true,
        "typeRoots": ["node_modules/@types"],
        "strict": true,
        "resolveJsonModule": true,
        "skipLibCheck": true,
        "lib": ["esnext", "dom"]
    },
    "include": ["src/**/*.ts", "src/database/models/index.ts"],
    "exclude": ["node_modules"]
}
EOL


###################################################################################################

# Install dependencies
echo "Installing dependencies..."
npm install


###################################################################################################

echo " "
echo "BACKEND SETUP COMPLETE!"
echo " "





#########################################################################################################################
#########################################################################################################################
# AWS: CREATING SERVICES AND CI/CD
#########################################################################################################################
#########################################################################################################################
echo "CREATING AWS SERVICES AND CI/CD..."
echo " "



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


#######################################################################################
# EC2:


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













#######################################################################################
# RDS

# Disable AWS CLI pager
export AWS_PAGER=""

# Exit if any command fails
set -e

# Read from .env file
if [ -f .env ]; then
    # Read DB_PASSWORD from .env file
    DB_PASSWORD=$(grep '^DB_PASSWORD=' .env | cut -d '=' -f2)
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




#########################################################################################################################
#########################################################################################################################
# AWS: LOGING IN TO EC2, MOUNTING EBS, INSTALLING NVM AND NODE.JS
#########################################################################################################################
#########################################################################################################################

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

# Exit the SSH session
exit
EOF

# Check if SSH command was successful
if [ $? -eq 0 ]; then
    echo "Successfully completed setup on EC2 instance"
else
    echo "Error: Setup on EC2 instance failed"
    exit 1
fi
echo " "
echo "Script completed. SSH session terminated."






########################################################################################################################################################
echo " "
echo "YOU HAVE FINISHED THE ENTIRE SETUP SCRIPT!!!!!!!!!!!!!!!!!!!!"
echo " "
echo "Next steps: Set up CI/CD:"
echo "Use AWS GitHub Actions, AWS CodeDeploy, or AWS CodePipeline to connect your EC2/EBS to GitHub repo"
echo " "
echo "Goodbye!"
