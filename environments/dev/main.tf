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

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
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
  ami_id         = data.aws_ami.amazon_linux_2.id  # Use an appropriate free-tier eligible AMI (e.g., Amazon Linux 2)
  instance_type  = "t2.micro"
  subnet_id      = module.vpc.public_subnets[0]
  instance_name  = "dev-ec2-instance"
  tags           = { Environment = "dev" }
}
