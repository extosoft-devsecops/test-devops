# =============================================================================
# Kubernetes Configuration
# =============================================================================

variable "kubeconfig_path" {
  description = "Path to kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "kube_context" {
  description = "Kubernetes context to use"
  type        = string
  default     = "docker-desktop"
}

variable "namespace" {
  description = "Kubernetes namespace for deployment"
  type        = string
  default     = "test-devops"
}

variable "environment" {
  description = "Environment name (local, develop, uat, production)"
  type        = string
  default     = "local"

  validation {
    condition     = contains(["local", "develop", "uat", "production"], var.environment)
    error_message = "Environment must be one of: local, develop, uat, production"
  }
}

# =============================================================================
# Helm Configuration
# =============================================================================

variable "release_name" {
  description = "Helm release name"
  type        = string
  default     = "test-devops"
}

variable "helm_chart_path" {
  description = "Path to Helm chart"
  type        = string
  default     = "../helm/test-devops"
}

# =============================================================================
# Application Configuration
# =============================================================================

variable "image_repository" {
  description = "Docker image repository"
  type        = string
  default     = "test-devops"
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}

variable "service_name" {
  description = "Service name"
  type        = string
  default     = "test-devops"
}

variable "replica_count" {
  description = "Number of replicas"
  type        = number
  default     = 1
}

# =============================================================================
# Service Configuration
# =============================================================================

variable "service_type" {
  description = "Kubernetes service type (NodePort, LoadBalancer, ClusterIP)"
  type        = string
  default     = "NodePort"

  validation {
    condition     = contains(["NodePort", "LoadBalancer", "ClusterIP"], var.service_type)
    error_message = "Service type must be NodePort, LoadBalancer, or ClusterIP"
  }
}

variable "service_node_port" {
  description = "NodePort for the service (30000-32767)"
  type        = number
  default     = 30080

  validation {
    condition     = var.service_node_port >= 30000 && var.service_node_port <= 32767
    error_message = "NodePort must be between 30000 and 32767"
  }
}

# =============================================================================
# Autoscaling Configuration
# =============================================================================

variable "autoscaling_enabled" {
  description = "Enable Horizontal Pod Autoscaler"
  type        = bool
  default     = false
}

variable "autoscaling_min_replicas" {
  description = "Minimum number of replicas for autoscaling"
  type        = number
  default     = 1
}

variable "autoscaling_max_replicas" {
  description = "Maximum number of replicas for autoscaling"
  type        = number
  default     = 10
}

# =============================================================================
# Monitoring Configuration
# =============================================================================

variable "datadog_enabled" {
  description = "Enable Datadog monitoring"
  type        = bool
  default     = false
}

variable "datadog_api_key" {
  description = "Datadog API key"
  type        = string
  default     = ""
  sensitive   = true
}

variable "prometheus_enabled" {
  description = "Enable Prometheus ServiceMonitor"
  type        = bool
  default     = false
}

# =============================================================================
# GKE Configuration (Optional)
# =============================================================================

# variable "cluster_endpoint" {
#   description = "GKE cluster endpoint"
#   type        = string
#   default     = ""
# }

# variable "cluster_token" {
#   description = "GKE cluster authentication token"
#   type        = string
#   default     = ""
#   sensitive   = true
# }

# variable "cluster_ca_certificate" {
#   description = "GKE cluster CA certificate"
#   type        = string
#   default     = ""
#   sensitive   = true
# }
