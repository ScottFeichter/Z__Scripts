#!/bin/bash

# Set the output format to ensure consistent JSON parsing
export AWS_DEFAULT_OUTPUT="json"
export AWS_PAGER=""

# Get the list of VPCs and format the output
echo "Listing VPCs..."
echo "--------------------------------------------------------------------------------------------"
printf "%-3s %-20s %-3s %-15s %-15s %-20s %-15s\n" "'" "VPC ID" "'" "CIDR BLOCK" "STATE" "DHCP OPTIONS" "IS DEFAULT"
echo "--------------------------------------------------------------------------------------------"

# Get all VPCs and format output
aws ec2 describe-vpcs \
    --query 'Vpcs[].[VpcId,CidrBlock,State,DhcpOptionsId,IsDefault]' \
    --output text | sort | while IFS=$'\t' read -r vpc_id cidr state dhcp_options is_default; do
    printf "%-3s %-20s %-3s %-15s %-15s %-20s %-15s\n" "'" "$vpc_id" "'" "$cidr" "$state" "$dhcp_options" "$is_default"
done

echo "--------------------------------------------------------------------------------------------"

# Prompt user for CSV file creation
read -p "Would you like to create a spreadsheet file with this list? (y/n): " answer

# Convert answer to lowercase using tr
answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

if [ "$answer" = "y" ]; then
    # Create CSV file with timestamp in the name
    timestamp=$(date +"%Y%m%d_%H%M%S")
    filename="vpcs_${timestamp}.csv"

    # Create header in the CSV file
    echo "QUOTE,VPC ID,QUOTE,CIDR BLOCK,STATE,DHCP OPTIONS,IS DEFAULT" > "$filename"

    # Get the VPCs and format them into the CSV file
    aws ec2 describe-vpcs \
        --query 'Vpcs[].[VpcId,CidrBlock,State,DhcpOptionsId,IsDefault]' \
        --output text | sort | while IFS=$'\t' read -r vpc_id cidr state dhcp_options is_default; do
        echo "\"'\",\"$vpc_id\",\"'\",\"$cidr\",\"$state\",\"$dhcp_options\",\"$is_default\"" >> "$filename"
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
