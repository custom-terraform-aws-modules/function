variable "identifier" {
  description = "Unique identifier to differentiate global resources."
  type        = string
  validation {
    condition     = length(var.identifier) > 2
    error_message = "Identifier must be at least 3 characters"
  }
}

variable "policies" {
  description = "List of IAM policy ARNs for the Lambda's IAM role."
  type        = list(string)
  default     = []
}

variable "vpc_config" {
  description = "Object to define the subnets and security groups for the Lambda function."
  type = object({
    subnets         = list(string)
    security_groups = list(string)
  })
  default = null
  validation {
    condition     = !contains([for v in try(var.vpc_config["subnets"], []) : startswith(v, "subnet-")], false)
    error_message = "Elements in subnet list must be valid subnet IDs"
  }
  validation {
    condition     = !contains([for v in try(var.vpc_config["security_groups"], []) : startswith(v, "sg-")], false)
    error_message = "Elements in security group list must be valid security group IDs"
  }
}

variable "log_config" {
  description = "Object to define logging configuration of the Lambda function to CloudWatch."
  type = object({
    retention_in_days = number
  })
  default = null
  validation {
    condition = try(var.log_config["retention_in_days"], 1) == 1 || (
      try(var.log_config["retention_in_days"], 3) == 3) || (
      try(var.log_config["retention_in_days"], 5) == 5) || (
      try(var.log_config["retention_in_days"], 7) == 7) || (
      try(var.log_config["retention_in_days"], 14) == 14) || (
      try(var.log_config["retention_in_days"], 30) == 30) || (
      try(var.log_config["retention_in_days"], 365) == 365) || (
    try(var.log_config["retention_in_days"], 0) == 0)
    error_message = "Retention in days must be one of these values: 0, 1, 3, 5, 7, 14, 30, 365"
  }
}

variable "image" {
  description = "Object of the image which will be pulled by the Lambda function to execute."
  type = object({
    uri = string
  })
  default = null
}

variable "memory_size" {
  description = "Amount of memory in MB the Lambda function can use at runtime."
  type        = number
  default     = 128
}

variable "timeout" {
  description = "Amount of time the Lambda function has to run in seconds."
  type        = number
  default     = 3
  validation {
    condition     = var.timeout <= 900
    error_message = "Must be equal or smaller than limit of 900 seconds"
  }
}

variable "env_variables" {
  description = "A map of environment variables for the Lambda function at runtime."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}
