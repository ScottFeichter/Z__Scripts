#!/bin/bash

export AWS_PAGER=""  # Disable the AWS CLI pager

# Array of RDS instance identifiers - change them to suit your needs
RDS_INSTANCES=(
    "database-1"
    "database-2"
)

# Function to delete an RDS instance
delete_rds() {
    local db_identifier=$1
    echo "Processing RDS instance: $db_identifier"

    # Check if instance exists and get its status
    db_status=$(aws rds describe-db-instances \
        --db-instance-identifier "$db_identifier" \
        --query 'DBInstances[0].DBInstanceStatus' \
        --output text 2>/dev/null) || {
        echo "  RDS instance does not exist: $db_identifier"
        echo "----------------------------------------"
        return 1
    }

    # Check if instance has deletion protection enabled
    deletion_protection=$(aws rds describe-db-instances \
        --db-instance-identifier "$db_identifier" \
        --query 'DBInstances[0].DeletionProtection' \
        --output text)

    if [ "$deletion_protection" == "true" ]; then
        echo "  Warning: Deletion protection is enabled for $db_identifier"
        read -p "  Do you want to disable deletion protection? (y/n): " disable_protection
        if [[ $disable_protection == [Yy]* ]]; then
            echo "  Disabling deletion protection..."
            aws rds modify-db-instance \
                --db-instance-identifier "$db_identifier" \
                --no-deletion-protection \
                --apply-immediately

            echo "  Waiting for modification to complete..."
            aws rds wait db-instance-available --db-instance-identifier "$db_identifier"
        else
            echo "  Skipping instance deletion"
            echo "----------------------------------------"
            return 1
        fi
    fi

    # Prompt for final snapshot
    read -p "  Do you want to create a final snapshot? (y/n): " create_snapshot
    if [[ $create_snapshot == [Yy]* ]]; then
        snapshot_identifier="${db_identifier}-final-$(date +%Y%m%d-%H%M%S)"
        echo "  Creating final snapshot: $snapshot_identifier"

        aws rds delete-db-instance \
            --db-instance-identifier "$db_identifier" \
            --final-db-snapshot-identifier "$snapshot_identifier"
    else
        echo "  Proceeding without final snapshot..."
        aws rds delete-db-instance \
            --db-instance-identifier "$db_identifier" \
            --skip-final-snapshot
    fi

    # Wait for deletion to complete
    echo "  Waiting for instance deletion to complete..."
    if aws rds wait db-instance-deleted --db-instance-identifier "$db_identifier"; then
        echo "  Successfully deleted RDS instance: $db_identifier"
    else
        echo "  Failed to verify deletion of RDS instance: $db_identifier"
    fi
    echo "----------------------------------------"
}

# Main execution
echo "Starting RDS instance deletion process..."
echo "----------------------------------------"

# Check if instances array is empty
if [ ${#RDS_INSTANCES[@]} -eq 0 ]; then
    echo "No RDS instances specified for deletion"
    exit 1
fi

# Confirm deletion
echo "The following RDS instances will be deleted:"
printf '%s\n' "${RDS_INSTANCES[@]}"
echo "WARNING: This action cannot be undone if you choose to skip final snapshots!"
read -p "Are you sure you want to proceed? (y/n): " confirm

if [[ $confirm == [Yy]* ]]; then
    for instance in "${RDS_INSTANCES[@]}"; do
        delete_rds "$instance"
    done
    echo "RDS instance deletion process complete!"
else
    echo "Operation cancelled"
fi
