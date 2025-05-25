output "django_instance_ip" {
  value = google_compute_instance.django_vm.network_interface[0].access_config[0].nat_ip
  description = "The public IP address of the EC2 instance"
}
