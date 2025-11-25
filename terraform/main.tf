# =============================================================================
# Terraform Configuration for Deploying Helm Chart to Kubernetes
# =============================================================================

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }

  # Optional: Configure backend for state management
  # backend "gcs" {
  #   bucket = "your-terraform-state-bucket"
  #   prefix = "terraform/test-devops"
  # }
}

# =============================================================================
# Providers Configuration
# =============================================================================

provider "kubernetes" {
  # For Docker Desktop Kubernetes
  config_path    = var.kubeconfig_path
  config_context = var.kube_context

  # For GKE (uncomment if using GKE)
  # host                   = var.cluster_endpoint
  # token                  = var.cluster_token
  # cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    config_path    = var.kubeconfig_path
    config_context = var.kube_context

    # For GKE (uncomment if using GKE)
    # host                   = var.cluster_endpoint
    # token                  = var.cluster_token
    # cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  }
}

# =============================================================================
# Kubernetes Namespace
# =============================================================================

resource "kubernetes_namespace" "test_devops" {
  metadata {
    name = var.namespace

    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "environment"                  = var.environment
    }
  }
}

# =============================================================================
# Datadog Secret (Optional)
# =============================================================================

resource "kubernetes_secret" "datadog_api_key" {
  count = var.datadog_enabled ? 1 : 0

  metadata {
    name      = "datadog-api-key"
    namespace = kubernetes_namespace.test_devops.metadata[0].name
  }

  data = {
    api-key = var.datadog_api_key
  }

  type = "Opaque"
}

# =============================================================================
# Helm Release - Test DevOps Application
# =============================================================================

resource "helm_release" "test_devops" {
  name       = var.release_name
  namespace  = kubernetes_namespace.test_devops.metadata[0].name
  chart      = var.helm_chart_path
  timeout    = 600
  wait       = true

  # Values from variables
  values = [
    templatefile("${path.module}/values/${var.environment}.yaml", {
      image_repository = var.image_repository
      image_tag        = var.image_tag
      replica_count    = var.replica_count
      node_env         = var.environment
      service_name     = var.service_name
    })
  ]

  # Dynamic values
  set {
    name  = "image.repository"
    value = var.image_repository
  }

  set {
    name  = "image.tag"
    value = var.image_tag
  }

  set {
    name  = "replicaCount"
    value = var.replica_count
  }

  set {
    name  = "env.nodeEnv"
    value = var.environment
  }

  set {
    name  = "env.serviceName"
    value = var.service_name
  }

  # Datadog configuration
  set {
    name  = "datadog.enabled"
    value = var.datadog_enabled
  }

  dynamic "set_sensitive" {
    for_each = var.datadog_enabled ? [1] : []
    content {
      name  = "datadog.apiKey"
      value = var.datadog_api_key
    }
  }

  # Autoscaling configuration
  set {
    name  = "autoscaling.enabled"
    value = var.autoscaling_enabled
  }

  set {
    name  = "autoscaling.minReplicas"
    value = var.autoscaling_min_replicas
  }

  set {
    name  = "autoscaling.maxReplicas"
    value = var.autoscaling_max_replicas
  }

  # Prometheus configuration
  set {
    name  = "prometheus.enabled"
    value = var.prometheus_enabled
  }

  # Service configuration
  set {
    name  = "service.type"
    value = var.service_type
  }

  set {
    name  = "service.nodePort"
    value = var.service_node_port
  }

  depends_on = [
    kubernetes_namespace.test_devops
  ]
}
