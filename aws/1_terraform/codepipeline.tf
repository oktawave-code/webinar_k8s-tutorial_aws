resource "aws_codestarconnections_connection" "github" {
  name          = "github"
  provider_type = "GitHub"
}

resource "aws_codepipeline" "this" {
  name     = "github-pipeline"
  role_arn = aws_iam_role.pipeline.arn

  artifact_store {
    location = aws_s3_bucket.this.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github.arn
        FullRepositoryId = "${var.repository_owner}/${var.repository_name}"
        BranchName       = "${var.repository_branch}"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source"]
      output_artifacts = ["build"]

      configuration = {
        ProjectName = aws_codebuild_project.this.name
      }
    }
  }
}
