#!/bin/sh

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
