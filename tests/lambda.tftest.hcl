provider "aws" {
  region = "eu-central-1"
  default_tags {
    tags = {
      Environment = "Test"
    }
  }
}

run "invalid_identifier" {
  command = plan

  variables {
    identifier = "ab"
  }

  expect_failures = [var.identifier]
}

run "valid_identifier" {
  command = plan

  variables {
    identifier = "abc"
  }
}

run "invalid_vpc_subnets" {
  command = plan

  variables {
    identifier = "abc"
    vpc_config = {
      subnets         = ["subnet-234sfwlfw", "fasldfew23854"]
      security_groups = []
    }
  }

  expect_failures = [var.vpc_config]
}

run "invalid_vpc_security_groups" {
  command = plan

  variables {
    identifier = "abc"
    vpc_config = {
      subnets         = []
      security_groups = ["fsad9t8ewyt", "sg-3429yfwlefhwe"]
    }
  }

  expect_failures = [var.vpc_config]
}

run "valid_vpc_config" {
  command = plan

  variables {
    identifier = "abc"
    vpc_config = {
      subnets         = ["subnet-938y92g2", "subnet-a98yewgwe"]
      security_groups = ["sg-woht9328g23", "sg-3429yfwlefhwe"]
    }
  }
}

run "invalid_retention_in_days" {
  command = plan

  variables {
    identifier = "abc"
    log_config = {
      retention_in_days = 6
    }
  }

  expect_failures = [var.log_config]
}

run "valid_log_config" {
  command = plan

  variables {
    identifier = "abc"
    log_config = {
      retention_in_days = 365
    }
  }
}
