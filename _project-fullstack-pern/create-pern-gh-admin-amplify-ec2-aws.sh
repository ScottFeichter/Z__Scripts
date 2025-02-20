#!/bin/bash
export AWS_PAGER=""

#########################################################################################################################
#########################################################################################################################
# ADMIN
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

    # Check GitHub repositories
    local existing_repos=$(gh repo list ScottFeichter --json name --limit 100 | grep -o "\"name\":\"$base_name-[0-9]*\"")

    # Check local directories
    local existing_dirs=$(ls -d "$base_name"* 2>/dev/null)

    local highest_version=1

    # Check versions from GitHub repos
    if [ -n "$existing_repos" ]; then
        local gh_version=$(echo "$existing_repos" | grep -o '[0-9]*$' | sort -n | tail -1)
        if [ "$gh_version" -gt "$highest_version" ]; then
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

    # If we found any existing versions, increment the highest one
    if [ "$highest_version" -gt 0 ]; then
        REPO_VERSION=$((highest_version + 1))
    fi
}

# Check for existing repos and update version if needed
echo "Checking for version..."
check_repo_version

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
echo "Admin setup complete!"
echo ""





#########################################################################################################################
#########################################################################################################################
# FRONTEND
#########################################################################################################################
#########################################################################################################################

# CREATES REACT FRONTEND THEN CREATES GIT LOCAL AND REMOTE AND PUSHES
echo "CREATING FRONTEND..."

# Create the final repo name with the appropriate version
FRONTEND_REPO_NAME="$FRONTEND_NAME_ARG-$CREATE_DATE-$REPO_VERSION"


# Initialize project with Vite
echo "Creating React w Vite project: $FRONTEND_REPO_NAME..."
npm create vite@latest $FRONTEND_REPO_NAME -- --template react -- --skip-git

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

gh repo create "$FRONTEND_REPO_NAME" --public

git remote add origin "https://github.com/ScottFeichter/$FRONTEND_REPO_NAME.git"
git branch -M main
git push -u origin main



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

# Create HomePage component
cat > src/pages/HomePage.tsx << EOL
import { motion } from 'framer-motion';
import { useSelector, useDispatch } from 'react-redux';
import { increment, decrement } from '../store/counterSlice';
import { RootState } from '../store';
import reactLogo from '../assets/react.svg';
import viteLogo from '/vite.svg';

const HomePage = () => {
  const count = useSelector((state: RootState) => state.counter.value);
  const dispatch = useDispatch();

  return (
    <div style={{ textAlign: 'center', padding: '2rem', marginTop: '30vh' }}>
      <div style={{ display: 'flex', justifyContent: 'center', gap: '2rem', marginBottom: '2rem' }}>
        <motion.div animate={{ rotateY: 360 }} transition={{ duration: 2, repeat: Infinity, ease: "linear" }}>
          <img src={viteLogo} alt="Vite logo" style={{ height: '8rem' }} />
        </motion.div>
        <motion.div animate={{ rotate: 360 }} transition={{ duration: 4, repeat: Infinity, ease: "linear" }}>
          <img src={reactLogo} alt="React logo" style={{ height: '8rem' }} />
        </motion.div>
      </div>
      <div style={{ marginTop: '2rem' }}>
        <h2 style={{ marginBottom: '2rem' }}>Count: {count}</h2>
        <button onClick={() => dispatch(decrement())}>Decrement</button>
        <button onClick={() => dispatch(increment())}>Increment</button>
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
    # Note: This gets the token used by gh cli
    TOKEN=$(gh auth token)

    # Print results
    echo " "
    echo "Repository Information:"
    echo "======================"
    echo "Name: $FRONTEND_REPO_NAME"
    echo "URL: $FRONTEND_REPO_URL"
    echo "Token: $TOKEN"
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




# Create a new Amplify app connected to GitHub
echo "Creating Amplify app..."
APP_ID=$(aws amplify create-app \
    --name "${FRONTEND_REPO_NAME}" \
    --repository "${FRONTEND_REPO_URL}" \
    --oauth-token "${TOKEN}" \
    --access-token "${TOKEN}" \
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
fi

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
# BACKEND
#########################################################################################################################
#########################################################################################################################


# CREATES NODE BACKENDEND THEN CREATES GIT LOCAL AND REMOTE AND PUSHES
echo "CREATING BACKEND..."
echo " "

# Create the final repo name with the appropriate version
BACKEND_REPO_NAME="$BACKEND_NAME_ARG-$CREATE_DATE-$REPO_VERSION"

# Create directory and initialize repository
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


# Initialize npm project
echo " "
echo "Initializing npm project..."
npm init -y

# Install dependencies
echo "Installing dependencies..."
npm install \
    bcryptjs \
    cookie-parser \
    cors \
    csurf \
    dotenv \
    express \
    express-async-errors \
    express-validator \
    helmet \
    jsonwebtoken \
    morgan \
    per-env \
    pg \
    sequelize \
    sequelize-cli

# Install development dependencies
echo "Installing development dependencies..."
npm install --save-dev \
    @types/bcryptjs \
    @types/cookie-parser \
    @types/cors \
    @types/csurf \
    @types/express \
    @types/helmet \
    @types/jsonwebtoken \
    @types/morgan \
    @types/node \
    @types/sequelize \
    dotenv-cli \
    nodemon \
    ts-node \
    typescript

# Update package.json with scripts and dependencies
cat > package.json << EOL
{
  "name": "\${BACKEND_REPO_NAME}",
  "version": "1.0.0",
  "description": "",
  "main": "dist/index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "sequelize": "sequelize",
    "sequelize-cli": "sequelize-cli",
    "start": "per-env",
    "start:development": "nodemon ./src/bin/www",
    "start:production": "node ./dist/bin/www",
    "build": "tsc"
  },
  "keywords": [],
  "author": "",
  "license": "ISC"
}
EOL

# Create directory structure
mkdir -p src/bin src/config src/db/migrations src/db/models src/db/seeders src/routes src/utils dist

# Create tsconfig.json
cat > tsconfig.json << EOL
{
  "compilerOptions": {
    "target": "ES6",
    "module": "CommonJS",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true
  }
}
EOL

# Create main application file
cat > src/app.ts << EOL
import express from 'express';
import morgan from 'morgan';
import cors from 'cors';
import csurf from 'csurf';
import helmet from 'helmet';
import cookieParser from 'cookie-parser';
import { environment } from './config';
import routes from './routes';
import { ValidationError } from 'sequelize';

// =================IMPORTS END======================//

const isProduction = environment === 'production';

const app = express();

// =================MIDDLE WARE START======================//

app.use(morgan('dev'));
app.use(cookieParser());
app.use(express.json());

if (!isProduction) {
    app.use(cors());
}

app.use(helmet.crossOriginResourcePolicy({ policy: "cross-origin" }));
app.use(
    csurf({
        cookie: {
            secure: isProduction,
            sameSite: isProduction && "Lax",
            httpOnly: true,
        },
    })
);

app.use(routes);

// =================MIDDLE WARE END======================//

app.use((_req, _res, next) => {
    const err: any = new Error("The requested resource couldn't be found.");
    err.title = "Resource Not Found";
    err.errors = ["The requested resource couldn't be found."];
    err.status = 404;
    next(err);
});

app.use((err: any, _req, _res, next) => {
    if (err instanceof ValidationError) {
        err.errors = err.errors.map((e) => e.message);
        err.title = 'Validation error';
    }
    next(err);
});

app.use((err: any, _req, res, _next) => {
    res.status(err.status || 500);
    console.error(err);
    res.json({
        title: err.title || 'Server Error',
        message: err.message,
        errors: err.errors,
        stack: isProduction ? null : err.stack,
    });
});

export default app;
EOL



# Create www file
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

# Create config file
cat > src/config/index.js << EOL
export default {
    environment: process.env.NODE_ENV || 'development',
    port: process.env.PORT || 5000,
    db: {
        username: process.env.DB_USERNAME || '',
        password: process.env.DB_PASSWORD || '',
        database: process.env.DB_DATABASE || '',
        host: process.env.DB_HOST || '',
    },
    jwtConfig: {
        secret: process.env.JWT_SECRET || '',
        expiresIn: process.env.JWT_EXPIRES_IN || '604800',
    },
};
EOL

# Create database config file
cat > src/config/database.js << EOL
import config from './index';

export default {
    development: {
        username: config.db.username,
        password: config.db.password,
        database: config.db.database,
        host: config.db.host,
        dialect: 'postgres',
    },
    production: {
        use_env_variable: 'DATABASE_URL',
        dialect: 'postgres',
        seederStorage: 'sequelize',
        dialectOptions: {
            ssl: {
                require: true,
                rejectUnauthorized: false,
            },
        },
    },
};
EOL

# Create .sequelizerc file
cat > .sequelizerc << EOL
const path = require('path');

module.exports = {
  'config': path.resolve('config', 'database.js'),
  'models-path': path.resolve('db', 'models'),
  'seeders-path': path.resolve('db', 'seeders'),
  'migrations-path': path.resolve('db', 'migrations')
};
EOL

# Create psql setup script
cat > psql-setup-script.ts << EOL
import { sequelize } from './db/models';

(async () => {
    const schemas = await sequelize.showAllSchemas({ logging: false });
    if (!schemas.includes(process.env.SCHEMA)) {
        await sequelize.createSchema(process.env.SCHEMA);
    }
})();
EOL

# Create routes index file
cat > src/routes/index.ts << EOL
import express from 'express';

const router = express.Router();

# TWO TEST ROUTES AND A RESTORE

router.get('/api/test', (req, res) => {
    res.json({ message: 'Success' });
});

router.get('/hello/world', (req: Request, res: Response) => {
  res.cookie('XSRF-TOKEN', req.csrfToken());
  res.send('Hello World!');
});

router.get('/api/csrf/restore', (req: Request, res: Response) => {
  const csrfToken = req.csrfToken();
  res.cookie('XSRF-TOKEN', csrfToken);
  res.status(200).json({
    'XSRF-Token': csrfToken,
  });
});


export default router;
EOL

# Create .gitignore
cat > .gitignore << EOL
node_modules
.env
.DS_Store
dist/
EOL

echo "Finished .gitignore"

# Initialize Sequelize
npx sequelize-cli init || true

# Create buildspec.yml for AWS CodeBuild
echo " "
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

echo " "
echo "Backend setup complete!"
echo " "




#########################################################################################################################
#########################################################################################################################
# AWS SERVICES CI/CD
#########################################################################################################################
#########################################################################################################################
echo "Creating AWS Services and CI/CD..."
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

# Ask for confirmation before proceeding
read -p "Do you want to proceed with this configuration? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation cancelled"
    exit 1
fi


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






#######################################################################################
# LOGING IN TO EC2, MOUNTING EBS, INSTALLING NVM AND NODE.JS
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

ssh -i "${KEY_PAIR_NAME}.pem" "ec2-user@${PUBLIC_IP}" << 'EOF'
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
