#!/bin/bash

# THE SCRIPT:


# Check if repo name is provided
if [ -z "$1" ]; then
    echo "Please try again and provide a repo name as argument..."
    echo "Usage: ./create-admin-pern-aws.sh my-repo"
    exit 1
fi

ARG=$1
ADMIN_NAME_ARG=$1-admin
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
mkdir -p api-docs comporables draw-io images misc postman questions requirements redux schema sequelize sounds wireframes


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

gh repo create "$ADMIN_REPO_NAME" --public

git remote add origin "https://github.com/ScottFeichter/$ADMIN_REPO_NAME.git"
git branch -M main
git push -u origin main



