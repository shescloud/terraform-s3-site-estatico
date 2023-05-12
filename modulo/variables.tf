variable "name" {
  description = "Name of the application"
}

variable "route53_zone_id" {
  description = "Route 53 zone id"
}

variable "environment" {
  description = "Environment [dev, pre, prod]"
}

variable "ssl_arn" {
  description = "Arn of the ssl certificate"
}

variable "log_bucket" {
  default     = ""
}

variable "oai_name" {
  default     = ""
}

variable "project" {
  default     = ""
}
