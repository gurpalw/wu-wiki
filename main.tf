provider "aws" {
  assume_role {
    role_arn = "arn:aws:iam::${var.account_id}:role/${var.assume_role}"
  }

  region  = var.region
  version = "~> 2.0"
}

provider "template" {
  version = "~> 2.0"
}

provider "random" {
  version = "~> 2.1"
}

provider "terraform" {
}

terraform {
  backend "s3" {}
  required_version = "~> 0.12"
}

variable "account" {
  default = "tmp"
}

variable "region" {
  default = "eu-west-1"
}
# Global Variables
variable "account_id" {
  default = "403255647730"
}

variable "assume_role" {
  default = "SRE"
}
