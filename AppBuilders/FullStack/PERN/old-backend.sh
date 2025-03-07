
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
