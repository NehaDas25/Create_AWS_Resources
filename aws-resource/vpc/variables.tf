provider "aws"
{
    region = var.region
} 

variable "basename"
{
  type = string
  nullable = false
}

variable "vpc_name" {
  type    = string
  nullable = false
}

variable "vpc_cidr_block" {
  type    = string
  nullable = false
}

variable "region" {
    type    = string
    nullable = false
}

locals {
    azs = ["${var.region}a", "${var.region}b"]
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR"
  nullable = false
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private Subnet CIDR"
  nullable = false
}