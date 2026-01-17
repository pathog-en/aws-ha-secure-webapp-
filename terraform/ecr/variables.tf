variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "repo_name" {
  type    = string
  default = "aws-ha-webapp"
}

variable "image_tag_mutability" {
  type    = string
  default = "MUTABLE" # IMMUTABLE is stricter
}
