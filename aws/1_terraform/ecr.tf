resource "aws_ecr_repository" "this" {
  name                 = "2todo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name = "todo-app"
}
