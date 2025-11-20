output "cluster_name" {
  description = "Prod GKE cluster name"
  value       = google_container_cluster.prod.name
}

output "cluster_endpoint" {
  description = "Prod GKE cluster endpoint"
  value       = google_container_cluster.prod.endpoint
}

output "prod_namespace" {
  description = "Prod application namespace"
  value       = kubernetes_namespace.prod_app.metadata[0].name
}
