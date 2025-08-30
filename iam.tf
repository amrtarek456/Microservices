resource "google_service_account" "gke_nodes" {
  account_id   = "gke-nodes"
  display_name = "GKE nodes service account"
}

resource "google_project_iam_member" "node_sa_roles" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer",
    "roles/artifactregistry.reader",
    "roles/storage.objectViewer"
  ])
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_project_iam_member" "iap_tunnel" {
  for_each = toset(var.iap_members)
  project  = var.project_id
  role     = "roles/iap.tunnelResourceAccessor"
  member   = each.value
}

resource "google_project_iam_member" "oslogin_admin" {
  count   = var.oslogin_admin ? length(var.iap_members) : 0
  project = var.project_id
  role    = "roles/compute.osAdminLogin"
  member  = element(var.iap_members, count.index)
}

resource "google_project_iam_member" "oslogin_user" {
  count   = var.oslogin_admin ? 0 : length(var.iap_members)
  project = var.project_id
  role    = "roles/compute.osLogin"
  member  = element(var.iap_members, count.index)
}
