#!/bin/bash

aws rds create-db-instance \
    --db-instance-identifier my-postgres-db \
    --db-instance-class db.t3.micro \
    --engine postgres \
    --engine-version 15.4 \
    --master-username postgres \
    --master-user-password "${DB_PASSWORD}" \
    --allocated-storage 20 \
    --storage-type gp3 \
    --vpc-security-group-ids sg-xxxxxxxx \
    --db-subnet-group-name my-db-subnet-group \
    --publicly-accessible \
    --port 5432 \
    --backup-retention-period 7 \
    --multi-az false \
    --auto-minor-version-upgrade true \
    --deletion-protection true \
    --storage-encrypted true

# The instance will take several minutes to create. You can monitor the creation status using:

aws rds describe-db-instances --db-instance-identifier my-postgres-db


# Let's break down the important parameters:

        # --db-instance-identifier: A unique name for your database instance

        # --db-instance-class: The compute and memory capacity (t3.micro is good for development)

        # --engine: Specifies PostgreSQL as the database engine

        # --allocated-storage: Size in GB (20 is the minimum)

        # --master-username: The master user for the database

        # --master-user-password: Using environment variable for security

        # --storage-type: gp3 is the latest general-purpose SSD storage type

        # --vpc-security-group-ids: Your VPC security group ID (replace sg-xxxxxxxx with yours) [2]

        # --db-subnet-group-name: Your database subnet group name

        # --backup-retention-period: Number of days to retain automated backups

        # --storage-encrypted: Enables encryption at rest

# Before running this command, make sure to:

        # Set up your DB_PASSWORD environment variable

        # Replace the security group ID with your actual security group

        # Create and specify the correct DB subnet group

        # Adjust the instance class and storage based on your needs

# Optional parameters you might want to consider:

        # --availability-zone: Specify a particular AZ

        # --preferred-backup-window: Set specific backup time window

        # --preferred-maintenance-window: Set specific maintenance time window

        # --tags: Add tags for better resource management
