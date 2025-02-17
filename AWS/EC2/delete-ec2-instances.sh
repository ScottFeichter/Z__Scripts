#!/bin/bash

export AWS_PAGER=""  # Disable the AWS CLI pager so we don't get json output

# Array of EC2 instance IDs - change them to suit your needs
INSTANCES=(
    # !Replace with your instance IDs
    "i-00e48f607c50c47ad"


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
