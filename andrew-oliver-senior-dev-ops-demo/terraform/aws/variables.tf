### Defaults ###
# Default Env selection
variable "env" {
  default = "dev"
  validation {
    condition     = contains(["dev", "stage", "prod"], var.env)
    error_message = "Valid values for var: env are (dev, stage, prod)."
  } 
}

# Region to set up infrastructure in
variable "aws_region" {
  default = "us-east-2"
}

# Availability zones to set up infrastructure in
variable "aws_azs" {
  default = ["a", "b", "c"]
}

# Default application Name
variable "app_name" {
  default = "cardinal"
}

### VPC Variables ###
# Default CIDR block for VPC
variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

### RDS Variables ###
# Default RDS engine type
variable "rds_engine_type" {
  default = "aurora-postgresql"
}

# Default RDS engine version
variable "rds_engine_version" {
  default = "12.16"
}

# Default RDS instance size
variable "rds_instance_size" {
  default = "db.t3.medium"
}

# Default RDS instance username
variable "rds_instance_username" {
  default = "postgres"
  sensitive = true
}

# Default RDS storage size
variable "rds_storage_size" {
  default = "20"
}

### EC2 Variables ###
# The name of the ami in the marketplace to run on our instance
variable "aws_ami_id" {
  default = "ami-06d4b7182ac3480fa"
}

# Default EC2 instance size
variable "ec2_instance_size" {
  default = "t2.micro"
}

# User to log in to instances and perform install ops with
variable "remote_user" {
  default = "ec2-user"
  sensitive = true
}

# Path to your public key, which will be used to log in to ec2 instances
variable "public_key" {
  default = "~/.ssh/cardinal-gitlab-ssh-key.pub"
  sensitive = true
}

# Path to your private key that matches your public from ^^
variable "private_key" {
  default = "~/.ssh/cardinal-gitlab-ssh-key"
  sensitive = true
}