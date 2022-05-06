resource "aws_codebuild_project" "this" {
  name         = "buildtodo"
  description  = "codebuild_for_the_todo_app"
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/docker:18.09.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "REPOSITORY_URI"
      value = aws_ecr_repository.this.repository_url
    }
  }
  source {
    type = "CODEPIPELINE"
  }
}
