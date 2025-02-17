#!/bin/bash

# This script includes creating a key pair, security group, and launching the EC2 instance.

#######################################################################################
# To make the script executable:

    # chmod +x create-ec2.sh


#######################################################################################
# THIS SCRIPT TAKES AN ARGUMENT - TO RUN IT:

    # ./create-ec2.sh $some-instance-name-of-your-choice


#######################################################################################
# Before running this script, make sure:

    # 1. You have AWS CLI installed and configured with your credentials [2]

    # 2. You have sufficient permissions to create EC2 resources

    # 3. Update the AMI_ID variable according to your region and preferred AMI

    # 4. Update the INSTANCE_TYPE if you want a different instance size


#######################################################################################
# The script will:

    # 1. Check if an instance exists with the same name and date

        # - If found, extract the version number from the instance name

        # - Increment the version number for the new instance

    # 2. Create a new instance name with the format: NAME_ARG-DATE-VERSION

    # 3. Create a new key pair and save it locally

    # 4. Create a security group with SSH access [3]

    # 5. Launch an EC2 instance with the specified configurations

    # 6. Wait for the instance to be running

    # 7. Display the connection information


#######################################################################################
# Important security notes:

# - The script creates a security group that allows SSH access from anywhere (0.0.0.0/0).
    # - In production, you should restrict this to specific IP ranges.

# - The private key file (.pem) is saved in the current directory. Keep it secure and never share it.

# - Consider adding additional security group rules based on your needs.


#######################################################################################
#######################################################################################
# THE SCRIPT:

# Disable AWS CLI pager to prevent requiring 'q' to continue
export AWS_PAGER=""

# Exit if any command fails
set -e

# Check if argument is provided
if [ $# -ne 1 ]; then
    echo "You must enter an argument for the instance name. Please try again."
    exit 1
fi


# Variables
NAME_ARG=$1
CREATE_DATE=$(date '+%m-%d-%Y')
EC2_INSTANCE_VERSION_EXISTS=false
INSTANCE_VERSION=1
MOST_RECENT_INSTANCE_VERSION="none"


# Check if instance with similar name exists
if aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=${NAME_ARG}*" \
    --query "Reservations[*].Instances[*].[InstanceId]" \
    --output text | grep -q .; then
    EC2_INSTANCE_VERSION_EXISTS=true
    echo "Recent version found..."

    # ADD DEBUGGING OUTPUT HERE - START
    echo "Debug: Listing all matching instance names:"
    aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=${NAME_ARG}-${CREATE_DATE}*" \
        --query "Reservations[*].Instances[*].Tags[?Key=='Name'].Value" \
        --output text

    echo "Debug: Attempting to extract version numbers:"
    aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=${NAME_ARG}-${CREATE_DATE}*" \
        --query "Reservations[*].Instances[*].Tags[?Key=='Name'].Value" \
        --output text | grep -o '[0-9]*$'
    # ADD DEBUGGING OUTPUT HERE - END

    # Get the highest version number from existing instances
    MOST_RECENT_INSTANCE_VERSION=$(aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=${NAME_ARG}-${CREATE_DATE}*" \
        --query "Reservations[*].Instances[*].Tags[?Key=='Name'].Value" \
        --output text | grep -o '[0-9]*$' | sort -nr | head -n 1)

    if [ -n "$MOST_RECENT_INSTANCE_VERSION" ]; then
        echo "Instance with similar name exists: Version $MOST_RECENT_INSTANCE_VERSION"
        echo "Incrementing version..."
        INSTANCE_VERSION=$((MOST_RECENT_INSTANCE_VERSION + 1))
    else
        echo "Found instance but couldn't determine version, using default version 1"
    fi

else
    echo "No instance with name including $1 is found..."
fi





echo "Ready to generate instance..."
INSTANCE_NAME="$1-$CREATE_DATE-$INSTANCE_VERSION"

# Print the variables (for verification)
echo "Name Argument: $NAME_ARG"
echo "Creation Date: $CREATE_DATE"
echo "Instance Exists: $EC2_INSTANCE_VERSION_EXISTS"
echo "Instance Version: $INSTANCE_VERSION"
echo "Final Instance Name: $INSTANCE_NAME"


KEY_PAIR_NAME="${INSTANCE_NAME}-key-pair"
SECURITY_GROUP_NAME="${INSTANCE_NAME}-security-group"
INSTANCE_TYPE="t2.micro"
AMI_ID="ami-0440d3b780d96b29d"  # Amazon Linux 2023 AMI (adjust for your region)
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query "Vpcs[0].VpcId" --output text)


echo "Checking for existing key pair..."
if aws ec2 describe-key-pairs --key-names "$KEY_PAIR_NAME" 2>&1 | grep -q 'does not exist'; then
    echo "Creating new key pair..."
    # Create key pair and save private key
    aws ec2 create-key-pair \
        --key-name "$KEY_PAIR_NAME" \
        --query "KeyMaterial" \
        --output text > "${KEY_PAIR_NAME}.pem"

    # Set correct permissions for private key
    chmod 400 "${KEY_PAIR_NAME}.pem"
    echo "Key pair created successfully"
else
    echo "Key pair $KEY_PAIR_NAME already exists"
    if [ ! -f "${KEY_PAIR_NAME}.pem" ]; then
        echo "Warning: Key pair exists in AWS but .pem file not found locally..."
        echo "    You may want to delete the key pair in AWS and run again to create a new key pair:"
        echo "        - You can do this in the AWS EC2 console"
        echo "        - In the left navigation pane click Key Pairs under Network & Security"
        exit 1
    fi
fi



echo "Creating security group..."
# Create security group and capture only the ID part
SECURITY_GROUP_ID=$(aws ec2 create-security-group \
    --group-name "$SECURITY_GROUP_NAME" \
    --description "Security group for EC2 instance" \
    --vpc-id "$VPC_ID" \
    --query 'GroupId' \
    --output text | grep -o 'sg-[a-zA-Z0-9]*')

# Add debug output to verify security group ID
echo "Security Group ID: $SECURITY_GROUP_ID"

# Add inbound rules for SSH (port 22)
aws ec2 authorize-security-group-ingress \
    --group-id "$SECURITY_GROUP_ID" \
    --protocol tcp \
    --port 22 \
    --cidr "0.0.0.0/0"




echo "Launching EC2 instance..."
# Launch EC2 instance
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id "$AMI_ID" \
    --instance-type "$INSTANCE_TYPE" \
    --key-name "$KEY_PAIR_NAME" \
    --security-group-ids "$SECURITY_GROUP_ID" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_NAME}]" \
    --query 'Instances[0].InstanceId' \
    --output text)

echo "Waiting for instance to be running..."
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"

# Get public IP address
PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)

echo "                                             "
echo "EC2 instance has been created successfully!!!"
echo "Please secure your .pem file and keys!"
echo "                                             "
echo "Instance ID: $INSTANCE_ID"
echo "Public IP: $PUBLIC_IP"
echo "                                             "
echo "To connect to your instance:"
echo "ssh -i ${KEY_PAIR_NAME}.pem ec2-user@${PUBLIC_IP}"
