bucket       = "tf-state-lab"
region       = "us-east-1"
use_lockfile = true
# dynamodb_table = "tf-locks"   # fallback if the emulator ignores conditional writes

use_path_style              = true
skip_credentials_validation = true
skip_metadata_api_check     = true
skip_region_validation      = true
skip_requesting_account_id  = true

endpoints = {
  s3 = "http://localhost:5000"
  # dynamodb = "http://localhost:5000"
}
