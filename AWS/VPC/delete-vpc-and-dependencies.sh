#!/bin/bash

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
"vpc-0a4778fab58d36e86"
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

    # Terminate EC2 instances first
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

    # Delete non-default security groups
    echo "  Checking for Security Groups..."
    sg_ids=$(aws ec2 describe-security-groups \
        --filters "Name=vpc-id,Values=$vpc_id" \
        --query 'SecurityGroups[?GroupName!=`default`].GroupId' \
        --output text)

    for sg_id in $sg_ids; do
        if [ ! -z "$sg_id" ] && [ "$sg_id" != "None" ]; then
            echo "  Processing Security Group: $sg_id"

            # Check for Lambda functions using this security group
            echo "    Checking for Lambda functions..."
            lambda_functions=$(aws lambda list-functions \
                --query "Functions[?VpcConfig.SecurityGroupIds[?contains(@,'$sg_id')]].FunctionName" \
                --output text)

            if [ ! -z "$lambda_functions" ] && [ "$lambda_functions" != "None" ]; then
                echo "    Warning: Security group is used by Lambda functions: $lambda_functions"
            fi

            # Check for RDS instances using this security group
            echo "    Checking for RDS instances..."
            rds_instances=$(aws rds describe-db-instances \
                --query "DBInstances[?VpcSecurityGroups[?VpcSecurityGroupId=='$sg_id']].DBInstanceIdentifier" \
                --output text)

            if [ ! -z "$rds_instances" ] && [ "$rds_instances" != "None" ]; then
                echo "    Warning: Security group is used by RDS instances: $rds_instances"
            fi

            # Try to delete the security group
            echo "    Attempting to delete Security Group..."
            aws ec2 delete-security-group --group-id "$sg_id" || \
            echo "    Warning: Could not delete Security Group"
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

# Confirm before proceeding
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
