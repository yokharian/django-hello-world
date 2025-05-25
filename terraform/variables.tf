variable "project_id" {
  description = "google cloud project"
  type = string
}

variable "zone" {
  description = "Google Cloud zone where the compute instance will be deployed"
  type        = string
  default     = "us-central1"
}


variable "image_tag" {
  description = "Docker image tag to be deployed on the compute instance"
  type        = string
  default     = "django_app_image"
}

variable "repository_name" {
  description = "google cloud artifact registry repository name"
  default     = "django_app_repo"
}
