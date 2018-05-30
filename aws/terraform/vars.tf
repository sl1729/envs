# Configure the Terraform backend to be stored into the S3 and not local
terraform {
  backend "s3" {
    bucket = "sl1729"            #bucket created as a pre-requisite
    region = "ap-southeast-1"
    key    = "terraform.tfstate" #file name to be used for the store
  }
}

# Configuration for TF_VAR_access_key and TF_VAR_secret_key will be derived from the environment variable
provider "aws" {
  region = "${var.region}"
}

#Default region
variable "region" {
  type    = "string"
  default = "ap-southeast-1"
}

#Id of me
variable "owner_id" {
  type    = "string"
  default = "702039097694"
}

variable "jboss-ami" {
  type    = "string"
  default = "ami-b0734ecc"
}
