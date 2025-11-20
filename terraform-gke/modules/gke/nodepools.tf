resource "google_container_node_pool" "system" {
  cluster    = google_container_cluster.primary.name
  location   = var.region
  name       = "system-pool"
  node_count = 1

  node_config {
    machine_type    = "e2-small"
    service_account = google_service_account.gke_nodes.email
    disk_type       = "pd-standard"
    disk_size_gb    = 20
    labels = { pool = "system" }
    tags   = ["system"]
  }
}

# Temporarily commented out for quota issues
# resource "google_container_node_pool" "general" {
#   cluster  = google_container_cluster.primary.name
#   location = var.region
#   name     = "general-pool"

#   autoscaling {
#     min_node_count = 1
#     max_node_count = 1
#   }

#   node_config {
#     machine_type    = "e2-medium"
#     service_account = var.node_sa != "" ? var.node_sa : google_service_account.gke_nodes.email
#     disk_type       = "pd-standard"
#     disk_size_gb    = 20
#     labels = { pool = "general" }
#   }
# }

# Commented out highcpu pool to reduce quota usage
# resource "google_container_node_pool" "highcpu" {
#   cluster  = google_container_cluster.primary.name
#   location = var.region
#   name     = "highcpu-pool"

#   autoscaling {
#     min_node_count = 0
#     max_node_count = 1
#   }

#   node_config {
#     machine_type    = "e2-standard-2"
#     service_account = var.node_sa != "" ? var.node_sa : google_service_account.gke_nodes.email
#     disk_type       = "pd-standard"
#     disk_size_gb    = 30
#     labels = { pool = "highcpu" }
#   }
# }
