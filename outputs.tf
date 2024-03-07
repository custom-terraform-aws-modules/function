output "arn" {
  description = "ARN of the Lambda function."
  value       = aws_lambda_function.main.arn
}

output "invoke_arn" {
  description = "Invoke ARN of the Lambda function."
  value       = aws_lambda_function.main.invoke_arn
}
