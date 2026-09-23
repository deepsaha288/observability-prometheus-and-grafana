terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source            = "../../modules/vpc"
  vpc_cidr          = var.vpc_cidr
  public_subnet     = var.public_subnet
  private_subnet    = var.private_subnet
  availability_zone = var.availability_zone
}

module "security" {
  source             = "../../modules/security"
  vpc_id             = module.vpc.vpc_id
  ssh_cidr           = var.ssh_cidr
  security_group_name = var.security_group_name
}

data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

module "ec2" {
  source            = "../../modules/ec2"
  ami_id            = data.aws_ami.ubuntu.id
  instance_type     = var.instance_type
  subnet_id         = module.vpc.public_subnet_id
  security_group_id = module.security.security_group_id
  key_name          = var.key_name
  user_data         = file("../../install-runtime.sh")
  instance_name     = var.instance_name
}
