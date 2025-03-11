#!/bin/bash

export AWS_PAGER=""  # Disable the AWS CLI pager so we don't get json output

# Array of Amplify app IDs - change them to suit your needs
APPS=(
d27xzi242brt2d
d1kajpql1k8j0z
d3vp3k229aie0p
d1g5vbigr7kmsk
dfodtmhgd0vgb
d1x1ht6d5dt5ng
d1uwck2114cjz7
d1tj1macx0qyf0
dd97xuam06t67
d12k8xzexl03ov
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
