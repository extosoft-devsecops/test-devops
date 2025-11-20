output "cluster_name" {
  description = "Nonprod GKE cluster name"
  value       = google_container_cluster.nonprod.name
}

output "cluster_endpoint" {
  description = "Nonprod GKE cluster endpoint"
  value       = google_container_cluster.nonprod.endpoint
}

output "nonprod_namespace" {
  description = "Nonprod application namespace"
  value       = kubernetes_namespace.nonprod_app.metadata[0].name
}
