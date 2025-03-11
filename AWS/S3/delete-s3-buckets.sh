#!/bin/bash

export AWS_PAGER=""

# Array of bucket names
BUCKETS=(
admiend-neorgp-03-09-2025-1-20250309184714-a39989f8
admiend-test-03-09-2025-1-20250309190124-de1b4161
admiend-test-03-09-2025-2-20250309190606-bf1eaf82
admiend-test-03-09-2025-3-20250309225812-9c96b49a
)

delete_bucket_contents() {
    local bucket="$1"
    local batch_count=0
    local max_attempts=50  # Maximum number of deletion attempts

    echo "Emptying bucket: $bucket"

    # First remove current objects
    echo "Removing current objects..."
    aws s3 rm "s3://$bucket" --recursive

    # Then handle versions and delete markers
    while [ $batch_count -lt $max_attempts ]; do
        ((batch_count++))
        echo "Deletion attempt $batch_count of $max_attempts"

        # Get versions and delete markers
        versions=$(aws s3api list-object-versions \
            --bucket "$bucket" \
            --max-items 1000 \
            --output json 2>/dev/null)

        # Check if we got any data
        if [ -z "$versions" ] || [ "$versions" = "null" ]; then
            echo "No more objects found"
            return 0
        fi

        # Create delete JSON
        tmp_file=$(mktemp)
        echo "$versions" | jq -r '{
            Objects: ([.Versions[]?, .DeleteMarkers[]?] | map({Key: .Key, VersionId: .VersionId})),
            Quiet: true
        }' > "$tmp_file"

        # Check if we have objects to delete
        object_count=$(jq -r '.Objects | length' "$tmp_file")
        if [ -z "$object_count" ] || [ "$object_count" = "null" ] || [ "$object_count" = "0" ]; then
            rm -f "$tmp_file"
            echo "No more objects to delete"
            return 0
        fi

        echo "Deleting batch of $object_count objects (attempt $batch_count)..."

        # Delete objects
        if aws s3api delete-objects \
            --bucket "$bucket" \
            --delete "file://$tmp_file" > /dev/null; then
            echo "Successfully deleted batch $batch_count"
        else
            echo "Error deleting batch $batch_count"
            rm -f "$tmp_file"
            return 1
        fi

        rm -f "$tmp_file"
        sleep 2  # Increased delay between batches
    done

    echo "Warning: Reached maximum deletion attempts ($max_attempts)"
    return 1
}

delete_bucket() {
    local bucket="$1"
    echo "Processing bucket: $bucket"
    echo "----------------------------------------"

    # Check if bucket exists
    if ! aws s3api head-bucket --bucket "$bucket" 2>/dev/null; then
        echo "Bucket does not exist or no access: $bucket"
        return 1
    fi

    # Empty the bucket
    if ! delete_bucket_contents "$bucket"; then
        echo "Failed to empty bucket: $bucket"
        return 1
    fi

    # Verify bucket is empty
    echo "Verifying bucket is empty..."
    if aws s3api list-object-versions --bucket "$bucket" --max-items 1 &>/dev/null; then
        versions_count=$(aws s3api list-object-versions --bucket "$bucket" --output json | jq -r '.Versions | length')
        if [ "$versions_count" != "null" ] && [ "$versions_count" != "0" ]; then
            echo "Bucket still contains objects after deletion attempts"
            return 1
        fi
    fi

    # Delete the bucket
    echo "Deleting bucket: $bucket"
    if aws s3api delete-bucket --bucket "$bucket"; then
        echo "Successfully deleted bucket: $bucket"
        return 0
    else
        echo "Failed to delete bucket: $bucket"
        return 1
    fi
}

# Main script
echo "Starting bucket deletion process..."
echo "Found ${#BUCKETS[@]} buckets to process"
echo "----------------------------------------"

# Print list of buckets
echo "Buckets to be deleted:"
for bucket in "${BUCKETS[@]}"; do
    echo "- $bucket"
done
echo "----------------------------------------"

# Confirm before proceeding
read -p "Continue with deletion? (y/n): " confirm
if [[ ! $confirm =~ ^[Yy]$ ]]; then
    echo "Operation cancelled"
    exit 0
fi

# Process buckets
success=0
failed=0

for bucket in "${BUCKETS[@]}"; do
    if delete_bucket "$bucket"; then
        ((success++))
    else
        ((failed++))
    fi
    echo "----------------------------------------"
done

# Summary
echo "Deletion process complete!"
echo "Summary:"
echo "- Successfully deleted: $success buckets"
echo "- Failed to delete: $failed buckets"
echo "----------------------------------------"

if [ $failed -gt 0 ]; then
    exit 1
fi
