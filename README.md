# Learn Terraform - Provision an EKS Cluster

## Create s3 bucket and dynamo DB for terraform backend

- Create s3 bucket:
    <br> `aws s3 mb "s3://<NAME>" --region "eu-west-2" `

-  Enable Versioning for S3 Bucket
<br>`aws s3api put-bucket-versioning --bucket "<NAME>" --versioning-configuration Status=Enabled`

- Create DynamoDB Table
<br> `aws dynamodb create-table --table-name "tf-lock-table" --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 --region eu-west-2"`

-  Apply policy to s3 bucket
<br><div>NOTE:  Edit policy.json values first</div>
<br>`aws s3api put-bucket-policy --bucket "<NAME>" --policy file://policy.json`

- Add values in terraform.tf accordingly

Steps that need to be followed :-
1. Install terraform 
2. Run aws configure
3. terraform init
4. terraform apply --auto-approve


Once you are done testing just remove the infrastructure using
terraform destroy --auto-approve# terraform-aws-eks-weaviate
