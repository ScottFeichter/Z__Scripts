#!/bin/bash
########################################################################################################################################################
# NOTE ABOUT APP CLEANUP

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

need to have the create script output a text file in the admiend with information for all the services

VPC
EBS
S3 Bucket for admiend
Amplify App
GitHub Repos
Directories
