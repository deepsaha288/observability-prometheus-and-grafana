variable "aws_region" {
  description = "AWS region to deploy the environment"
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
}

variable "public_subnet" {
  description = "Public subnet CIDR block"
  default     = "10.0.1.0/24"
}

variable "private_subnet" {
  description = "Private subnet CIDR block"
  default     = "10.0.2.0/24"
}

variable "availability_zone" {
  description = "Availability zone for subnets"
  default     = "ap-south-1a"
}

variable "ssh_cidr" {
  description = "CIDR block for SSH access"
  default     = "0.0.0.0/0"
}

variable "security_group_name" {
  description = "Name for the security group"
  default     = "k8s-sg"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.medium"
}

variable "key_name" {
  description = "Existing AWS Key Pair"
  default     = "eks8_key"
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  default     = "k8s-master"
}
