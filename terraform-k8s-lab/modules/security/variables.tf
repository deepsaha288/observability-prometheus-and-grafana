variable "vpc_id" {
  description = "VPC ID for the security group"
  type        = string
}

variable "ssh_cidr" {
  description = "Source CIDR block allowed for SSH access"
  type        = string
  default     = "0.0.0.0/0"
}

variable "security_group_name" {
  description = "Name tag for the security group"
  type        = string
  default     = "k8s-sg"
}
