resource "aws_instance" "this" {
  ami           = var.ami_id         # For example, an Amazon Linux 2 AMI.
  instance_type = var.instance_type  # Use "t2.micro" for free tier.
  subnet_id     = var.subnet_id
  key_name      = aws_key_pair.this.key_name

  tags = merge(var.tags, { Name = var.instance_name })
}

resource "aws_key_pair" "this" {
  key_name   = "my-key-pair"
  public_key = var.public_key
}
