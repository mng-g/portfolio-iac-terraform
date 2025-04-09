variable "public_key" {
  description = "The public SSH key to be used for the EC2 instance key pair."
  type        = string
}

variable "key_name" {
  description = "The public SSH key to be used for the EC2 instance key pair."
  type        = string
  default     = "prod-key-pair"
}