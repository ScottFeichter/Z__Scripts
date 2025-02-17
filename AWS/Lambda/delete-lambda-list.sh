#!/bin/bash
export AWS_PAGER=""

# List of Lambda functions to delete
LAMBDA_FUNCTIONS=(
    "function-name-1"
    "function-name-2"
    # Add more function names as needed
)

delete_lambda() {
    local function_name=$1
    echo "Processing Lambda function: $function_name"

    # Check if function exists
    if aws lambda get-function --function-name "$function_name" >/dev/null 2>&1; then
        echo "  Function exists, proceeding with deletion..."

        # Check for event source mappings
        echo "  Checking for event source mappings..."
        mappings=$(aws lambda list-event-source-mappings \
            --function-name "$function_name" \
            --query 'EventSourceMappings[].UUID' \
            --output text)

        # Delete event source mappings if they exist
        for mapping in $mappings; do
            if [ ! -z "$mapping" ] && [ "$mapping" != "None" ]; then
                echo "  Deleting event source mapping: $mapping"
                aws lambda delete-event-source-mapping --uuid "$mapping"
            fi
        done

        # Check for function URLs
        echo "  Checking for function URLs..."
        if aws lambda get-function-url-config --function-name "$function_name" >/dev/null 2>&1; then
            echo "  Deleting function URL configuration..."
            aws lambda delete-function-url-config --function-name "$function_name"
        fi

        # Delete function
        echo "  Deleting Lambda function..."
        if aws lambda delete-function --function-name "$function_name"; then
            echo "  Successfully deleted Lambda function: $function_name"
        else
            echo "  Failed to delete Lambda function: $function_name"
        fi
    else
        echo "  Lambda function does not exist: $function_name"
    fi
    echo "----------------------------------------"
}

# Main execution
echo "Starting Lambda function deletion process..."
echo "Found ${#LAMBDA_FUNCTIONS[@]} functions to process"

# Confirm before proceeding
read -p "Do you want to proceed with deletion of these Lambda functions? (y/n): " confirm
if [[ ! $confirm =~ ^[Yy]$ ]]; then
    echo "Operation cancelled"
    exit 0
fi

# Process each function
for function_name in "${LAMBDA_FUNCTIONS[@]}"; do
    delete_lambda "$function_name"
done

echo "Lambda function deletion process completed"
