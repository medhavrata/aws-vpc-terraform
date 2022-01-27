data "terraform_remote_state" "network-config" {
  backend = "s3"
  config = {
    bucket = "terraform-state-bucket-180122"
    key    = "network-config/terraform.tfstate"
    region = "us-east-1"
  }
}


# Filter the aws ami
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
