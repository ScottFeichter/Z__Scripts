#!/bin/sh


#########################################################################################################################
#########################################################################################################################
# FRONTEND
#########################################################################################################################
#########################################################################################################################


export AWS_PAGER=""

#########################################################################################################################
# CHECKS FOR LOCAL AND REMOTE GITHUB AND CREATES NAME WITH DATE A VERSION

# Check if repo name is provided
if [ -z "$1" ]; then
    echo "Please provide a repo name"
    echo "Usage: ./create-repo-local-and-remote.sh my-repo"
    exit 1
fi

NAME_ARG=$1-frontend
CREATE_DATE=$(date '+%m-%d-%Y')
REPO_VERSION=1

# Function to check if repository exists and get latest version
check_repo_version() {
    local base_name="$NAME_ARG-$CREATE_DATE"

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
check_repo_version

# Create the final repo name with the appropriate version
REPO_NAME="$NAME_ARG-$CREATE_DATE-$REPO_VERSION"



#########################################################################################################################
# CREATES REACT FRONTEND THEN CREATES GIT LOCAL AND REMOTE AND PUSHES

# Check if project name is provided
if [ -z "$1" ]; then
    echo "Please provide a project name"
    echo "Usage: ./create-react-redux-vite-frontend.sh my-app"
    exit 1
fi


# Initialize project with Vite
echo "Creating React w Vite project: $REPO_NAME..."
npm create vite@latest $REPO_NAME -- --template react -- --skip-git
cd $REPO_NAME


# Install core dependencies
echo "Installing core dependencies..."
npm install

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
    framer-motion

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
cat > src/store/counterSlice.js << EOL
import { createSlice } from '@reduxjs/toolkit';

export const counterSlice = createSlice({
  name: 'counter',
  initialState: {
    value: 0,
  },
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


cat > src/store/index.js << EOL
import { configureStore } from '@reduxjs/toolkit';
import counterReducer from './counterSlice';

export const store = configureStore({
  reducer: {
    counter: counterReducer,
  },
});
EOL


# Create main style file
cat > src/styles/main.scss << EOL
*,
*::before,
*::after {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
    'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
    sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  background-color: #FFFFFF;
  color: #242424;  /* Dark text for contrast on white background */
}

#root {
  max-width: 1280px;
  margin: 0 auto;
  padding: 2rem;
  text-align: center;
}
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
    config.headers.Authorization = \`Bearer \${token}\`;
  }
  return config;
});

export default api;
EOL

# Create sample component
cat > src/components/Layout.jsx << EOL
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


# Add this to create the HomePage component
cat > src/pages/HomePage.jsx << EOL
import { motion } from 'framer-motion';
import { useSelector, useDispatch } from 'react-redux';
import { increment, decrement } from '../store/counterSlice';
import reactLogo from '../assets/react.svg';
import viteLogo from '/vite.svg';


const HomePage = () => {
  const count = useSelector((state) => state.counter.value);
  const dispatch = useDispatch();

  const buttonStyle = {
    padding: '1rem 1rem',
    fontSize: '1.2rem',
    borderRadius: '8px',
    border: '1px solid transparent', // Add transparent border by default
    backgroundColor: '#F9F9F9',
    color: 'black',
    cursor: 'pointer',
    marginTop: '1rem',
    margin: '0 0.5rem'
  };


  return (
    <div style={{
      textAlign: 'center',
      padding: '2rem',
      marginTop: '30vh'
    }}>



      <div style={{ display: 'flex', justifyContent: 'center', gap: '2rem', marginBottom: '2rem' }}>
        <motion.div
          animate={{ rotateY: 360 }}
          transition={{ duration: 2, repeat: Infinity, ease: "linear" }}
        >
          <img src={viteLogo} alt="Vite logo" style={{ height: '8rem' }} />
        </motion.div>
        <motion.div
          animate={{ rotate: 360 }}
          transition={{ duration: 4, repeat: Infinity, ease: "linear" }}
        >
          <img src={reactLogo} alt="React logo" style={{ height: '8rem' }} />
        </motion.div>
      </div>

      <div style={{ marginTop: '2rem' }}>
        <h2 style={{ marginBottom: '2rem' }}>Count: {count}</h2>
        <div style={{ display: 'flex', justifyContent: 'center', gap: '1rem' }}>
          <motion.button
            whileHover={{
              scale: 1.1,
              border: '2px solid purple' // Add purple border on hover
            }}
            whileTap={{ scale: 0.9 }}
            style={buttonStyle}
            onClick={() => dispatch(decrement())}
          >
            Decrement
          </motion.button>

          <motion.button
            whileHover={{
              scale: 1.1,
              border: '2px solid purple' // Add purple border on hover
            }}
            whileTap={{ scale: 0.9 }}
            style={buttonStyle}
            onClick={() => dispatch(increment())}
          >
            Increment
          </motion.button>

        </div>
      </div>
    </div>
  );
};

export default HomePage;
EOL




# Create router setup
cat > src/router.jsx << EOL
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


# Update main.jsx
cat > src/main.jsx << EOL
import React from 'react';
import ReactDOM from 'react-dom/client';
import { Provider } from 'react-redux';
import { RouterProvider } from 'react-router-dom';
import { store } from './store';
import { router } from './router';
import './styles/main.scss';

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <Provider store={store}>
      <RouterProvider router={router} />
    </Provider>
  </React.StrictMode>
);
EOL



# Create environment files
cat > .env << EOL
VITE_API_URL=http://localhost:3000
EOL

cat > .env.example << EOL
VITE_API_URL=http://localhost:3000
EOL



# Update .gitignore
cat >> .gitignore << EOL
# Environment files
.env
.env.local
.env.*.local

# Editor directories
.vscode
.idea

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db
EOL



# Update package.json scripts
npm pkg set scripts.dev="vite"
npm pkg set scripts.build="vite build"
npm pkg set scripts.preview="vite preview"
npm pkg set scripts.lint="eslint src --ext js,jsx --report-unused-disable-directives --max-warnings 0"
npm pkg set scripts.format="prettier --write 'src/**/*.{js,jsx,css,scss}'"



# Initializing git repository
echo "Initializing git local and remote..."

git init
cat > README.md << EOL
react front end for $REPO_NAME
EOL

git add .
git commit -m "initial (msg via shell)"

gh repo create $REPO_NAME --public

git remote add origin https://github.com/ScottFeichter/$REPO_NAME.git
git branch -M main
git push -u origin main


echo "
Project setup complete! 🚀

Project structure:
├── src/
│   ├── components/     # Reusable components
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
1. cd $REPO_NAME
2. npm run dev

Happy coding! 🎉"





#########################################################################################################################
# Check if gh cli is installed

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
    if ! gh repo view "ScottFeichter/$REPO_NAME" &> /dev/null; then
        echo "Repository not found: ScottFeichter/$REPO_NAME"
        exit 1
    fi

    # Get repository URL
    REPO_URL=$(gh repo view "ScottFeichter/$REPO_NAME" --json url -q .url)

    # Get authentication token
    # Note: This gets the token used by gh cli
    TOKEN=$(gh auth token)

    # Print results
    echo "Repository Information:"
    echo "======================"
    echo "Name: $REPO_NAME"
    echo "URL: $REPO_URL"
    echo "Token: $TOKEN"




#########################################################################################################################
# CREATES AMPLIFY APP FROM REPO
export AWS_PAGER=""  # Disable the AWS CLI pager

# Exit on any error
set -e

# Check if required parameters are provided
if [ -z "$REPO_NAME" ] || [ -z "$REPO_URL" ] || [ -z "$TOKEN" ]; then
    echo "Usage: $0 <app-name> <github-repo-url> <github-access-token>"
    echo "Example: $0 'My App' 'https://github.com/username/repo' 'ghp_xxxxxxxxxxxx'"
    exit 1
fi

echo "Starting Amplify deployment process..."

# Get the current timestamp for unique app name




# Create a new Amplify app connected to GitHub
echo "Creating Amplify app..."
APP_ID=$(aws amplify create-app \
    --name "${REPO_NAME}" \
    --repository "${REPO_URL}" \
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
echo "Getting app information..."
FULL_URL=$(aws amplify get-app --app-id "${APP_ID}" --query 'app.defaultDomain' --output text)
FULL_URL="https://main.${FULL_URL}"
echo "App ID: ${APP_ID}"
echo "App URL: ${FULL_URL}"

cd ..


#########################################################################################################################
#########################################################################################################################
# BACKEND
#########################################################################################################################
#########################################################################################################################



# Here's a script that creates a Node.js backend project structure suitable for AWS CodePipeline.

# THIS SCRIPT REQUIRES AN ARGUMENT FOR THE PROJECT/REPO NAME.

# IT ADDS THE DATE AND VERSION AUTOMATICALLY.

# The script creates:

    # git/github local and remote

    # Complete project structure

    # Configuration files for Express and Sequelize

    # Basic error handling

    # Environment configuration

    # AWS CodeBuild specification

    # Database configuration

    # Basic API route setup

    # Security middleware configuration


#######################################################################################
# THE SCRIPT:


# Check if repo name is provided
if [ -z "$1" ]; then
    echo "Please provide a repo name"
    echo "Usage: ./create-repo-local-and-remote.sh my-repo"
    exit 1
fi

BACK_NAME_ARG=$1-backend


# Create the final repo name with the appropriate version
BACK_REPO_NAME="$BACK_NAME_ARG-$CREATE_DATE-$REPO_VERSION"

# Create directory and initialize repository
mkdir "$BACK_REPO_NAME"
cd "$BACK_REPO_NAME"

git init
touch README.md
git add .
git commit -m "initial (msg via shell)"

gh repo create "$BACK_REPO_NAME" --public

git remote add origin "https://github.com/ScottFeichter/$BACK_REPO_NAME.git"
git branch -M main
git push -u origin main








# Initialize npm project
echo "Initializing npm project..."
npm init -y

# Update package.json with scripts and dependencies
cat > package.json << EOL
{
  "name": "${BACK_REPO_NAME}",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "sequelize": "sequelize",
    "sequelize-cli": "sequelize-cli",
    "start": "per-env",
    "start:development": "nodemon ./bin/www",
    "start:production": "node ./bin/www",
    "build": "node psql-setup-script.js"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "dependencies": {
    "bcryptjs": "^2.4.3",
    "cookie-parser": "^1.4.6",
    "cors": "^2.8.5",
    "csurf": "^1.11.0",
    "dotenv": "^16.4.5",
    "express": "^4.19.2",
    "express-async-errors": "^3.1.1",
    "express-validator": "^7.2.0",
    "helmet": "^7.1.0",
    "jsonwebtoken": "^9.0.2",
    "morgan": "^1.10.0",
    "per-env": "^1.0.2",
    "pg": "^8.12.0",
    "sequelize": "^6.37.3",
    "sequelize-cli": "^6.6.2"
  },
  "devDependencies": {
    "dotenv-cli": "^7.4.1",
    "nodemon": "^3.1.0"
  }
}
EOL

# Install dependencies
echo "Installing dependencies..."
npm install

# Create directory structure
mkdir -p bin config db/migrations db/models db/seeders routes utils

# Create main application file
cat > app.js << EOL
const express = require('express');
const morgan = require('morgan');
const cors = require('cors');
const csurf = require('csurf');
const helmet = require('helmet');
const cookieParser = require('cookie-parser');
const { environment } = require('./config');
const routes = require('./routes');
const { ValidationError } = require('sequelize');

const isProduction = environment === 'production';

const app = express();

app.use(morgan('dev'));
app.use(cookieParser());
app.use(express.json());

// Security Middleware
if (!isProduction) {
    // enable cors only in development
    app.use(cors());
}

// helmet helps set a variety of headers to better secure your app
app.use(helmet.crossOriginResourcePolicy({ policy: "cross-origin" }));

// Set the _csrf token and create req.csrfToken method
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

// Error handling middleware
app.use((_req, _res, next) => {
    const err = new Error("The requested resource couldn't be found.");
    err.title = "Resource Not Found";
    err.errors = ["The requested resource couldn't be found."];
    err.status = 404;
    next(err);
});

app.use((err, _req, _res, next) => {
    // check if error is a Sequelize error:
    if (err instanceof ValidationError) {
        err.errors = err.errors.map((e) => e.message);
        err.title = 'Validation error';
    }
    next(err);
});

app.use((err, _req, res, _next) => {
    res.status(err.status || 500);
    console.error(err);
    res.json({
        title: err.title || 'Server Error',
        message: err.message,
        errors: err.errors,
        stack: isProduction ? null : err.stack,
    });
});

module.exports = app;
EOL

# Create www file
cat > bin/www << EOL
#!/usr/bin/env node

const { port } = require('../config');
const app = require('../app');
const db = require('../db/models');

db.sequelize
    .authenticate()
    .then(() => {
        console.log('Database connection success! Sequelize is ready to use...');
        app.listen(port, () => console.log(\`Listening on port \${port}...\`));
    })
    .catch((err) => {
        console.log('Database connection failure.');
        console.error(err);
    });
EOL

# Make www executable
chmod +x bin/www

# Create config file
cat > config/index.js << EOL
module.exports = {
    environment: process.env.NODE_ENV || 'development',
    port: process.env.PORT || 5000,
    db: {
        username: process.env.DB_USERNAME,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_DATABASE,
        host: process.env.DB_HOST,
    },
    jwtConfig: {
        secret: process.env.JWT_SECRET,
        expiresIn: process.env.JWT_EXPIRES_IN,
    },
};
EOL

# Create database config file
cat > config/database.js << EOL
const config = require('./index');

module.exports = {
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


# Create .env file with secure password
cat > .env << EOL
PORT=5000
DB_USERNAME=postgres
DB_PASSWORD=${SECURE_DB_PASSWORD}
DB_DATABASE=your_database_name
DB_HOST=localhost
JWT_SECRET=your_jwt_secret_here
JWT_EXPIRES_IN=604800
EOL

echo "Created .env file with secure database password"


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
cat > psql-setup-script.js << EOL
const { sequelize } = require('./db/models');

sequelize.showAllSchemas({ logging: false }).then(async (data) => {
    if (!data.includes(process.env.SCHEMA)) {
        await sequelize.createSchema(process.env.SCHEMA);
    }
});
EOL

# Create routes index file
cat > routes/index.js << EOL
const express = require('express');
const router = express.Router();

router.get('/api/test', (req, res) => {
    res.json({ message: 'Success' });
});

module.exports = router;
EOL

# Create .gitignore
cat > .gitignore << EOL
node_modules
.env
.DS_Store
EOL
echo "finished .gitignore"

# Initialize Sequelize
npx sequelize-cli init || true


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

echo "Project setup complete! Next steps:"
echo "1. Update .env with your database credentials"
echo "2. Create initial database migration"
echo "3. Set up AWS CodePipeline"


#########################################################################################################################
#########################################################################################################################
# AWS SERVICES CI/CD
#########################################################################################################################
#########################################################################################################################




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
# THE SCRIPT:


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
INSTANCE_NAME="$ECC_NAME_ARG-$CREATE_DATE-$INSTANCE_VERSION"

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
# THE SCRIPT

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

ssh -i ${KEY_PAIR_NAME}.pem ec2-user@${PUBLIC_IP} << 'EOF'
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

echo "Script completed. SSH session terminated."









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

# Validate password complexity
if ! echo "$DB_PASSWORD" | grep -q "[A-Z]" || \
   ! echo "$DB_PASSWORD" | grep -q "[a-z]" || \
   ! echo "$DB_PASSWORD" | grep -q "[0-9]" || \
   ! echo "$DB_PASSWORD" | grep -q "[!@#$%^&()_+{}[]:<>?.]"; then
    echo "Error: DB_PASSWORD must contain uppercase, lowercase, numbers, and special characters"
    exit 1
fi



# If all checks pass, proceed with RDS creation
echo "Password validation passed, proceeding with RDS creation..."

# Variables
DB_IDENTIFIER="$1-postgres-db"
SUBNET_GROUP_NAME="$1-db-subnet-group"



# Verify VPC exists
if [ -z "$VPC_ID" ] || [ "$VPC_ID" = "None" ]; then
    echo "Error: No VPC found"
    exit 1
fi

echo "Using VPC: $VPC_ID"



# Create DB subnet group
echo "Creating DB subnet group..."
aws rds create-db-subnet-group \
    --db-subnet-group-name "$SUBNET_GROUP_NAME" \
    --db-subnet-group-description "Subnet group for PostgreSQL RDS" \
    --subnet-ids "${PRIVATE_SUBNET_1_ID}" "${PRIVATE_SUBNET_2_ID}"


# Create RDS instance
echo "Creating RDS instance..."
aws rds create-db-instance \
    --db-instance-identifier "$DB_IDENTIFIER" \
    --db-instance-class db.t3.micro \
    --engine postgres \
    --engine-version 15.4 \
    --master-username postgres \
    --master-user-password "${DB_PASSWORD}" \
    --allocated-storage 20 \
    --storage-type gp3 \
    --vpc-security-group-ids "$PRIVATE_SG_ID" \
    --db-subnet-group-name "$SUBNET_GROUP_NAME" \
    --no-publicly-accessible \
    --port 5432 \
    --backup-retention-period 7 \
    --multi-az false \
    --auto-minor-version-upgrade true \
    --deletion-protection true \
    --storage-encrypted true \
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



########################################################################################################################################################
echo "YOU HAVE FINISHED THE SCRIPT!!!!!!!!!!!!!!!!!!!!"
echo "Use AWS GitHub Actions, AWS CodeDeploy, or AWS CodePipeline to connect your EC2/EBS to GitHub repo"
