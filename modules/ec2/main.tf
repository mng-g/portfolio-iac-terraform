resource "aws_instance" "this" {
  ami           = var.ami_id         # For example, an Amazon Linux 2 AMI.
  instance_type = var.instance_type  # Use "t2.micro" for free tier.
  subnet_id     = var.subnet_id
  key_name      = aws_key_pair.this.key_name
  vpc_security_group_ids = [aws_security_group.ec2_ssh.id]  # Attach the new SG


  #tags = merge(var.tags, { Name = var.instance_name })
}

resource "aws_key_pair" "this" {
  key_name   = var.key_name
  public_key = var.public_key
}

resource "aws_security_group" "ec2_ssh" {
  name        = "ec2-ssh-sg"
  description = "Security group allowing SSH access from anywhere"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #tags = merge(var.tags, { Name = "ec2-ssh-sg" })
}
