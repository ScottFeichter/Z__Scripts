#!/bin/bash

# Set the output format to ensure consistent JSON parsing
export AWS_DEFAULT_OUTPUT="json"
export AWS_PAGER=""

# Get the list of RDS Subnet Groups and format the output
echo "Listing RDS Subnet Groups..."
echo "--------------------------------------------------------------------------------"
printf "%-3s %-30s %-20s %-15s %-30s\n" "'" "SUBNET GROUP NAME" "VPC ID" "STATUS" "DESCRIPTION"
echo "--------------------------------------------------------------------------------"

# Get all RDS Subnet Groups and format output
aws rds describe-db-subnet-groups \
    --query 'DBSubnetGroups[].[DBSubnetGroupName,VpcId,SubnetGroupStatus,DBSubnetGroupDescription]' \
    --output text | sort | while IFS=$'\t' read -r group_name vpc_id status description; do
    printf "%-3s %-30s %-20s %-15s %-30s\n" "'" "$group_name" "$vpc_id" "$status" "$description"
done

echo "--------------------------------------------------------------------------------"

# Prompt user for CSV file creation
read -p "Would you like to create a spreadsheet file with this list? (y/n): " answer

# Convert answer to lowercase using tr
answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

if [ "$answer" = "y" ]; then
    # Create CSV file with timestamp in the name
    timestamp=$(date +"%Y%m%d_%H%M%S")
    filename="rds_subnet_groups_${timestamp}.csv"

    # Create header in the CSV file
    echo "QUOTE,SUBNET GROUP NAME,VPC ID,STATUS,DESCRIPTION,SUBNETS" > "$filename"

    # Get the subnet groups and format them into the CSV file
    aws rds describe-db-subnet-groups | jq -r '.DBSubnetGroups[] | [
        .DBSubnetGroupName,
        .VpcId,
        .SubnetGroupStatus,
        .DBSubnetGroupDescription,
        (.Subnets | map(.SubnetIdentifier) | join(";"))
    ] | @csv' | while IFS=',' read -r group_name vpc_id status description subnets; do
        # Remove any existing quotes and add new ones to ensure proper CSV formatting
        group_name=$(echo "$group_name" | tr -d '"')
        vpc_id=$(echo "$vpc_id" | tr -d '"')
        status=$(echo "$status" | tr -d '"')
        description=$(echo "$description" | tr -d '"')
        subnets=$(echo "$subnets" | tr -d '"')

        echo "\"'\",\"$group_name\",\"$vpc_id\",\"$status\",\"$description\",\"$subnets\"" >> "$filename"
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
