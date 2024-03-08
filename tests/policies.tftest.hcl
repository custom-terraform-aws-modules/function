provider "aws" {
  region = "eu-central-1"
  default_tags {
    tags = {
      Environment = "Test"
    }
  }
}

run "valid_policies" {
  command = plan

  variables {
    identifier = "abc"
    policies = [
      "arn:aws:iam::aws:policy/aws-service-role/AccessAnalyzerServiceRolePolicy",
      "arn:aws:iam::aws:policy/AdministratorAccess-Amplify"
    ]
  }

  assert {
    condition     = length(var.policies) == length(aws_iam_role_policy_attachment.import)
    error_message = "IAM policy attachment was not created for every policy"
  }
}

run "without_log" {
  command = plan

  variables {
    identifier = "abc"
    log_config = null
  }

  assert {
    condition     = length(aws_iam_role_policy_attachment.log) == 0
    error_message = "IAM policy attachment for logging policy was created unexpectedly"
  }

  assert {
    condition     = length(aws_iam_policy.log) == 0
    error_message = "IAM policy for logging was created unexpectedly"
  }
}

run "with_log" {
  command = plan

  variables {
    identifier = "abc"
    log_config = {
      retention_in_days = 7
    }
  }

  assert {
    condition     = length(aws_iam_role_policy_attachment.log) == 1
    error_message = "IAM policy attachment for logging policy was not created"
  }

  assert {
    condition     = length(aws_iam_policy.log) == 1
    error_message = "IAM policy for logging was not created"
  }
}

run "without_vpc" {
  command = plan

  variables {
    identifier = "abc"
    vpc_config = null
  }

  assert {
    condition     = length(aws_iam_role_policy_attachment.vpc) == 0
    error_message = "IAM policy attachment for VPC policy was created unexpectedly"
  }

  assert {
    condition     = length(aws_iam_policy.vpc) == 0
    error_message = "IAM policy for VPC was created unexpectedly"
  }
}

run "with_vpc" {
  command = plan

  variables {
    identifier = "abc"
    vpc_config = {
      subnets         = []
      security_groups = []
    }
  }

  assert {
    condition     = length(aws_iam_role_policy_attachment.vpc) == 1
    error_message = "IAM policy attachment for VPC policy was not created"
  }

  assert {
    condition     = length(aws_iam_policy.vpc) == 1
    error_message = "IAM policy for VPC was not created"
  }
}
