# Create the s3 remote backend running this commands
# aws s3api create-bucket --bucket terraform-state-bucket-ctomas --region us-east-1
# aws s3api put-bucket-versioning --bucket erraform-state-bucket-ctomas --versioning-configuration Status=Enabled
# aws s3api put-bucket-encryption --bucket terraform-state-bucket-ctomas --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
# aws dynamodb create-table \
#   --table-name terraform-lock \
#   --attribute-definitions AttributeName=LockID,AttributeType=S \
#   --key-schema AttributeName=LockID,KeyType=HASH \
#   --billing-mode PAY_PER_REQUEST

# terraform {
#   backend "s3" {
#     bucket         = "terraform-state-bucket-ctomas"
#     key            = "terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "terraform-lock"
#     encrypt        = true
#   }
# }
