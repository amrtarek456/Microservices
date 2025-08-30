output "cluster_name" {
  value = google_container_cluster.cluster.name
}

output "internal_get_credentials_cmd" {
  value = "gcloud container clusters get-credentials ${google_container_cluster.cluster.name} --region ${var.region} --project ${var.project_id} --internal-ip"
}

output "bastion_name" {
  value = google_compute_instance.bastion.name
}

output "iap_ssh_cmd" {
  value = "gcloud compute ssh ${google_compute_instance.bastion.name} --tunnel-through-iap --zone ${var.zone} --project ${var.project_id}"
}

output "node_service_account" {
  value = google_service_account.gke_nodes.email
}
