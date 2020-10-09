resource "aws_ecr_repository" "webserver_nginx" {
  name                 = "webserver-nginx"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration { scan_on_push = false }
}

resource "aws_ecr_repository" "webserver_puma" {
  name                 = "webserver-puma"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration { scan_on_push = false }
}

resource "aws_ecr_repository" "webserver_anycable_go" {
  name                 = "webserver-anycable-go"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration { scan_on_push = false }
}

resource "aws_ecr_repository" "webserver_anycable_ruby" {
  name                 = "webserver-anycable-ruby"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration { scan_on_push = false }
}
