provider "aws" {
  region = "eu-central-1"
  default_tags {
    tags = {
      Environment = "Test"
    }
  }
}

run "without_repository" {
  command = plan

  variables {
    identifier = "abc"
    image_uri  = ""
  }

  assert {
    condition     = length(aws_ecr_repository.main) == 0
    error_message = "ECR repository was created unexpectedly"
  }
}

run "with_repository" {
  command = plan

  variables {
    identifier = "abc"
    image_uri  = "test.registry:latest"
  }

  assert {
    condition     = length(aws_ecr_repository.main) == 1
    error_message = "ECR repository was not created"
  }
}
