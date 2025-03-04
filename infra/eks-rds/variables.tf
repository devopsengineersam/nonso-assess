variable "vpc_id" {
  type = string
  default = "vpc-0f13e58b7d73e0f1c"
}

variable "domain_name" {
  description = "Base domain name for Route53"
  type        = string
  default     = "chebsam.people.aws.dev"
}