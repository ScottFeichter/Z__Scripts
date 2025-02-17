#!/bin/bash

export AWS_PAGER=""  # Disable the AWS CLI pager so we don't get json output

# Array of Elastic Beanstalk application names - change them to suit your needs
APPS=(
"generic-11"
)

# Function to delete an Elastic Beanstalk application
delete_app() {
    local app_name=$1
    echo "Processing Elastic Beanstalk application: $app_name"

    # Check if app exists by trying to get its details
    if aws elasticbeanstalk describe-applications --application-names "$app_name" &>/dev/null; then
        echo "  Application exists, checking for environments..."

        # Get all environments for this application
        environments=$(aws elasticbeanstalk describe-environments \
            --application-name "$app_name" \
            --query "Environments[].EnvironmentName" \
            --output text)

        # Terminate all environments first if they exist
        if [ -n "$environments" ]; then
            echo "  Terminating environments..."
            for env in $environments; do
                echo "    Terminating environment: $env"
                aws elasticbeanstalk terminate-environment --environment-name "$env"
                echo "    Waiting for environment termination..."
                aws elasticbeanstalk wait environment-terminated \
                    --application-name "$app_name" \
                    --environment-name "$env"
            done
        fi

        # Delete application versions
        echo "  Deleting application versions..."
        aws elasticbeanstalk delete-application-versions \
            --application-name "$app_name" \
            --delete-source-bundle \
            --force-delete

        # Delete the application
        echo "  Deleting application..."
        aws elasticbeanstalk delete-application \
            --application-name "$app_name" \
            --terminate-env-by-force

        if [ $? -eq 0 ]; then
            echo "  Successfully deleted application: $app_name"
        else
            echo "  Failed to delete application: $app_name"
        fi
    else
        echo "  Application does not exist: $app_name"
    fi
    echo "----------------------------------------"
}

# Main execution
echo "Starting Elastic Beanstalk application deletion process..."
echo "----------------------------------------"

for app in "${APPS[@]}"; do
    delete_app "$app"
done

echo "Application deletion process complete!"
