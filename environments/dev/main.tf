terraform {
  backend "remote" {
    organization = "mng-g"
    workspaces {
      name = "portfolio-iac-terraform-dev"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

module "vpc" {
  source              = "../../modules/vpc"
  vpc_cidr            = "10.0.0.0/16"
  vpc_name            = "dev-vpc"
  availability_zones  = ["eu-north-1a", "eu-north-1b"]
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
  tags                = { Environment = "dev" }
}

module "ec2" {
  source         = "../../modules/ec2"
  ami_id         = "ami-0a2370e7c0f21e179" # Use an appropriate free-tier eligible AMI (e.g., Amazon Linux 2)
  instance_type  = "t3.micro"
  subnet_id      = module.vpc.public_subnets[0]
  public_key     = var.public_key     # Pass the root variable to the module
  key_name       = var.key_name      # Pass the key name variable to the module
  vpc_id         = module.vpc.vpc_id    # Pass the VPC ID from your VPC module
  instance_name  = "dev-ec2-instance"
  tags           = { Environment = "dev" }
}
