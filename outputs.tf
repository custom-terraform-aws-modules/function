output "arn" {
  description = "The ARN of the Lambda function."
  value       = try(aws_lambda_function.main.arn, null)
}

output "invoke_arn" {
  description = "The invoke ARN of the Lambda function."
  value       = try(aws_lambda_function.main.invoke_arn, null)
}

output "log_group_name" {
  description = "The name of the CloudWatch log group created for the Lambda function to log to."
  value       = try(aws_cloudwatch_log_group.main[0].name, null)
}
