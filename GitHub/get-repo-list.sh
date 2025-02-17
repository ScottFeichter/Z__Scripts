#!/bin/bash

# Get the list of repos and format the output
echo "Listing 20 Most Recent GitHub Repositories..."
echo "----------------------------------------"
printf "%-10s %-50s %-10s %-30s\n" "QUOTES" "REPOSITORY NAME" "QUOTES" "VISIBILITY"
echo "----------------------------------------"

# Get repos with JSON output including created_at for sorting
gh repo list --json name,visibility,createdAt -L 20 | \
jq -r '.[] | [.name, .visibility, .createdAt] | @tsv' | \
sort -k3,3r | \
while IFS=$'\t' read -r reponame visibility created; do
    printf "%-10s %-50s %-10s %-30s\n" "\"" "$reponame" "\"" "$visibility"
done

echo "----------------------------------------"

# Prompt user for CSV file creation
read -p "Would you like to create a spreadsheet file with this list? (y/n): " answer

# Convert answer to lowercase using tr
answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

if [ "$answer" = "y" ]; then
    # Create CSV file with timestamp in the name
    timestamp=$(date +"%Y%m%d_%H%M%S")
    filename="github_repos_${timestamp}.csv"

    # Create header in the CSV file
    echo "QUOTES,REPOSITORY NAME,QUOTES,VISIBILITY" > "$filename"

    # Get the repos and format them into the CSV file
    gh repo list --json name,visibility,createdAt -L 20 | \
    jq -r '.[] | [.name, .visibility, .createdAt] | @tsv' | \
    sort -k3,3r | \
    while IFS=$'\t' read -r reponame visibility created; do
        echo "\"\"\"\",\"$reponame\",\"\"\"\",\"$visibility\"" >> "$filename"
    done

    echo "Spreadsheet file created: $filename"

    # Open the file with default application based on OS
    case "$(uname)" in
        "Darwin") # macOS
            open "$filename"
            ;;
        "Linux")
            if command -v xdg-open > /dev/null; then
                xdg-open "$filename"
            else
                echo "Could not automatically open the file. Please open $filename manually."
            fi
            ;;
        "MINGW"*|"MSYS"*|"CYGWIN"*) # Windows
            start "$filename"
            ;;
        *)
            echo "Could not automatically open the file. Please open $filename manually."
            ;;
    esac
else
    echo "No spreadsheet file created"
fi
