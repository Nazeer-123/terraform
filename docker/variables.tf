# --- Variables Definition ---
variable "vpc_id" {
  description = "The VPC ID where the EC2 instance will be deployed."
  type        = string
}

variable "subnet_id" {
  description = "The Subnet ID within the VPC."
  type        = string
}

variable "key_name" {
  description = "The name of your EC2 Key Pair for SSH access."
  type        = string
}