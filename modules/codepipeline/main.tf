#This solution, non-production-ready template describes AWS Codepipeline based CICD Pipeline for terraform code deployment.
#© 2023 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
#This AWS Content is provided subject to the terms of the AWS Customer Agreement available at
#http://aws.amazon.com/agreement or other written agreement between Customer and either
#Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

resource "aws_codepipeline" "terraform_pipeline" {

  name     = "${var.project_name}-pipeline"
  role_arn = var.codepipeline_role_arn
  tags     = var.tags

  artifact_store {
    location = var.s3_bucket_name
    type     = "S3"
    encryption_key {
      id   = var.kms_key_arn
      type = "KMS"
    }
  }

  dynamic "stage" {
    for_each = toset(var.workspace_keys)
    content {
      name = "Source"

      action {
        name             = "Download-${stage.value.workspace_name}"
        category         = "Source"
        owner            = "AWS"
        version          = "1"
        provider         = "S3"
        namespace        = "SourceVariables"
        output_artifacts = [stage.value.workspace_name]
        run_order        = 1

        configuration = {
          S3Bucket    = stage.value.s3_bucket_name
          S3ObjectKey = stage.value.s3_source_object_key
        }
      }
    }
  }

  dynamic "stage" {
    for_each = toset(var.workspace_keys)
    content {
      name = "TF-Init-${stage.value.workspace_name}"
      action {
        category        = "Build"
        name            = stage.value.workspace_name
        owner           = "AWS"
        provider        = "CodeBuild"
        input_artifacts = [stage.value.workspace_name]
        version         = "1"
        run_order       = 2

        configuration = {
          ProjectName = stage.value.workspace_name
        }
      }
    }
  }

}