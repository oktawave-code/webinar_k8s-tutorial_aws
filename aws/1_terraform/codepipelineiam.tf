data "aws_iam_policy_document" "assume_by_pipeline" {
  statement {
    sid     = "AllowAssumeByPipeline"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "pipeline" {
  name               = "pipeline-example-role"
  assume_role_policy = data.aws_iam_policy_document.assume_by_pipeline.json
}

data "aws_iam_policy_document" "pipeline" {
  statement {
    sid    = "AllowS3"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetObjectVersion",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation",
      "s3:GetBucketVersioning"
    ]

    resources = [
      "${aws_s3_bucket.this.arn}",
      "${aws_s3_bucket.this.arn}/*"
    ]
  }

  statement {
    sid    = "AllowCodeBuild"
    effect = "Allow"

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild"
    ]

    resources = ["${aws_codebuild_project.this.arn}"]
  }

  statement {
    actions = [
      "codestar-connections:UseConnection",
      "codestar-connections:PassConnection"
    ]
    resources = ["${aws_codestarconnections_connection.github.arn}"]
  }
}

resource "aws_iam_role_policy" "pipeline" {
  role   = aws_iam_role.pipeline.name
  policy = data.aws_iam_policy_document.pipeline.json
}
