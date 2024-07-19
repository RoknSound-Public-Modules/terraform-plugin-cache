#This solution, non-production-ready template describes AWS Codepipeline based CICD Pipeline for terraform code deployment.
#© 2023 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
#This AWS Content is provided subject to the terms of the AWS Customer Agreement available at
#http://aws.amazon.com/agreement or other written agreement between Customer and either
#Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

variable "project_name" {
  description = "Unique name for this project"
  type        = string
}

variable "role_arn" {
  description = "Codepipeline IAM role arn. "
  type        = string
  default     = ""
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket used to store the deployment artifacts"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to the codebuild project"
  type        = map(any)
}

variable "builder_compute_type" {
  description = "Information about the compute resources the build project will use"
  type        = string
}

variable "builder_image" {
  description = "Docker image to use for the build project"
  type        = string
}

variable "builder_type" {
  description = "Type of build environment to use for related builds"
  type        = string
}

variable "builder_image_pull_credentials_type" {
  description = "Type of credentials AWS CodeBuild uses to pull images in your build."
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of KMS key for encryption"
  type        = string
}


variable "environment_variables" {
  type = list(object({
    name  = string
    value = string
    type  = string
  }))
  default = []
}

variable "terraform_version" {
  type        = string
  description = "Terraform CLI Version"
  default     = "1.7.5"
}

variable "efs_id" {
  description = "The ID of the EFS filesystem"
  type        = string
}

variable "efs_location" {
  description = "The location of the EFS filesystem"
  type        = string
}

variable "workspace_keys" {
  type = list(object({
    s3_bucket_name       = string
    s3_source_object_key = string
    workspace_name       = string
  }))
  default = []
}