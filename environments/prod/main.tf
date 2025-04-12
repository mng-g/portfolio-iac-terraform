terraform {
  required_version = ">= 1.3.0" # Set to a recent stable version
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0" # Change this to the desired version range
    }
  }
  backend "remote" {
    organization = "mng-g"
    workspaces {
      name = "portfolio-iac-terraform-prod"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

module "vpc" {
  source               = "../../modules/vpc"
  vpc_cidr             = "10.1.0.0/16" # Use a CIDR that suits production
  vpc_name             = "prod-vpc"
  availability_zones   = ["eu-north-1a", "eu-north-1b"] # Adjust based on your needs
  public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnet_cidrs = ["10.1.3.0/24", "10.1.4.0/24"]
  tags                 = { Environment = "Prod" }
}

module "ec2" {
  source        = "../../modules/ec2"
  ami_id        = "ami-0a2370e7c0f21e179" # Replace with a free-tier eligible AMI (e.g., Amazon Linux 2)
  instance_type = "t3.micro"              # Free-tier eligible
  subnet_id     = module.vpc.public_subnets[0]
  public_key    = var.public_key    # Pass the root variable to the module
  key_name      = var.key_name      # Pass the key name variable to the module
  vpc_id        = module.vpc.vpc_id # Pass the VPC ID from your VPC module
  instance_name = "prod-ec2-instance"
  tags          = { Environment = "Prod" }
}

module "monitoring" {
  source      = "../../modules/monitoring"
  instance_id = module.ec2.instance_id
  environment = "prod"
  tags        = { Environment = "Prod" }
}
