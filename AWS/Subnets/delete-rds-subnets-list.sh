#!/bin/bash

export AWS_PAGER=""  # Disable the AWS CLI pager

# Array of subnet group names - change them to suit your needs
SUBNET_GROUPS=(
test-03-10-2025-1-db-subnet-group
test-03-10-2025-5-db-subnet-group
)

# Function to delete an RDS subnet group
delete_subnet_group() {
    local subnet_group_name=$1
    echo "Processing subnet group: $subnet_group_name"

    # Check if subnet group exists
    if ! aws rds describe-db-subnet-groups \
        --db-subnet-group-name "$subnet_group_name" \
        --query 'DBSubnetGroups[0].DBSubnetGroupName' \
        --output text 2>/dev/null; then
        echo "  Subnet group does not exist: $subnet_group_name"
        echo "----------------------------------------"
        return 1
    fi

    # Check if subnet group is in use by any RDS instances
    if db_instances=$(aws rds describe-db-instances \
        --query "DBInstances[?DBSubnetGroup.DBSubnetGroupName=='${subnet_group_name}'].DBInstanceIdentifier" \
        --output text); then
        if [ ! -z "$db_instances" ]; then
            echo "  Warning: Subnet group $subnet_group_name is currently used by these instances:"
            echo "  $db_instances"
            read -p "  Cannot delete subnet group while in use. Press Enter to continue..."
            echo "----------------------------------------"
            return 1
        fi
    fi

    # Delete the subnet group
    echo "  Deleting subnet group..."
    if aws rds delete-db-subnet-group \
        --db-subnet-group-name "$subnet_group_name"; then
        echo "  Successfully deleted subnet group: $subnet_group_name"

        # Verify deletion
        echo "  Verifying deletion..."
        if ! aws rds describe-db-subnet-groups \
            --db-subnet-group-name "$subnet_group_name" \
            >/dev/null 2>&1; then
            echo "  Deletion verified for subnet group: $subnet_group_name"
        else
            echo "  Warning: Subnet group may still exist: $subnet_group_name"
        fi
    else
        echo "  Failed to delete subnet group: $subnet_group_name"
    fi
    echo "----------------------------------------"
}

# Main execution
echo "Starting RDS subnet group deletion process..."
echo "----------------------------------------"

# Check if subnet groups array is empty
if [ ${#SUBNET_GROUPS[@]} -eq 0 ]; then
    echo "No subnet groups specified for deletion"
    exit 1
fi

# Confirm deletion
echo "The following RDS subnet groups will be deleted:"
printf '%s\n' "${SUBNET_GROUPS[@]}"
read -p "Are you sure you want to proceed? (y/n): " confirm

if [[ $confirm == [Yy]* ]]; then
    for subnet_group in "${SUBNET_GROUPS[@]}"; do
        delete_subnet_group "$subnet_group"
    done
    echo "Subnet group deletion process complete!"
else
    echo "Operation cancelled"
fi
