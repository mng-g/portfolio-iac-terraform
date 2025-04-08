terraform {
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
  source              = "../../modules/vpc"
  vpc_cidr            = "10.1.0.0/16"  # Use a CIDR that suits production
  vpc_name            = "prod-vpc"
  availability_zones  = ["eu-north-1a", "eu-north-1b"] # Adjust based on your needs
  public_subnet_cidrs = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnet_cidrs = ["10.1.3.0/24", "10.1.4.0/24"]
  tags                = { Environment = "prod" }
}

module "ec2" {
  source         = "../../modules/ec2"
  ami_id         = "ami-07a6f770277670015"  # Replace with a free-tier eligible AMI (e.g., Amazon Linux 2)
  instance_type  = "t2.micro"      # Free-tier eligible
  subnet_id      = module.vpc.public_subnets[0]
  instance_name  = "prod-ec2-instance"
  tags           = { Environment = "prod" }
}

# Optionally, you can add additional modules (for networking, security, etc.)
