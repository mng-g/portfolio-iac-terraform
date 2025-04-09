variable "ami_id" {
  description = "AMI to use for the instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "Subnet ID where the instance will be deployed"
  type        = string
}

variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
}

variable "tags" {
  description = "Common tags for the instance"
  type        = map(string)
  default     = {}
}

variable "public_key" {
  description = "Public key for accessing EC2"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID in which the EC2 instance will be launched."
  type        = string
}
