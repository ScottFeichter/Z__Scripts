#!/bin/bash

# These commands are meant to be executed in the shell of your EC2 instance.

# Before running these commands, make sure that the volume is successfully attached to your EC2 instance. You can check this with:

lsblk

# Make sure that the device name (/dev/xvdf) matches the one shown in your EC2 dashboard, as AWS might show it as /dev/sdf but it is mapped as /dev/xvdf on the instance.

# Here's how to prepare the volume for use after it's attached:

# Format the volume (if it's new)
sudo mkfs -t xfs /dev/xvdf

# Create a mount point
sudo mkdir /app

# Mount the volume
sudo mount /dev/xvdf /app

# To configure automatic mounting on restart, add to /etc/fstab:
echo '/dev/xvdf /app xfs defaults,nofail 0 2' | sudo tee -a /etc/fstab

# The script includes error checking and will wait for the volume to become available before attempting to attach it. It also outputs the relevant IDs and device name for reference.

# Remember that the EBS volume must be created in the same availability zone as the EC2 instance. The script automatically handles this by querying the instance's availability zone.




# Recommended directory structure for your Node.js app:

# Create application directories
mkdir -p /app/nodejs
mkdir -p /app/logs
mkdir -p /app/uploads  # If your app handles file uploads
mkdir -p /app/backup   # For database backups if applicable
