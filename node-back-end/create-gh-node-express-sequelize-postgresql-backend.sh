#!/bin/bash

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

NAME_ARG=$1-backend
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

# Create directory and initialize repository
mkdir "$REPO_NAME"
cd "$REPO_NAME"

git init
touch README.md
git add .
git commit -m "initial (msg via shell)"

gh repo create "$REPO_NAME" --public

git remote add origin "https://github.com/ScottFeichter/$REPO_NAME.git"
git branch -M main
git push -u origin main








# Initialize npm project
echo "Initializing npm project..."
npm init -y

# Update package.json with scripts and dependencies
cat > package.json << EOL
{
  "name": "${REPO_NAME}",
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

# Create .env file
cat > .env << EOL
PORT=5000
DB_USERNAME=postgres
DB_PASSWORD=password
DB_DATABASE=your_database_name
DB_HOST=localhost
JWT_SECRET=your_jwt_secret_here
JWT_EXPIRES_IN=604800
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

# Initialize Sequelize
npx sequelize-cli init

# Create buildspec.yml for AWS CodeBuild
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
