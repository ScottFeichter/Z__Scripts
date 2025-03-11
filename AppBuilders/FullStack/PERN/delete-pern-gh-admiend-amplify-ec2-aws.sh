#!/bin/bash
export AWS_PAGER=""
#######################    NOTE ABOUT APP CLEANUP    ##########################

                # WHEN YOU WANT TO DELTE AN APP'S AWS RESOURCES:

                        # 1. Run the VPC deletion script first (handles all networking/compute)
                        # 2. Then clean up any non-VPC resources your app uses

                # Recourses NOT deleted with the VPC:

                        # 1. EBS Volumes
                        # 2. DynamoDB Tables
                        # 3. IAM Roles/Users/Policies
                        # 4. Route 53 DNS Records
                        # 5. CloudFront Distributions
                        # 6. ECR Repositories
                        # 7. CloudWatch Logs
                        # 8. Lambda Functions (unless VPC-connected)
                        # 9. Certificates (ACM)
                        # 10. Amplify Applications
                        # 11. S3 Buckets
                        # 12. Local Postrgres
                        # 13. Github Repos
                        # 14. Local Files


#######################    DELETE SCRIPT CONFIRMATION   ######################

echo " "
echo "-------------------------------------------------------------------"
echo "⚠️ ACHTUNG: THIS SCRIPT WILL DELETE THE ENTIRE APP INCLUDING AWS SERVICES, GH REPOS, AND LOCAL FILES!!!!!!! ⚠️"
echo "-------------------------------------------------------------------"
echo " "
echo "🚽  LOO FLUSH: This script attempts to delete everything in sequence..."
echo "💥  DATA LOSS: You will LOSE DATA that is associated with this app..."
echo " "
echo "-------------------------------------------------------------------"


# Prompt to user to continue
echo ""
read -p "💣 CONFIRM: Are you sure you want to proceed with app deletion? (y/n): " user_input

# Check the user's response
if [[ "$user_input" =~ ^[Yy]$ ]]; then





#######################    DELETE VPC START    ###############################
echo ""
echo "🛠  ACTION: Deleting VPC... "
echo ""


# List of VPCs to delete
VPC_LIST=(
    "$vpc_id"
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





echo ""
echo "✅ RESULT: VPC delete process finished! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"
#######################    DELETE VPC END    ###############################






#######################    DELETE SUBNETS START   ###############################
echo ""
echo "🛠  ACTION: Deleting Subnets... "
echo ""



# Array of subnet group names - change them to suit your needs
SUBNET_GROUPS=(
"$SUBNET_GROUP_NAME"
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



echo ""
echo "✅ RESULT: Subnet delete process finished! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"
#######################    DELETE SUBNETS END    ###############################







#######################    DELETE RDS START    ###############################
echo ""
echo "🛠  ACTION: Deleting RDS... "
echo ""




# Array of RDS instance identifiers - change them to suit your needs
RDS_INSTANCES=(
"$DB_IDENTIFIER"
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



echo ""
echo "✅ RESULT: RDS delete process finished! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"

#######################    DELETE RDS END    #################################










#######################    DELETE EC2 START    ###############################
echo ""
echo "🛠  ACTION: Deleting EC2... "
echo ""




# Array of EC2 instance IDs - change them to suit your needs
INSTANCES=(
    # !Replace with your instance IDs
"$EC2_INSTANCE_ID"

)

# Function to delete an EC2 instance
delete_instance() {
    local instance_id=$1
    echo "Processing EC2 instance: $instance_id"

    # Check if instance exists by trying to get its details
    if aws ec2 describe-instances --instance-ids "$instance_id" &>/dev/null; then
        echo "  Instance exists, checking state..."

        # Get instance state
        instance_state=$(aws ec2 describe-instances \
            --instance-ids "$instance_id" \
            --query 'Reservations[].Instances[].State.Name' \
            --output text)

        echo "  Current instance state: $instance_state"

        # If instance is running or stopped, terminate it
        if [ "$instance_state" != "terminated" ]; then
            echo "  Terminating instance..."

            # Check if instance has termination protection
            termination_protection=$(aws ec2 describe-instance-attribute \
                --instance-id "$instance_id" \
                --attribute disableApiTermination \
                --query 'DisableApiTermination.Value' \
                --output text)

            if [ "$termination_protection" == "true" ]; then
                echo "  Disabling termination protection..."
                aws ec2 modify-instance-attribute \
                    --instance-id "$instance_id" \
                    --no-disable-api-termination
            fi

            # Terminate the instance
            aws ec2 terminate-instances --instance-ids "$instance_id"

            echo "  Waiting for instance termination..."
            aws ec2 wait instance-terminated --instance-ids "$instance_id"

            if [ $? -eq 0 ]; then
                echo "  Successfully terminated instance: $instance_id"
            else
                echo "  Failed to terminate instance: $instance_id"
            fi
        else
            echo "  Instance is already terminated"
        fi
    else
        echo "  Instance does not exist: $instance_id"
    fi
    echo "----------------------------------------"
}

# Main execution
echo "Starting EC2 instance termination process..."
echo "----------------------------------------"

# Get instance names for confirmation
echo "The following instances will be terminated:"
for instance in "${INSTANCES[@]}"; do
    name=$(aws ec2 describe-tags \
        --filters "Name=resource-id,Values=$instance" "Name=key,Values=Name" \
        --query 'Tags[].Value' \
        --output text)
    echo "Instance ID: $instance (Name: ${name:-No name tag})"
done

# Ask for confirmation
read -p "Are you sure you want to terminate these instances? (y/n): " confirm
if [[ $confirm != [Yy]* ]]; then
    echo "Operation cancelled"
    exit 1
fi

# Process each instance
for instance in "${INSTANCES[@]}"; do
    delete_instance "$instance"
done

echo "Instance termination process complete!"
echo "--------------------------------------"
echo "                                         "
echo "PLEASE DELETE ANY ASSOCIATED KEY PAIRS AND SECURITY GROUPS!!!"
echo "                                         "
echo "Look in AWS EC2 Console at left under Network & Security you can find them."
echo "Also delete associated .pem files."


echo ""
echo "✅ RESULT: EC2 delete process finished! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"


#######################    DELETE EC2 END    #################################




#######################    DELETE EBS START    ###############################
echo ""
echo "🛠  ACTION: Deleting EBS... "
echo ""



# Array of volume IDs - change them to suit your needs
VOLUMES=(
"$EBS_VOLUME_ID"
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



echo ""
echo "✅ RESULT: EBS delete process finished! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"
#######################    DELETE EBS END    ###############################






#######################    DELETE S3 START    ###############################
echo ""
echo "🛠  ACTION: Deleting S3... "
echo ""



# Array of bucket names
BUCKETS=(
"$BUCKET_NAME"
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




echo ""
echo "✅ RESULT: S3 delete process finished! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"
#######################    DELETE S3 END    ###############################




#######################    DELETE AMPLIFY START    ###############################

echo ""
echo "🛠  ACTION: Deleting Amplify... "
echo ""



# Array of Amplify app IDs - change them to suit your needs
APPS=(
"$APP_ID"
)

# Function to delete an Amplify app
delete_app() {
    local app_id=$1
    echo "Processing Amplify app: $app_id"

    # Check if app exists by trying to get its details
    if aws amplify get-app --app-id "$app_id" &>/dev/null; then
        echo "  Deleting app..."
        aws amplify delete-app --app-id "$app_id"

        if [ $? -eq 0 ]; then
            echo "Successfully deleted app: $app_id"
        else
            echo "Failed to delete app: $app_id"
        fi
    else
        echo "App does not exist: $app_id"
    fi
    echo "----------------------------------------"
}

# Main execution
echo "Starting Amplify app deletion process..."
echo "----------------------------------------"

for app in "${APPS[@]}"; do
    delete_app "$app"
done

echo "App deletion process complete!"



echo ""
echo "✅ RESULT: Amplify delete process finished! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"
#######################    DELETE AMPLIFY END    ###############################






#######################    DELETE LOCAL POSTGRES START    ####################
echo ""
echo "🛠  ACTION: Deleting local Postgres... "
echo ""



# Database connection parameters - these should be set as environment variables
DB_HOST=${PGHOST:-"localhost"}
DB_PORT=${PGPORT:-"5432"}
DB_USER=${PGUSER:-"postgres"}
DB_PASSWORD=${PGPASSWORD:-""}

# Array of database names to delete
DATABASES=(
    # BE SURE TO REPLACE THESE WITH THE NAMES YOU WANT TO DELETE
    # ALSO BE SURE YOU HAVE AT LEAST ONE NAME IN HERE OR IT MIGHT BE DANGEROUS
    # YOU DON'T NEED THESE TO BE ENCLOSED IN QUOTES
"$PG_DB_NAME"
)

# Function to delete a PostgreSQL database
delete_database() {
    local db_name=$1
    echo "Processing database: $db_name"

    # Export password for all psql commands
    export PGPASSWORD="$DB_PASSWORD"

    # Check if database exists
    if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -lqt | cut -d \| -f 1 | grep -qw "$db_name"; then
        echo "  Database exists. Proceeding with deletion..."

        # Check if database is being accessed
        local connections=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -t -c \
            "SELECT count(*) FROM pg_stat_activity WHERE datname = '$db_name';")

        if [ "$connections" -gt "0" ]; then
            echo "  Warning: Database has active connections. Forcing disconnection..."
            # Force disconnect all users
            psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -c \
                "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$db_name';" &>/dev/null
        fi

        # Delete the database
        if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -c "DROP DATABASE \"$db_name\";" &>/dev/null; then
            echo "  Successfully deleted database: $db_name"
        else
            echo "  Failed to delete database: $db_name"
        fi
    else
        echo "  Database does not exist: $db_name"
    fi
    echo "----------------------------------------"
}


# Main execution
echo "Starting PostgreSQL database deletion process..."
echo "----------------------------------------"

# Verify psql is installed
if ! command -v psql &>/dev/null; then
    echo "Error: psql is not installed. Please install it first."
    exit 1
fi

# Test database connection
if ! psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -c "SELECT 1;" &>/dev/null; then
    echo "Error: Cannot connect to PostgreSQL. Please check your credentials and connection."
    exit 1
fi


# Display all databases that will be deleted
echo "The following databases will be deleted:"
for db in "${DATABASES[@]}"; do
    echo "  - $db"
done
echo "----------------------------------------"

# Single confirmation prompt
read -p "Are you sure you want to delete these databases? (y/n): " confirm
if [[ $confirm == [yY] ]]; then
    # Process each database
    for db in "${DATABASES[@]}"; do
        delete_database "$db"
    done
    echo "Database deletion process complete!"
else
    echo "Operation cancelled. No databases were deleted."
fi



echo ""
echo "✅ RESULT: Postgres delete process finished! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"
#######################    DELETE LOCAL POSTGRES END    ######################





#######################    DELETE GITHUB REPOS START    ###############################
echo ""
echo "🛠  ACTION: Deleting Github repos... "
echo ""



# Array of repository names - change them to suit your needs
REPOS=(

    # BE SURE TO REPLACE THESE WITH THE NAMES YOU WANT TO DELETE
    # ALSO BE SURE YOU HAVE AT LEAST ON NAME IN HERE OR IT MIGHT DELETE EVERY REPO!!!!!!!!!!!!
    # YOU DON'T NEED THESE TO BE ENCLOSED IN QUOTES
"$ADMIEND_REPO_NAME"
"$FRONTEND_REPO_NAME"
"$BACKEND_REPO_NAME"
)

# Function to delete a GitHub repository
delete_repo() {
    local repo_name=$1
    echo "Processing GitHub repository: $repo_name"

    # Check if repo exists by trying to get its details
    if gh repo view "$repo_name" &>/dev/null; then
        echo "  Repository exists. Requesting deletion..."

        # Prompt for confirmation
        read -p "  Are you sure you want to delete $repo_name? (y/n): " confirm
        if [[ $confirm == [yY] ]]; then
            echo "  Deleting repository..."
            gh repo delete "$repo_name" --confirm

            if [ $? -eq 0 ]; then
                echo "  Successfully deleted repository: $repo_name"
            else
                echo "  Failed to delete repository: $repo_name"
            fi
        else
            echo "  Skipping deletion of: $repo_name"
        fi
    else
        echo "  Repository does not exist: $repo_name"
    fi
    echo "----------------------------------------"
}

# Main execution
echo "Starting GitHub repository deletion process..."
echo "----------------------------------------"

# Verify GitHub CLI is installed and authenticated
if ! command -v gh &>/dev/null; then
    echo "GitHub CLI (gh) is not installed. Please install it first."
    exit 1
fi

if ! gh auth status &>/dev/null; then
    echo "Not authenticated with GitHub. Please run 'gh auth login' first."
    exit 1
fi

# Process each repository
for repo in "${REPOS[@]}"; do
    delete_repo "$repo"
done

echo "Repository deletion process complete!"



echo ""
echo "✅ RESULT: Github repo delete process finished! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"
#######################    DELETE GITHUB REPOS END    ###############################








#######################    DELETE LOCAL FILES START    ####################
echo ""
echo "🛠  ACTION: Deleting local files/fodlers... "
echo ""


# Directories to delete
dirs=("$ADMIEND_REPO_NAME" "$FRONTEND_REPO_NAME" "$BACKEND_REPO_NAME" "$APP_PROJECT_DIR_NAME")

# Iterate through each directory and delete if it exists
for dir in "${dirs[@]}"; do
    if [ -n "$dir" ] && [ -d "$dir" ]; then
        echo "Deleting directory: $dir"
        rm -rf "$dir"
        wait # Ensure deletion is complete before proceeding
    else
        echo "Skipping: $dir (does not exist or is not set)"
    fi
done



echo ""
echo "✅ RESULT: Local files/folders delete process finished! "
echo ""
read -p "⏸️  PAUSE: Press Enter to continue... "
echo ""
echo "-------------------------------------------------------------------"

#######################    DELETE LOCAL FILES END    ######################





########################################################################################################################################################
echo " "
echo "-------------------------------------------------------------------"
echo "📣 UPDATE: YOU HAVE FINISHED THE ENTIRE DELETE SCRIPT!!!!!!!!!!!!!!!!!!!!"
echo "-------------------------------------------------------------------"
echo " "
echo "🗑️ REGRET: You may be able to recover local files in your trash bin..."
echo "⚰️ TERMINATED: Your AWS services and Github repos are terminated!"
echo " "
echo "-------------------------------------------------------------------"
echo ""
echo "👋 GOODBYE: Program finished!"
echo ""
exit 0

else
  echo "👋 GOODBYE: Program finished!"
  exit 0
fi
