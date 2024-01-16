provider "aws" {
  region = "eu-west-1"

  allowed_account_ids = var.allowed_account_ids
}

terraform {
  backend "s3" {
    key = "medium-terraform/prod/terraform.tfstate"
    # ...
  }
}

locals {
  create_vpc = var.vpc_id == ""
}

module "network" {
  source = "../modules/network"

  name = var.name

  cidr = var.cidr
  azs  = var.azs
  public_subnets = var.public_subnets
}

data "aws_vpc" "selected" {
  count = local.create_vpc ? 0 : 1

  id = var.vpc_id
}

resource "aws_vpc" "this" {
  count = local.create_vpc ? 1 : 0

  cidr_block = var.cidr
}

resource "aws_internet_gateway" "this" {
  vpc_id = try(data.aws_vpc.selected[0].id, aws_vpc.this[0].id)
}



module "alb" {
  source = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  #...
}
