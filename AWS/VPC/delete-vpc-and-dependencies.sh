#!/bin/bash

# Because RDS take a long time to delete you may want to open a few terminals and run one vpc at a time in each to get some concurrency going...

# This script:
        # Takes a list of VPC IDs to delete
        # For each VPC:
                # Checks if it exists
                # Detaches and deletes dependent resources
                # Deletes all Subnets
                # Deletes non-main Route Tables
                # Deletes non-default Security Groups
                # Finally deletes the VPC itself



export AWS_PAGER=""

# List of VPCs to delete
VPC_LIST=(
vpc-08c8fe5e0bb8e5396
vpc-0c2b2c1ae314995bb

    # Add more VPC IDs as needed
)

delete_vpc() {
    local vpc_id=$1
    echo "Processing VPC: $vpc_id"

    # Check if VPC exists
    vpc_state=$(aws ec2 describe-vpcs \
        --vpc-ids "$vpc_id" \
        --query 'Vpcs[0].State' \
        --output text 2>/dev/null) || {
        echo "  VPC does not exist: $vpc_id"
        echo "----------------------------------------"
        return 1
    }

    # Function to wait for RDS instance deletion
    wait_for_rds_deletion() {
        local db_identifier=$1
        local start_time=$(date +%s)
        echo "Waiting for RDS instance $db_identifier to be deleted..."
        echo "This could take 5-30 minutes depending on the instance size."

        while aws rds describe-db-instances --db-instance-identifier "$db_identifier" 2>/dev/null; do
            local current_time=$(date +%s)
            local elapsed_time=$((current_time - start_time))
            local minutes=$((elapsed_time / 60))
            local seconds=$((elapsed_time % 60))
            echo "Still waiting... Time elapsed: ${minutes}m ${seconds}s"
            sleep 30
        done

        local total_time=$(($(date +%s) - start_time))
        local total_minutes=$((total_time / 60))
        local total_seconds=$((total_time % 60))
        echo "RDS instance deleted. Total time: ${total_minutes}m ${total_seconds}s"
    }

    # Delete RDS instances
    echo "  Checking for RDS instances..."
    RDS_INSTANCES=$(aws rds describe-db-instances \
        --query "DBInstances[?DBSubnetGroup.VpcId=='${vpc_id}'].DBInstanceIdentifier" \
        --output text)

    if [ ! -z "$RDS_INSTANCES" ] && [ "$RDS_INSTANCES" != "None" ]; then
        for db in $RDS_INSTANCES; do
            echo "  Processing RDS instance: $db"

            # Disable deletion protection
            echo "  Disabling deletion protection for RDS instance: $db"
            aws rds modify-db-instance \
                --db-instance-identifier "$db" \
                --no-deletion-protection \
                --apply-immediately

            # Wait for the modification to complete
            echo "  Waiting for modification to complete..."
            aws rds wait db-instance-available --db-instance-identifier "$db"

            # Delete the instance
            echo "  Now deleting RDS instance: $db"
            aws rds delete-db-instance \
                --db-instance-identifier "$db" \
                --skip-final-snapshot \
                --delete-automated-backups

            # Wait for deletion to complete
            wait_for_rds_deletion "$db"
        done
    else
        echo "  No RDS instances found in VPC"
    fi

    # Terminate EC2 instances
    echo "  Checking for and terminating EC2 instances..."
    instance_ids=$(aws ec2 describe-instances \
        --filters "Name=vpc-id,Values=$vpc_id" \
        --query 'Reservations[].Instances[].InstanceId' \
        --output text)

    if [ ! -z "$instance_ids" ] && [ "$instance_ids" != "None" ]; then
        echo "  Terminating instances: $instance_ids"
        aws ec2 terminate-instances --instance-ids $instance_ids
        echo "  Waiting for instances to terminate..."
        aws ec2 wait instance-terminated --instance-ids $instance_ids
    fi

    # Delete NAT Gateways
    echo "  Checking for NAT Gateways..."
    nat_gateway_ids=$(aws ec2 describe-nat-gateways \
        --filter "Name=vpc-id,Values=$vpc_id" \
        --query 'NatGateways[].NatGatewayId' \
        --output text)

    if [ ! -z "$nat_gateway_ids" ] && [ "$nat_gateway_ids" != "None" ]; then
        for nat_id in $nat_gateway_ids; do
            echo "  Deleting NAT Gateway: $nat_id"
            aws ec2 delete-nat-gateway --nat-gateway-id $nat_id
        done
        echo "  Waiting for NAT Gateways to delete (30 seconds)..."
        sleep 30
    fi

    # Delete VPC Endpoints
    echo "  Checking for VPC Endpoints..."
    vpc_endpoint_ids=$(aws ec2 describe-vpc-endpoints \
        --filters "Name=vpc-id,Values=$vpc_id" \
        --query 'VpcEndpoints[].VpcEndpointId' \
        --output text)

    if [ ! -z "$vpc_endpoint_ids" ] && [ "$vpc_endpoint_ids" != "None" ]; then
        echo "  Deleting VPC Endpoints: $vpc_endpoint_ids"
        aws ec2 delete-vpc-endpoints --vpc-endpoint-ids $vpc_endpoint_ids
        echo "  Waiting for VPC Endpoints to delete (30 seconds)..."
        sleep 30
    fi

    # Check for and delete Internet Gateway
    echo "  Checking for Internet Gateway..."
    igw_id=$(aws ec2 describe-internet-gateways \
        --filters "Name=attachment.vpc-id,Values=$vpc_id" \
        --query 'InternetGateways[].InternetGatewayId' \
        --output text)

    if [ ! -z "$igw_id" ] && [ "$igw_id" != "None" ]; then
        echo "  Detaching and deleting Internet Gateway: $igw_id"
        aws ec2 detach-internet-gateway --internet-gateway-id "$igw_id" --vpc-id "$vpc_id"
        aws ec2 delete-internet-gateway --internet-gateway-id "$igw_id"
    fi

    # Wait for NAT Gateways to be deleted (they take time)
    if [ ! -z "$nat_gateway_ids" ]; then
        echo "Waiting for NAT Gateways to be deleted..."
        sleep 60  # NAT Gateways take time to delete
    fi

    # Check for and delete Network Interfaces
    echo "  Checking for Network Interfaces..."
    eni_ids=$(aws ec2 describe-network-interfaces \
        --filters "Name=vpc-id,Values=$vpc_id" \
        --query 'NetworkInterfaces[].NetworkInterfaceId' \
        --output text)

    for eni_id in $eni_ids; do
        if [ ! -z "$eni_id" ] && [ "$eni_id" != "None" ]; then
            echo "    Processing ENI: $eni_id"

            # Get detailed ENI information
            eni_info=$(aws ec2 describe-network-interfaces \
                --network-interface-ids "$eni_id" \
                --query 'NetworkInterfaces[0].[Description,Status,Attachment.AttachmentId]' \
                --output text)

            description=$(echo "$eni_info" | cut -f1)
            status=$(echo "$eni_info" | cut -f2)
            attachment_id=$(echo "$eni_info" | cut -f3)

            echo "    Description: $description"
            echo "    Status: $status"

            if [ ! -z "$attachment_id" ] && [ "$attachment_id" != "None" ]; then
                echo "    Attempting to detach ENI..."
                aws ec2 detach-network-interface --attachment-id "$attachment_id" --force || \
                echo "    Warning: Could not detach ENI"
                sleep 10
            fi

            echo "    Attempting to delete ENI..."
            aws ec2 delete-network-interface --network-interface-id "$eni_id" || \
            echo "    Warning: Could not delete ENI. It may be managed by another service."
        fi
    done


    # Get all security group IDs for the VPC
    echo "Getting security groups for VPC $VPC_ID..."
    SECURITY_GROUP_IDS=$(aws ec2 describe-security-groups \
        --filters "Name=vpc-id,Values=$VPC_ID" \
        --query 'SecurityGroups[].GroupId' \
        --output text)

    if [ -z "$SECURITY_GROUP_IDS" ]; then
        echo "No security groups found for VPC $VPC_ID"
    else
        echo "Found security groups: $SECURITY_GROUP_IDS"

        # Process each security group
        for sg_id in $SECURITY_GROUP_IDS; do
            # Check if this is the default security group
            SG_NAME=$(aws ec2 describe-security-groups --group-ids $sg_id --query 'SecurityGroups[0].GroupName' --output text)

            if [ "$SG_NAME" = "default" ]; then
                echo "Skipping default security group: $sg_id (This will be deleted automatically with the VPC)"
                continue
            fi

            echo "Checking dependencies for Security Group: $sg_id"

            # Remove all inbound rules
            echo "Removing inbound rules for $sg_id"
            aws ec2 describe-security-group-rules \
                --filters Name=group-id,Values=$sg_id Name=is-egress,Values=false \
                --query 'SecurityGroupRules[].SecurityGroupRuleId' \
                --output text | tr '\t' '\n' | while read rule_id; do
                if [ ! -z "$rule_id" ]; then
                    aws ec2 revoke-security-group-rules \
                        --group-id $sg_id \
                        --security-group-rule-ids $rule_id
                fi
            done

            # Remove all outbound rules
            echo "Removing outbound rules for $sg_id"
            aws ec2 describe-security-group-rules \
                --filters Name=group-id,Values=$sg_id Name=is-egress,Values=true \
                --query 'SecurityGroupRules[].SecurityGroupRuleId' \
                --output text | tr '\t' '\n' | while read rule_id; do
                if [ ! -z "$rule_id" ]; then
                    aws ec2 revoke-security-group-rules \
                        --group-id $sg_id \
                        --security-group-rule-ids $rule_id
                fi
            done

            # Try to delete the non-default security group
            echo "Attempting to delete security group: $sg_id"
            if aws ec2 delete-security-group --group-id $sg_id; then
                echo "Successfully deleted security group: $sg_id"
            else
                echo "Failed to delete security group: $sg_id"
                echo "Checking what's still referencing this security group..."

                # Check for ENIs using this security group
                aws ec2 describe-network-interfaces \
                    --filters "Name=group-id,Values=$sg_id" \
                    --query 'NetworkInterfaces[].[NetworkInterfaceId,Description]' \
                    --output table
            fi
        done
    fi


    # Delete non-default security groups
    echo "  Checking for Security Groups..."
    sg_ids=$(aws ec2 describe-security-groups \
        --filters "Name=vpc-id,Values=$vpc_id" \
        --query 'SecurityGroups[?GroupName!=`default`].GroupId' \
        --output text)

    for sg_id in $sg_ids; do
        if [ ! -z "$sg_id" ] && [ "$sg_id" != "None" ]; then
            echo "  Processing Security Group: $sg_id"
            aws ec2 delete-security-group --group-id "$sg_id" || \
            echo "  Warning: Could not delete Security Group"
        fi
    done

    # Delete Subnets
    echo "  Checking for Subnets..."
    subnet_ids=$(aws ec2 describe-subnets \
        --filters "Name=vpc-id,Values=$vpc_id" \
        --query 'Subnets[].SubnetId' \
        --output text)

    for subnet_id in $subnet_ids; do
        if [ ! -z "$subnet_id" ] && [ "$subnet_id" != "None" ]; then
            echo "  Deleting Subnet: $subnet_id"
            aws ec2 delete-subnet --subnet-id "$subnet_id" || \
            echo "  Warning: Could not delete Subnet"
        fi
    done

    # Delete Route Tables
    echo "  Checking for Route Tables..."
    rt_ids=$(aws ec2 describe-route-tables \
        --filters "Name=vpc-id,Values=$vpc_id" \
        --query 'RouteTables[?Associations[0].Main!=`true`].RouteTableId' \
        --output text)

    for rt_id in $rt_ids; do
        if [ ! -z "$rt_id" ] && [ "$rt_id" != "None" ]; then
            echo "  Deleting Route Table: $rt_id"
            aws ec2 delete-route-table --route-table-id "$rt_id" || \
            echo "  Warning: Could not delete Route Table"
        fi
    done

    # Final wait before VPC deletion
    echo "  Waiting for all deletions to complete..."
    sleep 30

    # Try to delete the VPC
    echo "  Attempting to delete VPC..."
    if aws ec2 delete-vpc --vpc-id "$vpc_id"; then
        echo "  Successfully deleted VPC: $vpc_id"
    else
        echo "  Failed to delete VPC: $vpc_id"
        echo "  Checking for remaining dependencies..."

        # List remaining ENIs
        remaining_enis=$(aws ec2 describe-network-interfaces \
            --filters "Name=vpc-id,Values=$vpc_id" \
            --query 'NetworkInterfaces[].NetworkInterfaceId' \
            --output text)

        if [ ! -z "$remaining_enis" ]; then
            echo "  Found remaining ENIs: $remaining_enis"
        fi

        # List any remaining security groups
        remaining_sgs=$(aws ec2 describe-security-groups \
            --filters "Name=vpc-id,Values=$vpc_id" \
            --query 'SecurityGroups[].GroupId' \
            --output text)

        if [ ! -z "$remaining_sgs" ]; then
            echo "  Found remaining Security Groups: $remaining_sgs"
        fi
    fi
    echo "----------------------------------------"
}

# Main execution
echo "Starting VPC deletion process..."
echo "Found ${#VPC_LIST[@]} VPCs to process"

read -p "Do you want to proceed with deletion of these VPCs? (y/n): " confirm
if [[ ! $confirm =~ ^[Yy]$ ]]; then
    echo "Operation cancelled"
    exit 0
fi

# Process each VPC in the list
for vpc_id in "${VPC_LIST[@]}"; do
    delete_vpc "$vpc_id"
done

echo "VPC deletion process completed"
