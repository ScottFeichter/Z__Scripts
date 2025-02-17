#!/bin/bash

# The script provides a solid foundation for a React project with modern tooling and best practices.


#######################################################################################
# This script:

#     1. Creates a new React project using Vite

#     2. Installs common dependencies:

#         - Redux Toolkit for state management

#         - React Router for routing

#         - Axios for API calls

#         - Material-UI for components

#         - Formik & Yup for form handling

#         - SASS for styling

#     3. Sets up a structured project layout:

#         - Components directory for reusable components

#         - Pages for route components

#         - Features for feature-specific code

#         - Services for API calls

#         - Hooks for custom hooks

#         - Utils for helper functions

#         - Store for Redux setup

#     4. Creates basic configuration files:

#         - Router setup

#         - Redux store

#         - API service

#         - SASS styling

#         - Environment variables

#     5. Initializes git repository local and remote and pushes

#######################################################################################
# To use the script:

    # Save it as create-react-redux-vite-frontend.sh

    # Make it executable: chmod +x create-react-redux-vite-frontend.sh

    # Run it: ./create-react-redux-vite-frontend.sh my-app-name



#######################################################################################


#######################################################################################
# THE SCRIPT

export AWS_PAGER=""

# Check if project name is provided
if [ -z "$1" ]; then
    echo "Please provide a project name"
    echo "Usage: ./create-react-redux-vite-frontend.sh my-app"
    exit 1
fi

PROJECT_NAME=$1


# Initialize project with Vite
echo "Creating React w Vite project: $PROJECT_NAME..."
npm create vite@latest $PROJECT_NAME -- --template react -- --skip-git
cd $PROJECT_NAME


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

# Copy the NeoRGB logo to assets directory
echo "Copying NeoRGB logo to assets directory..."
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cp "$SCRIPT_DIR/NeoRGB-flame-no-dark-edges.png" "$PROJECT_NAME/src/assets/"

if [ $? -eq 0 ]; then
    echo "Logo file copied successfully"
else
    echo "Warning: Failed to copy logo file. Please ensure NeoRGB-flame-no-dark-edges.png exists in the same directory as the script"
fi


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
touch README.md
git add .
git commit -m "initial (msg via shell)"

gh repo create $PROJECT_NAME --public

git remote add origin https://github.com/ScottFeichter/$PROJECT_NAME.git
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
1. cd $PROJECT_NAME
2. npm run dev

Happy coding! 🎉"
