#!/bin/bash

export AWS_PAGER=""  # Disable the AWS CLI pager so we don't get json output

# Array of bucket names - change them to suit your needs
BUCKETS=(
admiend-do-reg-mi-02-19-2025-2-20250219154849-646909fa
admiend-do-reg-mi-02-19-2025-3-20250219155304-b4333f58
admiend-do-reg-mi-02-20-2025-2-20250220055647-251870a6
admiend-do-reg-mi-02-20-2025-3-20250220061238-71b1c748
admiend-do-reg-mi-02-20-2025-4-20250220062614-ecaff3a1
)

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed. Please install jq first."
    exit 1
fi

# Function to delete all versions from a bucket
delete_all_versions() {
    local bucket=$1
    echo "Deleting all versions from bucket: $bucket"

    # Get all versions and delete markers in one go
    versions=$(aws s3api list-object-versions \
        --bucket "$bucket" \
        --output json \
        --query '{Objects: Objects[].{Key:Key,VersionId:VersionId}, DeleteMarkers: DeleteMarkers[].{Key:Key,VersionId:VersionId}}' 2>/dev/null)

    # Process objects in batches of 1000 (S3 delete limit)
    while true; do
        # Get up to 1000 object versions
        batch=$(echo "$versions" | jq -r '
            (.Objects + .DeleteMarkers) |
            select(. != null) |
            limit(1000;.[]) |
            select(. != null) |
            {Key:.Key, VersionId:.VersionId} |
            tojson' | jq -s .)

        # Break if no more objects
        if [ "$batch" == "[]" ] || [ -z "$batch" ]; then
            break
        fi

        echo "Deleting batch of objects..."

        # Create delete request JSON
        delete_json=$(echo "{\"Objects\": $batch, \"Quiet\": true}")

        # Delete batch
        aws s3api delete-objects \
            --bucket "$bucket" \
            --delete "$delete_json"

        if [ $? -ne 0 ]; then
            echo "Error deleting objects batch"
            return 1
        fi
    done
}

# Function to delete a bucket and its contents
delete_bucket() {
    local bucket=$1
    echo "Processing bucket: $bucket"

    # Check if bucket exists
    if aws s3 ls "s3://$bucket" &>/dev/null; then
        echo "  Removing all objects and versions from bucket..."

        # First try simple removal
        aws s3 rm "s3://$bucket" --recursive

        # Then handle versioned objects
        delete_all_versions "$bucket"

        # Double check for any remaining objects
        echo "  Checking for any remaining objects..."
        aws s3api list-object-versions \
            --bucket "$bucket" \
            --max-items 1 &>/dev/null

        if [ $? -eq 0 ]; then
            echo "  Running deletion process again to ensure all objects are removed..."
            delete_all_versions "$bucket"
        fi

        # Try to delete the bucket
        echo "  Attempting to delete bucket..."
        if aws s3 rb "s3://$bucket"; then
            echo "  Successfully deleted bucket: $bucket"
        else
            echo "  Failed to delete bucket: $bucket"
            echo "  Checking for remaining objects..."
            aws s3api list-object-versions --bucket "$bucket"
        fi
    else
        echo "  Bucket does not exist: $bucket"
    fi
    echo "----------------------------------------"
}

# Main execution
echo "Starting bucket deletion process..."
echo "Found ${#BUCKETS[@]} buckets to process"
echo "----------------------------------------"

# Confirm before proceeding
read -p "Do you want to proceed with deletion of these buckets? (y/n): " confirm
if [[ ! $confirm =~ ^[Yy]$ ]]; then
    echo "Operation cancelled"
    exit 0
fi

for bucket in "${BUCKETS[@]}"; do
    delete_bucket "$bucket"
done

echo "Bucket deletion process complete!"
