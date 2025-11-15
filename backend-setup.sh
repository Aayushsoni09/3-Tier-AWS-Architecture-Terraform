#!bin/bash

BUCKET_NAME = "tf-3tier-state-bucket"
DYNAMODB_TABLE = "terraform-state-lock"
REGION = "ap-south-1"

# Create S3 bucket for state

aws s3api create-bucket \
    --bucket $BUCKET_NAME \
    --region $REGION

# Enable versioning (to recover from accidents)

aws s3api put-bucket-versioning \ 
    --bucket $BUCKET_NAME \
    --versioning-configuration Status = Enabled

# Enable Encryption

aws s3api put-bucket-encryption \
    --bucket $BUCKET_NAME \
    --server-side-encryption-configuration '{
        "Rules": [{
        "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
            }
        }]
    }'

# Block Public Access

aws s3api put-public-access-block \
    --bucket $BUCKET_NAME \
    --public-access-block-configuration \ 
        BlockPublicAcls=true,\
        IgnorePublicAcls=true,\
        BlockPublicPolicy=true,\
        RestrictPublicBuckets=true

# Create DynamoDB table for state locking

aws dynamo create-table \
    -table-name $DYNAMODB_TABLE \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region $REGION

echo "Backend resources created successfully"