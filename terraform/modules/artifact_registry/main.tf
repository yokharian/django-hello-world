module "artifact_registry" {
  source  = "GoogleCloudPlatform/artifact-registry/google"
  version = "~> 0.3"

  # Required variables
  project_id    = var.project_id
  location      = var.zone
  format        = "DOCKER"
  repository_id = var.repository_name
}


variable "project_id" {
  type = string
  description = "google cloud project"
}
variable "zone" {
  type        = string
  description = "Google Cloud zone where the artifact registry will be deployed"
  default     = "us-central1"
}
variable "repository_name" {
  description = "google cloud artifact registry repository name"
}
