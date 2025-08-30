locals {
  iap_members_normalized = [
    for m in var.iap_members :
    (startswith(m, "user:") || startswith(m, "group:") || startswith(m, "serviceAccount:"))
    ? m
    : "user:${m}"
  ]
}

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
  for_each = toset(local.iap_members_normalized)
  project  = var.project_id
  role     = "roles/iap.tunnelResourceAccessor"
  member   = each.value
}

resource "google_project_iam_member" "oslogin_admin" {
  for_each = var.oslogin_admin ? toset(local.iap_members_normalized) : toset([])
  project  = var.project_id
  role     = "roles/compute.osAdminLogin"
  member   = each.value
}

resource "google_project_iam_member" "oslogin_user" {
  for_each = var.oslogin_admin ? toset([]) : toset(local.iap_members_normalized)
  project  = var.project_id
  role     = "roles/compute.osLogin"
  member   = each.value
}
