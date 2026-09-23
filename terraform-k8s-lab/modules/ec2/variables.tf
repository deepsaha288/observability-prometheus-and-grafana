variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.medium"
}

variable "subnet_id" {
  description = "Subnet ID where the EC2 instance will be launched"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for the EC2 instance"
  type        = string
}

variable "key_name" {
  description = "Existing AWS Key Pair"
  type        = string
}

variable "user_data" {
  description = "User data script for the EC2 instance"
  type        = string
  default     = ""
}

variable "instance_name" {
  description = "Name tag for EC2 instance"
  type        = string
  default     = "k8s-master"
}

variable "volume_size" {
  description = "Size of the additional EBS volume in GB"
  type        = number
  default     = 20
}

variable "volume_type" {
  description = "EBS volume type"
  type        = string
  default     = "gp3"
}

variable "device_name" {
  description = "Device name to attach the EBS volume as"
  type        = string
  default     = "/dev/sdh"
}
