################################
# IAM Role                     #
################################

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "main" {
  name               = "${var.identifier}-ServiceRoleForLambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = merge(
    { "Name" = var.name },
    var.tags
  )
}

resource "aws_iam_role_policy_attachment" "import" {
  count      = length(var.policies)
  role       = aws_iam_role.main.name
  policy_arn = var.policies[count.index]
}

# for lambda which is deployed in a VPC
data "aws_iam_policy_document" "vpc" {
  count = var.vpc_config != null ? 1 : 0
  statement {
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:AssignPrivateIpAddresses",
      "ec2:UnassignPrivateIpAddresses"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "vpc" {
  count  = var.vpc_config != null ? 1 : 0
  name   = "${var.identifier}-AssignSelfToVPC"
  policy = data.aws_iam_policy_document.vpc[0].json

  tags = merge(
    { "Name" = var.name },
    var.tags
  )
}

resource "aws_iam_role_policy_attachment" "vpc" {
  count      = var.vpc_config != null ? 1 : 0
  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.vpc[0].arn
}

# for lambda that issues logs
data "aws_iam_policy_document" "log" {
  count = var.log ? 1 : 0
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "log" {
  count  = var.log ? 1 : 0
  name   = "${var.identifier}-CloudWatchCreateLog"
  policy = data.aws_iam_policy_document.log[0].json

  tags = merge(
    { "Name" = var.name },
    var.tags
  )
}

resource "aws_iam_role_policy_attachment" "log" {
  count      = var.log ? 1 : 0
  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.log[0].arn
}

################################
# ECR Repository               #
################################

resource "aws_ecr_repository" "main" {
  count                = length(var.image_uri) > 0 ? 1 : 0
  name                 = "${var.identifier}-lambda"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  tags = merge(
    { "Name" = var.name },
    var.tags
  )
}

################################
# Lambda Function              #
################################

resource "aws_lambda_function" "main" {
  function_name = var.identifier
  package_type  = "Image"
  role          = aws_iam_role.main.arn
  image_uri     = length(var.image_uri) > 0 ? "${aws_ecr_repository.main[0].repository_url}:latest" : var.image_uri
  memory_size   = var.memory_size
  timeout       = var.timeout

  environment {
    variables = var.env_variables
  }

  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [1] : []
    content {
      subnet_ids         = try(var.vpc_config["subnets"], null)
      security_group_ids = try(var.vpc_config["security_groups"], null)
    }
  }

  tags = merge(
    { "Name" = var.name },
    var.tags
  )
}
