#!/bin/bash

# Set the output format to ensure consistent JSON parsing
export AWS_DEFAULT_OUTPUT="json"
export AWS_PAGER=""

# Get the list of volumes and format the output
echo "Listing EBS Volumes..."
echo "--------------------------------------------------------------------------------"
printf "%-3s %-20s %-15s %-15s %-10s %-15s %-15s\n" "'" "VOLUME ID" "SIZE (GB)" "TYPE" "STATE" "AZ" "INSTANCE ID"
echo "--------------------------------------------------------------------------------"

# Get all volumes and format output
aws ec2 describe-volumes \
    --query 'Volumes[].[VolumeId,Size,VolumeType,State,AvailabilityZone,Attachments[0].InstanceId]' \
    --output text | sort | while IFS=$'\t' read -r vol_id size type state az instance_id; do
    # If instance_id is null, replace with "Not Attached"
    if [ "$instance_id" == "None" ]; then
        instance_id="Not Attached"
    fi
    printf "%-3s %-20s %-15s %-15s %-10s %-15s %-15s\n" "'" "$vol_id" "$size" "$type" "$state" "$az" "$instance_id"
done

echo "--------------------------------------------------------------------------------"

# Prompt user for CSV file creation
read -p "Would you like to create a spreadsheet file with this list? (y/n): " answer

# Convert answer to lowercase using tr
answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

if [ "$answer" = "y" ]; then
    # Create CSV file with timestamp in the name
    timestamp=$(date +"%Y%m%d_%H%M%S")
    filename="ebs_volumes_${timestamp}.csv"

    # Create header in the CSV file
    echo "QUOTE,VOLUME ID,SIZE (GB),TYPE,STATE,AVAILABILITY ZONE,INSTANCE ID" > "$filename"

    # Get the volumes and format them into the CSV file
    aws ec2 describe-volumes \
        --query 'Volumes[].[VolumeId,Size,VolumeType,State,AvailabilityZone,Attachments[0].InstanceId]' \
        --output text | sort | while IFS=$'\t' read -r vol_id size type state az instance_id; do
        # If instance_id is null, replace with "Not Attached"
        if [ "$instance_id" == "None" ]; then
            instance_id="Not Attached"
        fi
        echo "\"$vol_id\",\"$size\",\"$type\",\"$state\",\"$az\",\"$instance_id\"" >> "$filename"
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
