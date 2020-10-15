variable "region" {}

# variable "aws_account_id" {}
# variable "aws_iam_policy_access_dynamodb" {}
# variable "aws_iam_policy_write_to_cloudwatch" {}
# variable "aws_iam_role_ecs_task_execution" {}
variable "aws_iam_policy_read_dynamodb_config_arn" {}

variable "aws_vpc_main" {}
variable "aws_subnet_publics" {}

#variable "tooling_orchestrator_host" {}
#variable "tooling_orchestrator_port" {}

provider "aws" {
  region  = var.region
  version = "~> 2.64"
}

data "aws_caller_identity" "current" {}
locals {
  aws_account_id = data.aws_caller_identity.current.account_id
}

