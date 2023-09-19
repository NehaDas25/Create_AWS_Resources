provider "aws"{
  region = "${var.aws_region}"
} 

variable "basename"{
  type = string
  nullable = false
}

variable "vpc_cidr_block" {
  type    = string
  nullable = false
}

variable "aws_region" {
    type    = string
    nullable = false
}

variable "azs" {
  type        = list(string)
  description = "Availability zones"
  nullable = false
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