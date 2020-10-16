variable "region" {
  type        = string
  description = "Region"
  default     = "us-east-1"
}

variable "s3_bucket" {
  type        = string
  description = "S3 bucket with Lambdas sources"
}

variable "public_subdomain" {
  type        = string
  description = "Base domain"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "dev"
}

variable "telegram_token" {
  type        = string
  description = "String like '12345678:AAFPImsdfhgjhfgdfgdfhdfgdfgdfgViJQdfgf0'"
}

variable "pixabay_token" {
  type        = string
  description = "String like '12133434-gfkjfkdjkgj67fkkhfh'"
}
