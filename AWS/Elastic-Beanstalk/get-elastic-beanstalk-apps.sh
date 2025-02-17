#!/bin/bash

# Set the output format to ensure consistent JSON parsing
export AWS_DEFAULT_OUTPUT="json"
export AWS_PAGER=""

# Get the list of apps and format the output
echo "Listing Elastic Beanstalk Applications..."
echo "--------------------------------------------------------------------------------"
printf "%-3s %-50s %-20s %-20s %-20s\n" "'" "APPLICATION NAME" "DESCRIPTION" "CREATED" "MODIFIED"
echo "--------------------------------------------------------------------------------"

# Get all applications and format output
aws elasticbeanstalk describe-applications --query "Applications[].[ApplicationName,Description,DateCreated,DateUpdated]" --output text | sort | while IFS=$'\t' read -r name description created modified; do
    # If description is null, replace with "No description"
    if [ "$description" == "None" ]; then
        description="No description"
    fi
    # Format dates to be more readable
    created_date=$(date -d "$created" "+%Y-%m-%d %H:%M" 2>/dev/null || echo "$created")
    modified_date=$(date -d "$modified" "+%Y-%m-%d %H:%M" 2>/dev/null || echo "$modified")
    printf "%-3s %-50s %-20s %-20s %-20s\n" "'" "$name" "$description" "$created_date" "$modified_date"
done

echo "--------------------------------------------------------------------------------"

# Prompt user for CSV file creation
read -p "Would you like to create a spreadsheet file with this list? (y/n): " answer

# Convert answer to lowercase using tr instead
answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

if [ "$answer" = "y" ]; then
    # Create CSV file with timestamp in the name
    timestamp=$(date +"%Y%m%d_%H%M%S")
    filename="elastic_beanstalk_apps_${timestamp}.csv"

    # Create header in the CSV file
    echo "QUOTE,APPLICATION NAME,QUOTE,DESCRIPTION,QUOTE,DATE CREATED,QUOTE,DATE MODIFIED" > "$filename"

    # Get the applications and format them into the CSV file
    aws elasticbeanstalk describe-applications --query "Applications[].[ApplicationName,Description,DateCreated,DateUpdated]" --output text | sort | while IFS=$'\t' read -r name description created modified; do
        # If description is null, replace with "No description"
        if [ "$description" == "None" ]; then
            description="No description"
        fi
        # Format dates to be more readable
        created_date=$(date -d "$created" "+%Y-%m-%d %H:%M" 2>/dev/null || echo "$created")
        modified_date=$(date -d "$modified" "+%Y-%m-%d %H:%M" 2>/dev/null || echo "$modified")
        echo "\"\"\"\",\"$name\",\"\"\"\",\"$description\",\"\"\"\",\"$created_date\",\"\"\"\",\"$modified_date\"" >> "$filename"
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
