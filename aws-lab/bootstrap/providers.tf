provider "aws" {
  region                      = var.region
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    s3       = var.endpoint
    dynamodb = var.endpoint
    ec2      = var.endpoint
    sts      = var.endpoint
    iam      = var.endpoint
  }
}
