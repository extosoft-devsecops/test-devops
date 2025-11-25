# =============================================================================
# Outputs
# =============================================================================

output "namespace" {
  description = "Kubernetes namespace"
  value       = kubernetes_namespace.test_devops.metadata[0].name
}

output "release_name" {
  description = "Helm release name"
  value       = helm_release.test_devops.name
}

output "release_status" {
  description = "Helm release status"
  value       = helm_release.test_devops.status
}

output "release_version" {
  description = "Helm release version"
  value       = helm_release.test_devops.version
}

output "app_version" {
  description = "Application version"
  value       = helm_release.test_devops.metadata[0].app_version
}

output "chart_version" {
  description = "Helm chart version"
  value       = helm_release.test_devops.metadata[0].version
}

output "service_endpoint" {
  description = "Service endpoint URL"
  value       = var.service_type == "NodePort" ? "http://localhost:${var.service_node_port}" : "Check kubectl get svc -n ${kubernetes_namespace.test_devops.metadata[0].name}"
}

output "deployment_info" {
  description = "Deployment information"
  value = {
    namespace          = kubernetes_namespace.test_devops.metadata[0].name
    release_name       = helm_release.test_devops.name
    image              = "${var.image_repository}:${var.image_tag}"
    replicas           = var.replica_count
    autoscaling        = var.autoscaling_enabled
    datadog_enabled    = var.datadog_enabled
    prometheus_enabled = var.prometheus_enabled
    environment        = var.environment
  }
}
