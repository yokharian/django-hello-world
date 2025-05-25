module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 7.0"

  project_id   = var.project_id
  network_name = "django-vpc"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name           = "django-subnet"
      subnet_ip             = "10.0.0.0/24"
      subnet_region         = "us-central1"
      subnet_private_access = true
    }
  ]

  firewall_rules = [
    {
      name        = "allow-http"
      description = "Allow incoming HTTP traffic"
      direction   = "INGRESS"
      priority    = 1000
      ranges      = ["0.0.0.0/0"]
      allow = [
        {
          protocol = "tcp"
          ports    = ["80"]
        }
      ]
      target_tags = ["django-server"]
    }
  ]
}


variable "project_id" {
  type = string
  description = "google cloud project"
}


output "network_name" {
  value = module.vpc.network_name
}
output "subnets" {
  value = module.vpc.subnets
}
