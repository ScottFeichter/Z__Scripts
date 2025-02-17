#!/bin/bash

# Set the output format to ensure consistent JSON parsing
export AWS_DEFAULT_OUTPUT="json"
export AWS_PAGER=""

# Get the list of RDS instances and format the output
echo "Listing RDS Instances..."
echo "--------------------------------------------------------------------------------"
printf "%-3s %-20s %-15s %-15s %-20s %-20s %-15s\n" "'" "DB IDENTIFIER" "ENGINE" "STATUS" "SIZE" "ENDPOINT" "PORT"
echo "--------------------------------------------------------------------------------"

# Get all RDS instances and format output
aws rds describe-db-instances \
    --query 'DBInstances[].[DBInstanceIdentifier,Engine,DBInstanceStatus,DBInstanceClass,Endpoint.Address,Endpoint.Port]' \
    --output text | sort | while IFS=$'\t' read -r id engine status size endpoint port; do
    # If values are null, replace with "None"
    if [ "$id" == "None" ]; then
        id="No ID"
    fi
    if [ "$engine" == "None" ]; then
        engine="No engine"
    fi
    if [ "$status" == "None" ]; then
        status="No status"
    fi
    if [ "$size" == "None" ]; then
        size="No size"
    fi
    if [ "$endpoint" == "None" ]; then
        endpoint="No endpoint"
    fi
    if [ "$port" == "None" ]; then
        port="No port"
    fi
    printf "%-3s %-20s %-15s %-15s %-20s %-20s %-15s\n" "'" "$id" "$engine" "$status" "$size" "$endpoint" "$port"
done

echo "--------------------------------------------------------------------------------"

# Prompt user for CSV file creation
read -p "Would you like to create a spreadsheet file with this list? (y/n): " answer

# Convert answer to lowercase using tr
answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

if [ "$answer" = "y" ]; then
    # Create CSV file with timestamp in the name
    timestamp=$(date +"%Y%m%d_%H%M%S")
    filename="rds_instances_${timestamp}.csv"

    # Create header in the CSV file
    echo "QUOTE,DB IDENTIFIER,QUOTE,ENGINE,QUOTE,STATUS,QUOTE,SIZE,QUOTE,ENDPOINT,QUOTE,PORT" > "$filename"

    # Get the instances and format them into the CSV file
    aws rds describe-db-instances \
        --query 'DBInstances[].[DBInstanceIdentifier,Engine,DBInstanceStatus,DBInstanceClass,Endpoint.Address,Endpoint.Port]' \
        --output text | sort | while IFS=$'\t' read -r id engine status size endpoint port; do
        # If values are null, replace with "None"
        if [ "$id" == "None" ]; then
            id="No ID"
        fi
        if [ "$engine" == "None" ]; then
            engine="No engine"
        fi
        if [ "$status" == "None" ]; then
            status="No status"
        fi
        if [ "$size" == "None" ]; then
            size="No size"
        fi
        if [ "$endpoint" == "None" ]; then
            endpoint="No endpoint"
        fi
        if [ "$port" == "None" ]; then
            port="No port"
        fi
        echo "\"\"\"\",\"$id\",\"\"\"\",\"$engine\",\"\"\"\",\"$status\",\"\"\"\",\"$size\",\"\"\"\",\"$endpoint\",\"\"\"\",\"$port\"" >> "$filename"
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
