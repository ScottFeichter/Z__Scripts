#!/bin/bash

    # Important notes:

        # 1.  The script assumes your VPC has at least two private subnets (required for RDS)

        # 2.  Security group CIDR should be adjusted to match your VPC's CIDR

        # 3.  The RDS instance will only be accessible from within the VPC

        # 4.  You'll need a bastion host or VPN to connect if you're outside the VPC

        # 5.  The script waits for the RDS instance to be available (can take 5-10 minutes)


    # To use this script:

        # 1.  Set your DB\_PASSWORD environment variable:

            # export DB_PASSWORD='your-secure-password'

        # 2.  Adjust the CIDR range in the security group rule to match your VPC

        # 3.  Make sure you have at least two private subnets in your VPC

        # 4.  Run the script

########################################################################################################################################################
# RDS requires 2 subnets in different Availability Zones primarily for high availability and disaster recovery purposes, even if you're not using Multi-AZ deployment initially. Here's why: 

    # 1.  Multi-AZ Deployment Support:


            # *   Even if you start with Single-AZ ( \--multi-az false), AWS wants to ensure you can easily switch to Multi-AZ later

            # *   In Multi-AZ, RDS maintains a synchronous standby replica in a different AZ

            # *   If the primary DB instance fails, RDS automatically fails over to the standby


    # 2. DB Subnet Group Requirements:

            # *   A DB subnet group must have at least one subnet in at least two AZs 

            # *   This is a hard requirement from AWS, even for Single-AZ deployments

            # * From the AWS docs: "Amazon RDS requires at least two subnets in two different Availability Zones to support Multi-AZ DB instance deployments"







# Disable AWS CLI pager
export AWS_PAGER=""

# Exit if any command fails
set -e

# Check if DB_PASSWORD is set
if [ -z "$DB_PASSWORD" ]; then
    echo "Error: DB_PASSWORD environment variable must be set"
    exit 1
fi

# Variables
DB_IDENTIFIER="my-postgres-db"
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query "Vpcs[0].VpcId" --output text)
SUBNET_GROUP_NAME="my-db-subnet-group"
DB_SECURITY_GROUP_NAME="rds-postgres-sg"

# Verify VPC exists
if [ -z "$VPC_ID" ] || [ "$VPC_ID" = "None" ]; then
    echo "Error: No VPC found"
    exit 1
fi

echo "Using VPC: $VPC_ID"

# Get private subnets from VPC
echo "Finding private subnets in VPC..."
PRIVATE_SUBNET_IDS=$(aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$VPC_ID" \
    --query 'Subnets[?MapPublicIpOnLaunch==`false`].SubnetId' \
    --output text)

if [ -z "$PRIVATE_SUBNET_IDS" ]; then
    echo "Error: No private subnets found in VPC"
    exit 1
fi

# Create DB subnet group
echo "Creating DB subnet group..."
aws rds create-db-subnet-group \
    --db-subnet-group-name "$SUBNET_GROUP_NAME" \
    --db-subnet-group-description "Subnet group for PostgreSQL RDS" \
    --subnet-ids $PRIVATE_SUBNET_IDS || {
        echo "Error creating DB subnet group. It might already exist."
    }

# Create security group for RDS
echo "Creating security group for RDS..."
SECURITY_GROUP_ID=$(aws ec2 create-security-group \
    --group-name "$DB_SECURITY_GROUP_NAME" \
    --description "Security group for PostgreSQL RDS" \
    --vpc-id "$VPC_ID" \
    --query 'GroupId' \
    --output text)

# Add inbound rule for PostgreSQL (adjust CIDR as needed)
echo "Adding security group rules..."
aws ec2 authorize-security-group-ingress \
    --group-id "$SECURITY_GROUP_ID" \
    --protocol tcp \
    --port 5432 \
    --cidr "10.0.0.0/16"  # Adjust this to your VPC CIDR

# Create RDS instance
echo "Creating RDS instance..."
aws rds create-db-instance \
    --db-instance-identifier "$DB_IDENTIFIER" \
    --db-instance-class db.t3.micro \
    --engine postgres \
    --engine-version 15.4 \
    --master-username postgres \
    --master-user-password "${DB_PASSWORD}" \
    --allocated-storage 20 \
    --storage-type gp3 \
    --vpc-security-group-ids "$SECURITY_GROUP_ID" \
    --db-subnet-group-name "$SUBNET_GROUP_NAME" \
    --no-publicly-accessible \
    --port 5432 \
    --backup-retention-period 7 \
    --multi-az false \
    --auto-minor-version-upgrade true \
    --deletion-protection true \
    --storage-encrypted true \
    --tags "Key=Name,Value=$DB_IDENTIFIER"

echo "Waiting for RDS instance to be available..."
aws rds wait db-instance-available --db-instance-identifier "$DB_IDENTIFIER"

# Get instance details
INSTANCE_INFO=$(aws rds describe-db-instances \
    --db-instance-identifier "$DB_IDENTIFIER" \
    --query 'DBInstances[0].[Endpoint.Address,Endpoint.Port,DBInstanceStatus]' \
    --output text)

ENDPOINT=$(echo $INSTANCE_INFO | cut -d' ' -f1)
PORT=$(echo $INSTANCE_INFO | cut -d' ' -f2)
STATUS=$(echo $INSTANCE_INFO | cut -d' ' -f3)

echo "----------------------------------------"
echo "RDS Instance Created Successfully!"
echo "Endpoint: $ENDPOINT"
echo "Port: $PORT"
echo "Status: $STATUS"
echo "----------------------------------------"
echo "Connection string format:"
echo "postgresql://postgres:${DB_PASSWORD}@${ENDPOINT}:${PORT}/postgres"
echo "----------------------------------------"
echo "Note: This RDS instance is in private subnets."
echo "To connect, you'll need to be in the VPC (e.g., through a bastion host or VPN)"
