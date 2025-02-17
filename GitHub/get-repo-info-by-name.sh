#!/bin/bash

# Check if repository name is provided
if [ -z "$1" ]; then
    echo "Please provide a repository name"
    echo "Usage: $0 repository-name"
    exit 1
fi

REPO_NAME=$1

# Function to check if gh cli is installed
check_gh_cli() {
    if ! command -v gh &> /dev/null; then
        echo "GitHub CLI (gh) is not installed. Please install it first."
        echo "Visit: https://cli.github.com/ for installation instructions"
        exit 1
    fi
}

# Function to check if user is authenticated
check_auth() {
    if ! gh auth status &> /dev/null; then
        echo "Not logged in to GitHub. Please run 'gh auth login' first"
        exit 1
    fi
}

# Function to get repository information
get_repo_info() {
    # Check if repository exists
    if ! gh repo view "ScottFeichter/$REPO_NAME" &> /dev/null; then
        echo "Repository not found: ScottFeichter/$REPO_NAME"
        exit 1
    }

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
}

# Main execution
check_gh_cli
check_auth
get_repo_info
