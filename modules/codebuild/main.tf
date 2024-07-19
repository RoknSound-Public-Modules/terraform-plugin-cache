#This solution, non-production-ready template describes AWS Codepipeline based CICD Pipeline for terraform code deployment.
#© 2023 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
#This AWS Content is provided subject to the terms of the AWS Customer Agreement available at
#http://aws.amazon.com/agreement or other written agreement between Customer and either
#Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

locals {
  efs = {
    mount_options = "nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2"
    mount_point   = "/mnt/efs"
  }
}
resource "aws_codebuild_project" "terraform_codebuild_project" {
  for_each       = toset(var.workspace_keys)
  name           = each.value.workspace_name
  service_role   = var.role_arn
  encryption_key = var.kms_key_arn
  tags           = var.tags

  artifacts {
    type = "CODEPIPELINE"
  }

  file_system_locations {
    identifier    = var.efs_id
    location      = var.efs_location
    mount_options = local.efs.mount_options
    mount_point   = local.efs.mount_point
    type          = "EFS"
  }

  environment {
    compute_type                = var.builder_compute_type
    image                       = var.builder_image
    type                        = var.builder_type
    privileged_mode             = true
    image_pull_credentials_type = var.builder_image_pull_credentials_type
    dynamic "environment_variable" {
      for_each = toset(
        concat(var.environment_variables,
          [
            {
              name  = "TF_PLUGIN_CACHE_DIR"
              value = "/mnt/efs"
              type  = "PLAINTEXT"
            }
          ]
        )
      )
      content {
        name  = environment_variable.value.name
        value = environment_variable.value.value
        type  = environment_variable.value.type
      }
    }
  }
  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }
  source {
    type = "CODEPIPELINE"
    buildspec = templatefile(
      "${path.module}/templates/tf_init.yml",
      {
        terraform_version = var.terraform_version
      }
    )
  }
  lifecycle {
    ignore_changes = [
      project_visibility
    ]
  }
}