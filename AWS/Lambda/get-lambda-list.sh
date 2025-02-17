#!/bin/bash

# Set the output format to ensure consistent JSON parsing
export AWS_DEFAULT_OUTPUT="json"
export AWS_PAGER=""

# Get the list of Lambda functions and format the output
echo "Listing Lambda Functions..."
echo "--------------------------------------------------------------------------------"
printf "%-3s %-32s %-15s %-8s %-8s %-20s %-15s\n" "'" "FUNCTION NAME" "RUNTIME" "MEM(MB)" "TIMEOUT" "LAST MODIFIED" "STATE"
echo "--------------------------------------------------------------------------------"

# Get all Lambda functions and format output
aws lambda list-functions \
    --query 'Functions[].[FunctionName,Runtime,MemorySize,Timeout,LastModified,State]' \
    --output text | sort | while IFS=$'\t' read -r func_name runtime memory timeout modified state; do
    # If state is null, replace with "Active"
    if [ "$state" == "None" ]; then
        state="Active"
    fi
    # Format the last modified date
    modified=$(echo "$modified" | cut -d'.' -f1 | sed 's/T/ /')
    printf "%-3s %-32s %-15s %-8s %-8s %-20s %-15s\n" "'" "$func_name" "$runtime" "$memory" "$timeout" "$modified" "$state"
done

echo "--------------------------------------------------------------------------------"

# Prompt user for CSV file creation
read -p "Would you like to create a spreadsheet file with this list? (y/n): " answer

# Convert answer to lowercase using tr
answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

if [ "$answer" = "y" ]; then
    # Create CSV file with timestamp in the name
    timestamp=$(date +"%Y%m%d_%H%M%S")
    filename="lambda_functions_${timestamp}.csv"

    # Create header in the CSV file
    echo "QUOTE,FUNCTION NAME,RUNTIME,MEMORY(MB),TIMEOUT(SEC),LAST MODIFIED,STATE,DESCRIPTION,ROLE,HANDLER" > "$filename"

    # Get the functions with additional details and format them into the CSV file
    aws lambda list-functions \
        --query 'Functions[].[FunctionName,Runtime,MemorySize,Timeout,LastModified,State,Description,Role,Handler]' \
        --output text | sort | while IFS=$'\t' read -r func_name runtime memory timeout modified state desc role handler; do
        # If state is null, replace with "Active"
        if [ "$state" == "None" ]; then
            state="Active"
        fi
        # If description is null, replace with empty string
        if [ "$desc" == "None" ]; then
            desc=""
        fi
        # Format the last modified date
        modified=$(echo "$modified" | cut -d'.' -f1 | sed 's/T/ /')
        # Format role ARN to get just the role name
        role=$(echo "$role" | awk -F'/' '{print $NF}')
        echo "\"$func_name\",\"$runtime\",\"$memory\",\"$timeout\",\"$modified\",\"$state\",\"$desc\",\"$role\",\"$handler\"" >> "$filename"
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
