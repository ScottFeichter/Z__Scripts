#!/bin/bash

# Set the output format to ensure consistent JSON parsing
export AWS_DEFAULT_OUTPUT="json"
export AWS_PAGER=""

# Get the list of instances and format the output
echo "Listing EC2 Instances..."
echo "--------------------------------------------------------------------------------"
printf "%-3s %-20s %-15s %-15s %-20s %-20s %-15s\n" "'" "INSTANCE ID" "TYPE" "STATE" "NAME" "PRIVATE IP" "PUBLIC IP"
echo "--------------------------------------------------------------------------------"

# Get all instances and format output
aws ec2 describe-instances \
    --query 'Reservations[].Instances[].[InstanceId,InstanceType,State.Name,Tags[?Key==`Name`].Value|[0],PrivateIpAddress,PublicIpAddress]' \
    --output text | sort | while IFS=$'\t' read -r id type state name private_ip public_ip; do
    # If name is null, replace with "No name"
    if [ "$name" == "None" ]; then
        name="No name"
    fi
    # If IPs are null, replace with "None"
    if [ "$private_ip" == "None" ]; then
        private_ip="No IP"
    fi
    if [ "$public_ip" == "None" ]; then
        public_ip="No IP"
    fi
    printf "%-3s %-20s %-15s %-15s %-20s %-20s %-15s\n" "'" "$id" "$type" "$state" "$name" "$private_ip" "$public_ip"
done

echo "--------------------------------------------------------------------------------"

# Prompt user for CSV file creation
read -p "Would you like to create a spreadsheet file with this list? (y/n): " answer

# Convert answer to lowercase using tr instead
answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

if [ "$answer" = "y" ]; then
    # Create CSV file with timestamp in the name
    timestamp=$(date +"%Y%m%d_%H%M%S")
    filename="ec2_instances_${timestamp}.csv"

    # Create header in the CSV file
    echo "QUOTE,INSTANCE ID,QUOTE,TYPE,QUOTE,STATE,QUOTE,NAME,QUOTE,PRIVATE IP,QUOTE,PUBLIC IP" > "$filename"

    # Get the instances and format them into the CSV file
    aws ec2 describe-instances \
        --query 'Reservations[].Instances[].[InstanceId,InstanceType,State.Name,Tags[?Key==`Name`].Value|[0],PrivateIpAddress,PublicIpAddress]' \
        --output text | sort | while IFS=$'\t' read -r id type state name private_ip public_ip; do
        # If name is null, replace with "No name"
        if [ "$name" == "None" ]; then
            name="No name"
        fi
        # If IPs are null, replace with "None"
        if [ "$private_ip" == "None" ]; then
            private_ip="No IP"
        fi
        if [ "$public_ip" == "None" ]; then
            public_ip="No IP"
        fi
        echo "\"\"\"\",\"$id\",\"\"\"\",\"$type\",\"\"\"\",\"$state\",\"\"\"\",\"$name\",\"\"\"\",\"$private_ip\",\"\"\"\",\"$public_ip\"" >> "$filename"
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
