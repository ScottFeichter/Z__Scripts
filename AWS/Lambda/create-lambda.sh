#!/bin/bash
export AWS_PAGER=""

# Configuration
LAMBDA_FUNCTIONS=(
    "my-function-1:python3.9:index.handler"
    "my-function-2:nodejs18.x:index.handler"
    # Add more in format "function-name:runtime:handler"
)

# IAM role for Lambda
LAMBDA_ROLE_ARN="arn:aws:iam::YOUR_ACCOUNT_ID:role/YOUR_LAMBDA_ROLE"

# Default memory and timeout
MEMORY_SIZE=128
TIMEOUT=30

create_lambda() {
    local function_config=$1

    # Split the config string
    IFS=':' read -r function_name runtime handler <<< "$function_config"

    echo "Processing Lambda function: $function_name"

    # Check if function already exists
    if aws lambda get-function --function-name "$function_name" >/dev/null 2>&1; then
        echo "  Lambda function already exists: $function_name"
        return 1
    fi

    # Check if deployment package exists
    if [ ! -f "${function_name}.zip" ]; then
        echo "  Error: Deployment package ${function_name}.zip not found"
        return 1
    fi
    }

    echo "  Creating Lambda function..."
    if aws lambda create-function \
        --function-name "$function_name" \
        --runtime "$runtime" \
        --handler "$handler" \
        --role "$LAMBDA_ROLE_ARN" \
        --memory-size "$MEMORY_SIZE" \
        --timeout "$TIMEOUT" \
        --zip-file "fileb://${function_name}.zip"; then

        echo "  Successfully created Lambda function: $function_name"

        # Add tags
        aws lambda tag-resource \
            --resource "$(aws lambda get-function --function-name "$function_name" --query 'Configuration.FunctionArn' --output text)" \
            --tags "Environment=Production,Project=MainApp"

        # Configure function URL (optional)
        read -p "  Do you want to create a function URL? (y/n): " create_url
        if [[ $create_url =~ ^[Yy]$ ]]; then
            aws lambda create-function-url-config \
                --function-name "$function_name" \
                --auth-type "AWS_IAM" \
                --cors '{"AllowOrigins": ["*"]}'
        fi

    else
        echo "  Failed to create Lambda function: $function_name"
        return 1
    fi
    echo "----------------------------------------"
}

# Main execution
echo "Starting Lambda function creation process..."
echo "Found ${#LAMBDA_FUNCTIONS[@]} functions to process"

# Confirm before proceeding
read -p "Do you want to proceed with creation of these Lambda functions? (y/n): " confirm
if [[ ! $confirm =~ ^[Yy]$ ]]; then
    echo "Operation cancelled"
    exit 0
fi

# Process each function
for function_config in "${LAMBDA_FUNCTIONS[@]}"; do
    create_lambda "$function_config"
done

echo "Lambda function creation process completed"
