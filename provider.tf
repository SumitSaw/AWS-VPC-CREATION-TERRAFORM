provider "aws" {
  region                  = "${var.region}"
  shared_credentials_file = "/home/sumit/.aws/config"
  profile                 = "default"
}