data "terraform_remote_state" "network-config" {
  backend = "s3"
  config = {
    bucket = "terraform-state-bucket-180122"
    key    = "network-config/terraform.tfstate"
    region = "us-east-1"
  }
}
