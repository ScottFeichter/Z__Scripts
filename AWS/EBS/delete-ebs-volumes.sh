#!/bin/bash

export AWS_PAGER=""  # Disable the AWS CLI pager

# Array of volume IDs - change them to suit your needs
VOLUMES=(
vol-0040386e9607b3136
vol-093757deb4cde34f5
)

# Function to delete an EBS volume
delete_volume() {
    local volume_id=$1
    echo "Processing volume: $volume_id"

    # Check if volume exists and get its state
    volume_state=$(aws ec2 describe-volumes \
        --volume-ids "$volume_id" \
        --query 'Volumes[0].State' \
        --output text 2>/dev/null) || {
        echo "  Volume does not exist: $volume_id"
        echo "----------------------------------------"
        return 1
    }

    # Check if volume is in-use
    if [ "$volume_state" == "in-use" ]; then
        echo "  Warning: Volume $volume_id is currently attached to an instance"
        read -p "  Do you want to force detach and delete this volume? (y/n): " force_delete
        if [[ $force_delete == [Yy]* ]]; then
            echo "  Detaching volume..."
            aws ec2 detach-volume --volume-id "$volume_id" --force

            # Wait for volume to become available
            echo "  Waiting for volume to detach..."
            aws ec2 wait volume-available --volume-ids "$volume_id"
        else
            echo "  Skipping volume deletion"
            echo "----------------------------------------"
            return 1
        fi
    fi

    # Delete the volume
    echo "  Deleting volume..."
    if aws ec2 delete-volume --volume-id "$volume_id"; then
        echo "  Successfully deleted volume: $volume_id"

        # Wait to confirm deletion
        echo "  Verifying deletion..."
        if aws ec2 wait volume-deleted --volume-ids "$volume_id" 2>/dev/null; then
            echo "  Deletion verified for volume: $volume_id"
        fi
    else
        echo "  Failed to delete volume: $volume_id"
    fi
    echo "----------------------------------------"
}

# Main execution
echo "Starting volume deletion process..."
echo "----------------------------------------"

# Check if volumes array is empty
if [ ${#VOLUMES[@]} -eq 0 ]; then
    echo "No volumes specified for deletion"
    exit 1
fi

# Confirm deletion
echo "The following volumes will be deleted:"
printf '%s\n' "${VOLUMES[@]}"
read -p "Are you sure you want to proceed? (y/n): " confirm

if [[ $confirm == [Yy]* ]]; then
    for volume in "${VOLUMES[@]}"; do
        delete_volume "$volume"
    done
    echo "Volume deletion process complete!"
else
    echo "Operation cancelled"
fi
