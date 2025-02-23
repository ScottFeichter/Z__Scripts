#!/bin/bash

export AWS_PAGER=""  # Disable the AWS CLI pager so we don't get json output

# Array of Amplify app IDs - change them to suit your needs
APPS=(
d1uphoh7myr402
d2tqocrnazuw3g
d26hnkizz7i9f2
d3obplo9qahw3y
d3a3z6cdkefh2d
d3h3h8u9u16a4
d34iave1v75sq7 

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
            echo "  Successfully deleted app: $app_id"
        else
            echo "  Failed to delete app: $app_id"
        fi
    else
        echo "  App does not exist: $app_id"
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
