provider "google" {

}
module "vpc_module" {
  source = "./modules/vpc/"
  project_id = var.project_id
}

module "artifact_registry_module" {
  source = "./modules/artifact_registry"
  project_id = var.project_id
  repository_name = var.repository_name
}

resource "google_compute_instance" "django_vm" {
  name         = "django-server"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "projects/cos-cloud/global/images/family/cos-stable"
    }
  }

  metadata_startup_script = <<-EOT
    docker-credential-gcr configure-docker
    docker pull ${var.image_tag}
    docker run -d -p 80:8000 ${var.image_tag}
  EOT

  network_interface {
    network    = module.vpc_module.network_name
    subnetwork = module.vpc_module.subnets["us-central1/django-subnet"].self_link
    access_config {}
  }
}
