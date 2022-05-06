variable "region" {
  description = "AWS region"
  default     = "us-east-2"
}

variable "repository_branch" {
  description = "Main repository branch"
  default     = "develop"
}

variable "repository_owner" {
  description = "GitHub repository owner"
  default     = "your_login"
}

variable "repository_name" {
  description = "GitHub repository name"
  default     = "2_todo"
}
