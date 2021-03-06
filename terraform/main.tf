variable "region" {
  default = "eu-west-2"
}

locals {
  ecr_tooling_repos = toset([
    "c-test-runner",
    "clojure-analyzer",
    "clojure-representer",
    "clojure-test-runner",
    "common-lisp-analyzer",
    "common-lisp-representer",
    "common-lisp-test-runner",
    "cpp-test-runner",
    "csharp-analyzer",
    "csharp-representer",
    "csharp-test-runner",
    "elixir-analyzer",
    "elixir-representer",
    "elixir-test-runner",
    "elm-test-runner",
    "erlang-analyzer",
    "erlang-test-runner",
    "fsharp-representer",
    "fsharp-test-runner",
    "generic-test-runner",
    "go-analyzer",
    "go-test-runner",
    "j-representer",
    "j-test-runner",
    "java-analyzer",
    "java-test-runner",
    "javascript-analyzer",
    "javascript-representer",
    "javascript-test-runner",
    "julia-test-runner",
    "kotlin-test-runner",
    "nim-test-runner",
    "python-analyzer",
    "python-representer",
    "python-test-runner",
    "ruby-analyzer",
    "ruby-representer",
    "ruby-test-runner",
    "rust-analyzer",
    "rust-representer",
    "rust-test-runner",
    "scala-analyzer",
    "scheme-test-runner",
    "stub-analyzer",
    "swift-test-runner",
    "typescript-analyzer",
    "x86-64-assembly-test-runner"
  ])
}

provider "aws" {
  region  = var.region
  version = "~> 2.64"
}

# Fetch AZs in the current region
data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}

module "webservers" {
  source = "./webservers"

  region = var.region

  aws_iam_policy_document_assume_role_ecs      = data.aws_iam_policy_document.assume_role_ecs
  aws_iam_policy_read_dynamodb_config          = aws_iam_policy.read_dynamodb_config
  aws_iam_policy_write_to_cloudwatch           = aws_iam_policy.write_to_cloudwatch
  aws_iam_policy_access_dynamodb_tooling_jobs  = aws_iam_policy.access_dynamodb_tooling_jobs
  aws_iam_policy_access_s3_bucket_submissions  = aws_iam_policy.access_s3_bucket_submissions
  aws_iam_policy_access_s3_bucket_tooling_jobs = aws_iam_policy.access_s3_bucket_tooling_jobs
  aws_iam_role_ecs_task_execution              = aws_iam_role.ecs_task_execution

  aws_vpc_main       = aws_vpc.main
  aws_subnet_publics = aws_subnet.publics

  container_cpu    = 256
  container_memory = 512
  container_count  = 1

  http_port       = 80
  websockets_port = 3334
}

module "tooling_orchestrator" {
  source = "./tooling_orchestrator"

  region = var.region

  aws_account_id                               = data.aws_caller_identity.current.account_id
  aws_iam_policy_document_assume_role_ecs      = data.aws_iam_policy_document.assume_role_ecs
  aws_iam_policy_read_dynamodb_config          = aws_iam_policy.read_dynamodb_config
  aws_iam_policy_write_to_cloudwatch           = aws_iam_policy.write_to_cloudwatch
  aws_iam_policy_access_dynamodb_tooling_jobs  = aws_iam_policy.access_dynamodb_tooling_jobs
  aws_iam_policy_access_s3_bucket_tooling_jobs = aws_iam_policy.access_s3_bucket_tooling_jobs
  aws_iam_role_ecs_task_execution              = aws_iam_role.ecs_task_execution

  aws_vpc_main       = aws_vpc.main
  aws_subnet_publics = aws_subnet.publics

  container_cpu    = 256
  container_memory = 512
  container_count  = 1

  http_port = 80
}

module "tooling_invoker" {
  source = "./tooling_invoker"

  region = var.region
  ecr_tooling_repos = local.ecr_tooling_repos

  # aws_account_id                                         = data.aws_caller_identity.current.account_id
  # aws_iam_policy_read_dynamodb_config                         = aws_iam_policy.read_dynamodb_config
  # aws_iam_policy_write_to_cloudwatch                     = aws_iam_policy.write_to_cloudwatch
  # aws_iam_role_ecs_task_execution                        = aws_iam_role.ecs_task_execution
  aws_iam_policy_read_dynamodb_config_arn                  = aws_iam_policy.read_dynamodb_config.arn
  aws_iam_policy_read_dynamodb_tooling_language_groups_arn = aws_iam_policy.read_dynamodb_tooling_language_groups.arn
  aws_iam_policy_read_s3_bucket_submissions                = aws_iam_policy.read_s3_bucket_submissions

  aws_vpc_main       = aws_vpc.main
  aws_subnet_publics = aws_subnet.publics

  # container_cpu    = 256
  # container_memory = 512
  # container_count  = 1

  # http_port = 80
}


module "github_deploy" {
  source = "./github_deploy"

  region = var.region

  aws_ecr_repo_arns = [
    module.git_server.ecr_repository_arn_application,
    module.git_server.ecr_repository_arn_nginx,

    module.tooling_orchestrator.ecr_repository_arn_application,
    module.tooling_orchestrator.ecr_repository_arn_nginx,

    module.webservers.ecr_repository_arn_rails,
    module.webservers.ecr_repository_arn_nginx,
    module.webservers.ecr_repository_arn_anycable_go
  ]
  aws_s3_bucket_name_webservers_assets = module.webservers.s3_bucket_name_assets
}

module "tooling" {
  source = "./tooling"

  region = var.region
  ecr_tooling_repos = local.ecr_tooling_repos
}

module "git_server" {
  source = "./git_server"

  region = var.region

  aws_account_id                          = data.aws_caller_identity.current.account_id
  aws_iam_policy_document_assume_role_ecs = data.aws_iam_policy_document.assume_role_ecs
  aws_iam_policy_read_dynamodb_config     = aws_iam_policy.read_dynamodb_config
  aws_iam_policy_write_to_cloudwatch      = aws_iam_policy.write_to_cloudwatch
  aws_iam_role_ecs_task_execution         = aws_iam_role.ecs_task_execution

  aws_vpc_main       = aws_vpc.main
  aws_subnet_publics = aws_subnet.publics

  container_cpu    = 256
  container_memory = 512
  container_count  = 1

  http_port = 80
}
