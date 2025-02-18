#!/bin/sh
export AWS_PAGER=""

#########################################################################################################################
# CHECKS FOR LOCAL AND REMOTE GITHUB AND CREATES NAME WITH DATE A VERSION

# Check if repo name is provided
if [ -z "$1" ]; then
    echo "Please provide a repo name"
    echo "Usage: ./create-repo-local-and-remote.sh my-repo"
    exit 1
fi

NAME_ARG=$1
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
