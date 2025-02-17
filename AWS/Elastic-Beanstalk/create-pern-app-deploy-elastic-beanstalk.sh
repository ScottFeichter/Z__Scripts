#!/bin/bash

##########################
# To use this script:

# 1. Save it as create-pern-app.sh

# 2. Make it executable: chmod +x create-pern-app.sh

# 3. Run it w argument: ./create-pern-app.sh $project-name

###########################################
# After running the script, you'll need to:

# 1. Configure your PostgreSQL database credentials in the .env file

# 2. Install AWS CLI and configure your AWS credentials

# 3. Create an RDS instance for PostgreSQL in AWS

# 4. Update the production database configuration with RDS credentials


#######################
# To start development:

# ./start.sh


#######################
# To deploy to AWS:

# ./deploy.sh


#######################
# The script sets up:

# A Node/Express backend with Sequelize ORM

# A React frontend with Vite

# Security middleware (helmet, cors, rate-limiting)

# Basic project structure

# AWS Elastic Beanstalk configuration

# Development and deployment scripts


#######################
# Remember to:

# Keep sensitive information in environment variables

# Set up proper security groups in AWS

# Configure SSL/TLS for production

# Set up proper database backup strategies

# Implement proper authentication/authorization

# Add error handling and logging

# Set up CI/CD pipelines as needed

# This is a basic setup that you can build upon based on your specific requirements.






# This needs to be vetted.

# - It uses pip for elb cli and various things and therefore needs to use virtual environment.
# - After running the script, the EB CLI will be available within the virtual environment.
# - When you need to use the EB CLI in the future, you'll need to activate the virtual environment first:
#      source eb-venv/bin/activate

############################################################################################

# After deploying with Elastic Beanstalk, you can access your application in several ways:

# - Through the AWS Management Console:
#   1. Go to the Elastic Beanstalk service
#   2. Find your application "pern-stack-app"
#   3. Click on the environment "pern-stack-app-env"
#   4. You'll see a URL at the top of the page that looks like: pern-stack-app-env.xxxxxx.region.elasticbeanstalk.com

# - Through the EB CLI: Run these commands in your terminal:
#   1. eb status    # Shows environment info including the URL
#   2. eb open      # Opens the application in your default browser


############################################################################################

# To see deployment status and logs:

# eb health    # Shows environment health
# eb logs      # Shows application logs


############################################################################################

# If you need to make changes to your application:

# - Make your changes locally
# - Commit your changes if using git
# - Deploy the updates using:
#   - eb deploy

# Copy

# Remember that your application needs to be properly configured to listen on port 8080 (Elastic Beanstalk's default port) or the port specified by process.env.PORT.




# THE SCRIPT:
#######################

dir_name=$1



export AWS_PAGER=""


# Create project
echo "Creating project..."

mkdir $dir_name
cd $dir_name


# Initializ git
echo "Initializing git local and remote..."

git init
touch README.md
git add .
git commit -m "initial (msg via shell)"

gh repo create $dir_name --public

git remote add origin https://github.com/ScottFeichter/$dir_name.git
git branch -M main
git push -u origin main


# Create project directories
echo "Creating project structure..."


# Initialize main project
npm init -y

# Create frontend and backend directories
mkdir frontend backend
cd backend

# Initialize backend
echo "Setting up backend..."
npm init -y
npm install express pg pg-hstore sequelize cors dotenv helmet express-rate-limit

# Create backend structure
mkdir src src/models src/controllers src/routes src/config

# Create basic backend files
cat > src/config/database.js << EOL
require('dotenv').config();

module.exports = {
  development: {
    username: process.env.DB_USERNAME,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    host: process.env.DB_HOST,
    dialect: 'postgres'
  },
  production: {
    username: process.env.DB_USERNAME,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    host: process.env.DB_HOST,
    dialect: 'postgres'
  }
};
EOL

# Create main server file
cat > src/index.js << EOL
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const { Sequelize } = require('sequelize');
const config = require('./config/database');

const app = express();

// Middleware
app.use(cors());
app.use(helmet());
app.use(express.json());

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});
app.use(limiter);

// Database connection
const sequelize = new Sequelize(config[process.env.NODE_ENV || 'development']);

// Test database connection
sequelize.authenticate()
  .then(() => console.log('Database connected successfully'))
  .catch(err => console.error('Unable to connect to the database:', err));

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(\`Server running on port \${PORT}\`));
EOL

# Create .env file
cat > .env << EOL
DB_USERNAME=postgres
DB_PASSWORD=your_password
DB_NAME=pern_db
DB_HOST=localhost
PORT=5000
NODE_ENV=development
EOL

# Initialize Sequelize
npx sequelize-cli init

# Move to frontend directory and setup React with Vite
cd ../frontend
npm create vite@latest . -- --template react
npm install
npm install axios @reduxjs/toolkit react-redux react-router-dom

# Create basic frontend structure
mkdir src/components src/pages src/services src/store



# Create start script
cat > start.sh << EOL


# Start development servers
echo "Starting development servers..."

# Start backend
cd backend
npm run dev &

# Start frontend
cd ../frontend
npm run dev
EOL

chmod +x start.sh
chmod +x deploy.sh


# Create README
cat > README.md << EOL

# PERN Stack Application

## Setup Instructions

1. Install dependencies:
   \`\`\`bash
   cd backend && npm install
   cd ../frontend && npm install
   \`\`\`

2. Configure environment variables in \`backend/.env\`

3. Start development servers:
   \`\`\`bash
   ./start.sh
   \`\`\`

## Deployment

1. Configure AWS credentials:
   \`\`\`bash
   aws configure
   \`\`\`

2. Deploy to AWS:
   \`\`\`bash
   ./deploy.sh
   \`\`\`
EOL

# Initialize gitignore and add files
echo "Creating gitignore and adding files..."
cat > .gitignore << EOL
node_modules
.env
.DS_Store
dist
build
.elasticbeanstalk/*
!.elasticbeanstalk/config.yml
EOL

echo "GIT: Staging, commiting, and pushing to local and remote..."

git add -A
git commit -m "Adding project files. Automated message from the shell."
git push


echo "Project setup complete!"


cd ..


# AWS Elastic Beanstalk deployment script
echo "Preparing for AWS deployment..."


# Install AWS CLI if not installed
if ! command -v aws &> /dev/null; then
    echo "Installing AWS CLI..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
fi


# First, ensure Python 3 is installed and accessible
if ! command -v python3 &> /dev/null; then
    echo "Python 3 is not installed. Please install Python 3 first."
    exit 1
fi


# Create and activate a virtual environment to avoid system-wide package conflicts
echo "Setting up Python virtual environment..."
python3 -m venv eb-venv


# Source the virtual environment based on the shell
if [[ "$SHELL" == */zsh ]]; then
    source eb-venv/bin/activate
else
    . eb-venv/bin/activate
fi


# Upgrade pip within the virtual environment
echo "Upgrading pip..."
python3 -m pip install --upgrade pip


# Install EB CLI in the virtual environment
echo "Installing EB CLI..."
python3 -m pip install awsebcli


# Verify EB CLI installation
if ! command -v eb &> /dev/null; then
    echo "Adding eb-venv/bin to PATH..."
    export PATH="$PWD/eb-venv/bin:$PATH"
fi


# Test EB CLI installation
if ! command -v eb &> /dev/null; then
    echo "EB CLI installation failed. Please install manually."
    exit 1
fi



# Add this section before the eb init command in your script

echo "Verifying and creating required IAM roles..."

# Create trust policy documents
cat > eb-service-role-trust.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "elasticbeanstalk.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

cat > eb-ec2-role-trust.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

# Function to create service role if it doesn't exist
create_service_role() {
    if ! aws iam get-role --role-name aws-elasticbeanstalk-service-role 2>/dev/null; then
        echo "Creating Elastic Beanstalk service role..."
        aws iam create-role \
            --role-name aws-elasticbeanstalk-service-role \
            --assume-role-policy-document file://eb-service-role-trust.json

        # Attach required policies
        aws iam attach-role-policy \
            --role-name aws-elasticbeanstalk-service-role \
            --policy-arn arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkService

        aws iam attach-role-policy \
            --role-name aws-elasticbeanstalk-service-role \
            --policy-arn arn:aws:iam::aws:policy/AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy

        echo "Elastic Beanstalk service role created successfully"
    else
        echo "Elastic Beanstalk service role already exists"
    fi
}

# Function to create EC2 instance profile if it doesn't exist
create_instance_profile() {
    if ! aws iam get-role --role-name aws-elasticbeanstalk-ec2-role 2>/dev/null; then
        echo "Creating EC2 instance role..."
        aws iam create-role \
            --role-name aws-elasticbeanstalk-ec2-role \
            --assume-role-policy-document file://eb-ec2-role-trust.json

        # Attach required policies
        aws iam attach-role-policy \
            --role-name aws-elasticbeanstalk-ec2-role \
            --policy-arn arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier

        aws iam attach-role-policy \
            --role-name aws-elasticbeanstalk-ec2-role \
            --policy-arn arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker

        aws iam attach-role-policy \
            --role-name aws-elasticbeanstalk-ec2-role \
            --policy-arn arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier

        # Create instance profile
        aws iam create-instance-profile \
            --instance-profile-name aws-elasticbeanstalk-ec2-role 2>/dev/null || true

        # Add role to instance profile
        aws iam add-role-to-instance-profile \
            --instance-profile-name aws-elasticbeanstalk-ec2-role \
            --role-name aws-elasticbeanstalk-ec2-role 2>/dev/null || true

        echo "EC2 instance role and profile created successfully"
    else
        echo "EC2 instance role already exists"
    fi
}

# Create the roles and profiles
create_service_role
create_instance_profile

# Clean up JSON files
rm -f eb-service-role-trust.json eb-ec2-role-trust.json

# Add option settings for the roles to the existing Elastic Beanstalk configuration
cat > .elasticbeanstalk/additional-options.json << EOF
[
    {
        "Namespace": "aws:autoscaling:launchconfiguration",
        "OptionName": "IamInstanceProfile",
        "Value": "aws-elasticbeanstalk-ec2-role"
    },
    {
        "Namespace": "aws:elasticbeanstalk:environment",
        "OptionName": "ServiceRole",
        "Value": "aws-elasticbeanstalk-service-role"
    }
]
EOF

# Modify your existing eb create command to include these options
# Find the line with 'eb create' and modify it to:
eb create $dir_name-env \
    --instance-type t2.micro \
    --platform "node.js-18" \
    --region us-east-1 \
    --option-settings file://.elasticbeanstalk/additional-options.json

# Clean up additional options file
rm -f .elasticbeanstalk/additional-options.json



# Initialize Elastic Beanstalk (only proceed if eb command is available)
if command -v eb &> /dev/null; then
    # Initialize Elastic Beanstalk with specific Node.js platform branch
    echo "Initializing Elastic Beanstalk..."
    eb init $dir_name --platform "node.js-18" --region us-east-1

    # Create Elastic Beanstalk configuration
    mkdir -p .elasticbeanstalk
    cat > .elasticbeanstalk/config.yml << EOF
branch-defaults:
  main:
    environment: $dir_name-env
global:
  application_name: $dir_name
  default_region: us-east-1
  profile: null
  sc: git
EOF

    # Create Profile
    echo "web: node backend/src/index.js" > Procfile

    # Create .ebignore
    cat > .ebignore << EOF
.git
.gitignore
.env
node_modules
frontend/node_modules
EOF

    # Create the Elastic Beanstalk environment
    echo "Creating Elastic Beanstalk environment..."
    eb create $dir_name-env \
        --instance-type t2.micro \
        --platform "node.js-18" \
        --region us-east-1 \
        --nohang

    # Wait for environment to be ready
    echo "Waiting for environment to be ready..."
    eb status

    # Display the application URL
    echo "Opening application in default browser..."
    eb open

else
    echo "EB CLI is not available in PATH. Installation may have failed."
    exit 1
fi

echo "Setup complete!"

# Deactivate the virtual environment
deactivate



echo "Opening project in VScode..."

code .

echo "All finished!"
