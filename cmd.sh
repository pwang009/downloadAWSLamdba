#!/bin/bash

# Script to download a specific AWS Lambda function
# Checks for 'prod' alias first, falls back to $LATEST if no alias exists

# Check if Lambda name was provided
if [ -z "$1" ]; then
    echo "Error: Please provide a Lambda function name as an argument"
    echo "Usage: $0 <lambda-function-name>"
    exit 1
fi

# Configuration
LAMBDA_NAME=$1
OUTPUT_DIR="./src"
AWS_REGION="us-west-1"  # Change to your region

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

echo "Processing Lambda function: $LAMBDA_NAME"

# Check if 'prod' alias exists for this function
alias_exists=$(aws lambda list-aliases --function-name "$LAMBDA_NAME" --region $AWS_REGION \
              --query "Aliases[?Name=='prod'].Name" --output text)

if [ "$alias_exists" == "prod" ]; then
    # Download the version with 'prod' alias
    echo "  Found 'prod' alias, downloading that version"
    output_file="$OUTPUT_DIR/${LAMBDA_NAME}_prod.zip"
    aws lambda get-function --function-name "$LAMBDA_NAME:prod" --region $AWS_REGION \
        --query 'Code.Location' --output text | xargs wget -O "$output_file"
    echo "  Saved to: $output_file"
else
    # Download the $LATEST version
    echo "  No 'prod' alias found, downloading \$LATEST version"
    output_file="$OUTPUT_DIR/${LAMBDA_NAME}.zip"
    aws lambda get-function --function-name "$LAMBDA_NAME" --region $AWS_REGION \
        --query 'Code.Location' --output text | xargs wget -O "$output_file"
    echo "  Saved to: $output_file"
fi

echo "Download complete"

# xargs -n 1 ./cmd.sh < lambda.txt