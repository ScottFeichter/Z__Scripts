#!/bin/bash

# Array of repository names - change them to suit your needs
REPOS=(

    # BE SURE TO REPLACE THESE WITH THE NAMES YOU WANT TO DELETE
    # ALSO BE SURE YOU HAVE AT LEAST ON NAME IN HERE OR IT MIGHT DELETE EVERY REPO!!!!!!!!!!!!
    # YOU DON'T NEED THESE TO BE ENCLOSED IN QUOTES
node_ts-03-10-2025-2 
)

# Function to delete a GitHub repository
delete_repo() {
    local repo_name=$1
    echo "Processing GitHub repository: $repo_name"

    # Check if repo exists by trying to get its details
    if gh repo view "$repo_name" &>/dev/null; then
        echo "  Repository exists. Requesting deletion..."

        # Prompt for confirmation
        read -p "  Are you sure you want to delete $repo_name? (y/n): " confirm
        if [[ $confirm == [yY] ]]; then
            echo "  Deleting repository..."
            gh repo delete "$repo_name" --confirm

            if [ $? -eq 0 ]; then
                echo "  Successfully deleted repository: $repo_name"
            else
                echo "  Failed to delete repository: $repo_name"
            fi
        else
            echo "  Skipping deletion of: $repo_name"
        fi
    else
        echo "  Repository does not exist: $repo_name"
    fi
    echo "----------------------------------------"
}

# Main execution
echo "Starting GitHub repository deletion process..."
echo "----------------------------------------"

# Verify GitHub CLI is installed and authenticated
if ! command -v gh &>/dev/null; then
    echo "GitHub CLI (gh) is not installed. Please install it first."
    exit 1
fi

if ! gh auth status &>/dev/null; then
    echo "Not authenticated with GitHub. Please run 'gh auth login' first."
    exit 1
fi

# Process each repository
for repo in "${REPOS[@]}"; do
    delete_repo "$repo"
done

echo "Repository deletion process complete!"
