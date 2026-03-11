variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "trusted_ip" {
  description = "Trusted IP address for SSH access (CIDR format)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "terraform-security-lab"
}
