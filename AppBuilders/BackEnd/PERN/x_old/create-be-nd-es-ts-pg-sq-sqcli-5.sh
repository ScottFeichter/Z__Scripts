#!/bin/bash


#########################################################################################################################
# Check if repo name is provided
echo ""
echo "🛠  ACTION: Checking if repo name provided as arg... "



if [ -z "$1" ]; then
    echo "Please try again and provide a repo name as argument..."
    echo "Usage: ./create-pern-gh-admin-amplify-ec2-aws.sh my-repo"
    exit 1
fi

echo ""
echo "✅ RESULT: Repo name arg correctly provided! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"



#########################################################################################################################
# Create DB_POSTGRES from BACKEND_REPO_NAME
echo ""
echo "🛠  ACTION: Creating DB_POSTGRES variables from BACKEND_REPO_NAME... "



BACKEND_REPO_NAME=$1
DB_POSTGRES=${BACKEND_REPO_NAME}_db_postgres
DB_POSTGRES_TEST=${BACKEND_REPO_NAME}_db_postgres_test


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



mkdir $BACKEND_REPO_NAME
cd $BACKEND_REPO_NAME


echo ""
echo "✅ RESULT: Project folder successfully created! "
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
mkdir -p src/middlewares
mkdir -p src/types
mkdir -p src/types/express
mkdir -p src/routes
mkdir -p src/routes/api
mkdir -p src/tests
mkdir -p src/tests/middleware
mkdir -p src/utils
mkdir -p .env
mkdir -p controller
mkdir -p misc

# Create dist folder and sub folders (for compiled files)
mkdir -p dist/config
mkdir -p dist/database/models
mkdir -p dist/database/migrations
mkdir -p dist/database/seeders
mkdir -p dist/middlewares
mkdir -p dist/types
mkdir -p dist/types/express
mkdir -p dist/routes
mkdir -p dist/routes/api
mkdir -p dist/tests
mkdir -p dist/tests/middleware
mkdir -p dist/utils


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
    "cors": "^2.8.5",
    "jsonwebtoken": "^9.0.2",
    "dotenv": "^16.3.1",
    "express": "^4.18.2",
    "pg": "^8.11.3",
    "pg-hstore": "^2.3.4",
    "sequelize": "^6.35.2",
    "sequelize-typescript": "^2.1.6",
    "cookie-parser": "^1.4.6",
    "csurf": "^1.11.0"
  },
  "devDependencies": {
    "@types/cookie-parser": "^1.4.6",
    "@types/csurf": "^1.11.4",
    "@types/bcrypt": "^5.0.2",
    "@types/cors": "^2.8.17",
    "@types/jsonwebtoken": "^9.0.7",
    "@types/express": "^4.17.21",
    "@types/express-serve-static-core": "^4.17.35",
    "@types/pg": "^8.10.9",
    "@types/node": "^20.10.5",
    "@types/jest": "^29.5.11",
    "@types/sequelize": "^4.28.20",
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
echo ""

npx tsc --init



# Adjust tsconfig.json
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
    "baseUrl": "./",                                     /* Specify the base directory to resolve non-relative module names. */
    "paths": { "@/*": ["src/*"] },                       /* Specify a set of entries that re-map imports to additional lookup locations. */
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
import cors from 'cors';
import cookieParser from 'cookie-parser';
import csrf from 'csurf';
import { SERVER } from '../server';
import { Request, CSRFError } from '../types';

export const setupMiddleware = () => {
  SERVER.use(cors({
    origin: ['http://localhost:5500', 'http://127.0.0.1:5500', 'file://', 'http://localhost:3000'],
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    allowedHeaders: ['Content-Type', 'Authorization', 'XSRF-Token'],
    credentials: true
  }));

  SERVER.use(cookieParser());
  SERVER.use(express.json());

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
echo ""
echo "🛠  ACTION: Launching the server... 🚀  "
echo ""


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
