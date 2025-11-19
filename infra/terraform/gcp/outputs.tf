output "prod_cluster_name" {
  description = "Production GKE cluster name"
  value       = google_container_cluster.prod.name
}

output "nonprod_cluster_name" {
  description = "Non-production GKE cluster name"
  value       = google_container_cluster.nonprod.name
}

# Application URLs and Access Information
output "application_urls" {
  description = "URLs to access applications"
  value = {
    prod = {
      app_url = "To get Production App IP: kubectl get svc test-devops-app -n prod-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}'"
      graphite_url = "To get Production Graphite IP: kubectl get svc graphite -n prod-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}'"
    }
    nonprod = {
      app_url = "To get NonProd App IP: kubectl get svc test-devops-app -n nonprod-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}'"
      graphite_url = "To get NonProd Graphite IP: kubectl get svc graphite -n nonprod-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}'"
    }
  }
}

# Quick access commands
output "access_commands" {
  description = "Commands to access applications"
  value = {
    prod_app = "kubectl get svc test-devops-app -n prod-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}'"
    prod_graphite = "kubectl get svc graphite -n prod-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}'"
    nonprod_app = "kubectl get svc test-devops-app -n nonprod-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}'"
    nonprod_graphite = "kubectl get svc graphite -n nonprod-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}'"
  }
}
