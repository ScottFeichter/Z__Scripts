#!/bin/bash


#########################################################################################################################


# Check if repo name is provided
if [ -z "$1" ]; then
    echo "Please try again and provide a repo name as argument..."
    echo "Usage: ./create-pern-gh-admin-amplify-ec2-aws.sh my-repo"
    exit 1
fi

BACKEND_REPO_NAME=$1
DB_POSTGRES=${BACKEND_REPO_NAME}_db_postgres
DB_POSTGRES_TEST=${BACKEND_REPO_NAME}_db_postgres_test

#########################################################################################################################

# 1. make project folder
mkdir $BACKEND_REPO_NAME
cd $BACKEND_REPO_NAME



###################################################################################################

# 2. Create a .env.example file for environment variables (db credentials)
cat > .env.example << EOL
PG_DB_HOST=localhost
PG_DB_USER=postgres
PG_DB_PASSWORD=postgres
PG_DB_NAME=$DB_POSTGRES
PG_DB_PORT=5432

PG_DB_NAME_TEST=$DB_POSTGRES_TEST

SERVER_PORT=5555
EOL

###################################################################################################


# 3. Load environment variables from .env.example (excluding comments and empty lines)
export $(cat .env.example)


###################################################################################################

# 4. Create the databases on postgres if they don't exist

echo "Creating databases if they don't exist..."

PGPASSWORD=$PG_DB_PASSWORD psql -U $PG_DB_USER -h $PG_DB_HOST postgres << EOF
CREATE DATABASE $DB_POSTGRES;
CREATE DATABASE $DB_POSTGRES_TEST;
EOF




###################################################################################################

# 5. Check if the database creation was successful

# Check if databases exist now
PGPASSWORD=$PG_DB_PASSWORD psql -U $PG_DB_USER -h $PG_DB_HOST postgres -c "SELECT datname FROM pg_database WHERE datname = '$DB_POSTGRES';" | grep -q "$DB_POSTGRES"
DB_EXISTS=$?

if [ $DB_EXISTS -eq 0 ]; then
    echo "Databases created successfully!"
else
    echo "Error: Failed to create databases. Make sure PostgreSQL is running and you have the correct permissions."
    exit 1
fi

# Wait a moment for databases to be ready
sleep 2




###################################################################################################

# 6. Add build and startup scripts to package.json
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
    "build": "tsc && echo 'Build Finished! 👍'",
    "prod": "node dist/server.js",
    "dev": "nodemon dist/server.js",
    "test": "nodemon dist/server.js",
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
    "express": "^4.18.2",
    "pg": "^8.11.3",
    "dotenv": "^16.3.1",
    "typescript": "^5.3.3",
    "ts-node": "^10.9.2",
    "cors": "^2.8.5",
    "sequelize": "^6.35.2",
    "sequelize-typescript": "^2.1.6",
    "pg-hstore": "^2.3.4"
  },
  "devDependencies": {
    "typescript": "^5.3.3",
    "ts-node": "^10.9.2",
    "@types/express": "^4.17.21",
    "@types/node": "^20.10.5",
    "@types/pg": "^8.10.9",
    "@types/cors": "^2.8.17",
    "@types/sequelize": "^4.28.20",
    "nodemon": "^3.0.2",
    "@typescript-eslint/eslint-plugin": "^6.15.0",
    "@typescript-eslint/parser": "^6.15.0",
    "eslint": "^8.56.0",
    "ts-jest": "^29.1.1",
    "@types/jest": "^29.5.11",
    "jest": "^29.7.0",
    "sequelize-cli": "^6.6.2"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
EOL


###################################################################################################

# 7. run installs
npm install

###################################################################################################

# 8. create tsconfig.json
npx tsc --init

###################################################################################################

# 9. adjust tsconfig.json
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
    // "moduleResolution": "node10",                     /* Specify how TypeScript looks up a file from a given module specifier. */
    // "baseUrl": "./",                                  /* Specify the base directory to resolve non-relative module names. */
    // "paths": {},                                      /* Specify a set of entries that re-map imports to additional lookup locations. */
    // "rootDirs": [],                                   /* Allow multiple folders to be treated as one when resolving modules. */
    // "typeRoots": [],                                  /* Specify multiple folders that act like './node_modules/@types'. */
    // "types": [],                                      /* Specify type package names to be included without being referenced in a source file. */
    // "allowUmdGlobalAccess": true,                     /* Allow accessing UMD globals from modules. */
    // "moduleSuffixes": [],                             /* List of file name suffixes to search when resolving a module. */
    // "allowImportingTsExtensions": true,               /* Allow imports to include TypeScript file extensions. Requires '--moduleResolution bundler' and either '--noEmit' or '--emitDeclarationOnly' to be set. */
    // "rewriteRelativeImportExtensions": true,          /* Rewrite '.ts', '.tsx', '.mts', and '.cts' file extensions in relative import paths to their JavaScript equivalent in output files. */
    // "resolvePackageJsonExports": true,                /* Use the package.json 'exports' field when resolving package imports. */
    // "resolvePackageJsonImports": true,                /* Use the package.json 'imports' field when resolving imports. */
    // "customConditions": [],                           /* Conditions to set in addition to the resolver-specific defaults when resolving imports. */
    // "noUncheckedSideEffectImports": true,             /* Check side effect imports. */
    // "resolveJsonModule": true,                        /* Enable importing .json files. */
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


###################################################################################################

# 8a. Create src folder and sub folders
mkdir -p src/config
mkdir -p src/database/models
mkdir -p src/database/migrations
mkdir -p src/database/seeders

# 8b. Create dist folder and sub folders (for compiled files)
mkdir -p dist/config
mkdir -p dist/database/models
mkdir -p dist/database/migrations
mkdir -p dist/database/seeders


###################################################################################################

# 9a. Create a database configuration file using modules:
cat > src/config/env-module.ts << 'EOL'
import { Sequelize } from 'sequelize-typescript';
import { User } from '../database/models/User';  // Import the User model
import dotenv from 'dotenv';
dotenv.config();


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

###################################################################################################

# 9b. Create a database configuration file using common (for sequelize-cli and perhaps others):
cat > src/config/env-common.ts << 'EOL'
// import dotenv from 'dotenv';
const { config } = require('dotenv');
// dotenv.config();


console.log(config({ path: '.env.example'}));
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


###################################################################################################

# 9. Create .sequelizerc file:
cat > .sequelizerc << 'EOL'
const path = require('path');

module.exports = {
  'config': path.resolve('dist/config', 'env-common.js'),
  'models-path': path.resolve('dist/database', 'models'),
  'seeders-path': path.resolve('dist/database', 'seeders'),
  'migrations-path': path.resolve('dist/database', 'migrations')
};
EOL







###################################################################################################


# 10. Create sample model
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

###################################################################################################

# Create an example migration
# Note that migrations and seeders remain as JavaScript files because Sequelize CLI doesn't directly support TypeScript files.
# However, they include TypeScript type annotations through JSDoc comments.
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

###################################################################################################

# Create an example seeder
# Note that migrations and seeders remain as JavaScript files because Sequelize CLI doesn't directly support TypeScript files.
# However, they include TypeScript type annotations through JSDoc comments.
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




###################################################################################################

# 8. Establish a PostgreSQL connection using the pg library
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




###################################################################################################

# 9. Set up a Express server to handle requests
cat > src/server.ts << 'EOL'
// =================IMPORTS START======================//
import express, { Request, Response } from 'express';
import dotenv from 'dotenv';
import SEQUELIZE from './config/env-module';
import { User } from './database/models/User';
import { QueryTypes } from 'sequelize';
import cors from 'cors';
dotenv.config();



// =================VARIABLES START======================//
// Create Server
const SERVER = express();
const port = process.env.SERVER_PORT || 5555;


// =================MIDDLE WARE START======================//
SERVER.use(cors({

  // the origin might be these or whatever your frontend origin is...
  // if you are trying to do a fetch you can check your exact origin with console.log(window.location.origin);

  origin: ['http://localhost:5500', 'http://127.0.0.1:5500', 'file://', 'http://localhost:3000'],
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));


SERVER.use(express.json());



// =================ROUTES START======================//

// Test database connection and sync models
const initDatabase = async () => {
  try {
    await SEQUELIZE.authenticate();
    console.log('Database connection established.');
    await SEQUELIZE.sync({ alter: true });
    console.log('Models synchronized.');

    // Check if test user exists
    const testUser = await User.findOne({
      where: {
        email: 'test@example.com'
      }
    });

    // Create test user if it doesn't exist
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


// Example route returning msg and time
SERVER.get('/', async (req: Request, res: Response) => {
  try {
    await SEQUELIZE.authenticate();
    interface TimeResult {
      now: Date;
    }
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


// Example route using Sequelize model
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

// =================SEQUELIZE CONNECT START======================//

// Make sure to initialize the database before starting the server
const start = async () => {
  try {
    await initDatabase();
    SERVER.listen(port, () => {
      console.log(`Server is running on port ${port}`);
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
};

start();
EOL


###################################################################################################

# Create LICENSE
echo "Creating LICENSE..."
cat > LICENSE << EOL
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





###################################################################################################

# Compile ts and build
npm run build

###################################################################################################

# Run migrations
npm run db:migrate

# Run seeders
npm run db:seed

###################################################################################################

# Run the server
npm run dev

###################################################################################################
###################################################################################################



# In your setup, port 5555 is being used for your Express server, while port 5432 is the default PostgreSQL database port. Let's break this down:

# 1. Express Server (port 5555): [1]

        # This is your web server that handles HTTP requests

        # Defined in your server.ts with process.env.SERVER_PORT || 5555

        # When you visit http://localhost:5555, you're connecting to this Express server

        # The successful response you're seeing (time and connected message) means:

                # Your Express server is running correctly [2]

                # It successfully connected to PostgreSQL

                # It executed the test query SELECT NOW()

# 2. PostgreSQL (port 5432):

        # This is your database server

        # Running on the default PostgreSQL port 5432

        # Defined in your postgres.ts with process.env.PG_DB_PORT || '5432'

        # Not directly accessible via web browser

        # Your Express server connects to this port to communicate with the database

# So when you make a request to http://localhost:5555:

        # 1. Express receives the request on port 5555

        # 2. Express connects to PostgreSQL on port 5432

        # 3. PostgreSQL executes the query

        # 4. Express sends the result back to your browser

# This is a typical setup where:

        # Web/API server (Express) uses one port (5555)

        # Database server (PostgreSQL) uses another port (5432)

        # They communicate with each other behind the scenes


###################################################################################################

# the app will attempt to connect to PostgreSQL using the credentials specified in your .env file. However, it's not automatically connected - you need to:

    # Create a .env file (copy from .env.example that was created by the script):

    # Make sure the credentials in your .env file match your local PostgreSQL setup: [1]

# The script created a basic connection test endpoint at '/'. You can test the connection by:

    # Building the TypeScript code: npm run build

    # Starting the server: npm run dev

    # Visiting http://localhost:3000 in your browser or using curl

        # If the connection is successful, you'll see:

            # {
            #   "message": "PostgreSQL connected!",
            #   "time": "2024-xx-xx xx:xx:xx.xxxxx"
            # }

        # If it fails, you'll see:

            # {
            #   "error": "Database connection failed"
            # }


###################################################################################################

# Common issues that might prevent connection:

    # PostgreSQL service not running

    # Wrong credentials in .env

    # Database doesn't exist

    # Wrong port number

    # PostgreSQL not accepting connections from localhost

# You can check your PostgreSQL service status with:

    # brew services list
    # NOTE THE USER LISTED IS NOT THE PSQL USER BUT THE MAC OS SYSTEM USER

# And verify your PostgreSQL connection details using psql:

    # psql -l



###################################################################################################

# At localhost:5555/users should display the test user created by the script

# To test it manually, you'll need to:

        # First, create a user using a POST request to /users. You can do this using curl, Postman, or any API client:

                # Using curl:

                        # curl -X POST http://localhost:5555/users \
                        # -H "Content-Type: application/json" \
                        # -d '{"name": "John Doe", "email": "john@example.com"}'


                # Using Postman:

                        # Method: POST
                        # URL: http://localhost:5555/users
                        # Headers: Content-Type: application/json
                        # Body (raw JSON):

                        # {
                        #     "name": "John Doe",
                        #     "email": "john@example.com"
                        # }

                # Using fetch in the browser:

                        # fetch('http://localhost:5555/users', {
                        #   method: 'POST',
                        #   headers: {
                        #     'Content-Type': 'application/json'
                        #   },
                        #   body: JSON.stringify({
                        #     name: 'John Doe',
                        #     email: 'john@example.com'
                        #   })
                        # })
                        # .then(response => response.json())
                        # .then(data => console.log(data))
                        # .catch(error => console.error('Error:', error));

                        # You need to be sure cors is used in the server
                        # And you need to be sure your origin is authorized by cors (listed in the server.ts)
                        # To find out your exact origin, you can run this in your browser console:

                                # console.log(window.location.origin);

###################################################################################################


# Then, when you GET http://localhost:5555/users, you should see the created user:

# [
#     {
#         "id": 1,
#         "name": "John Doe",
#         "email": "john@example.com",
#         "createdAt": "2024-01-...",
#         "updatedAt": "2024-01-..."
#     }
# ]




# If the POST request fails:

# Check your server logs for errors

# Verify that your database connection is working (the root endpoint '/' should show the current time)

# Confirm that the users table was created (you can check using psql)

# \c your_database_name
# \dt
# SELECT * FROM users;


###################################################################################################


# In your TypeScript code, you can now import and use the models with full type safety:

        # import { User } from './database/models/User';

        # Create a new user
                # const user = await User.create({
                #   name: 'John Doe',
                #   email: 'john@example.com'
                # });

        # Find all users with type safety
                # const users = await User.findAll();
