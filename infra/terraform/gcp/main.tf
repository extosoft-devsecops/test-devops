terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.30"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 3.0.0"
    }
  }
}

########################################
# Providers
########################################

provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_client_config" "default" {}


########################################
# Network (VPC + Subnet)
########################################

resource "google_compute_network" "main" {
  name                    = "gke-main-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "main" {
  name          = "gke-main-subnet"
  ip_cidr_range = "10.10.0.0/16"
  region        = var.region
  network       = google_compute_network.main.id
}


########################################
# GKE Clusters (Zonal)
########################################

locals {
  gke_zone = "${var.region}-a"
}

# Production Cluster
resource "google_container_cluster" "prod" {
  name     = "prod-gke"
  location = local.gke_zone

  network    = google_compute_network.main.self_link
  subnetwork = google_compute_subnetwork.main.self_link

  remove_default_node_pool = true
  initial_node_count       = 1

  release_channel {
    channel = "REGULAR"
  }

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "10.20.0.0/14"
    services_ipv4_cidr_block = "10.30.0.0/20"
  }
}

resource "google_container_node_pool" "prod_nodes" {
  name     = "prod-node-pool"
  cluster  = google_container_cluster.prod.name
  location = local.gke_zone

  node_count = 2

  node_config {
    machine_type = "e2-medium"
    disk_type    = "pd-standard"
    disk_size_gb = 20

    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]

    labels = {
      env = "production"
    }
  }

  autoscaling {
    min_node_count = 1
    max_node_count = 5
  }
}

# Non-Prod Cluster
resource "google_container_cluster" "nonprod" {
  name     = "nonprod-gke"
  location = local.gke_zone

  network    = google_compute_network.main.self_link
  subnetwork = google_compute_subnetwork.main.self_link

  remove_default_node_pool = true
  initial_node_count       = 1

  release_channel {
    channel = "REGULAR"
  }

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "10.40.0.0/14"
    services_ipv4_cidr_block = "10.50.0.0/20"
  }
}

resource "google_container_node_pool" "nonprod_nodes" {
  name     = "nonprod-node-pool"
  cluster  = google_container_cluster.nonprod.name
  location = local.gke_zone

  node_count = 1

  node_config {
    machine_type = "e2-small"
    disk_type    = "pd-standard"
    disk_size_gb = 20

    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]

    labels = {
      env = "non-production"
    }
  }

  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }
}


########################################
# Kubernetes Providers (Per Cluster)
########################################

provider "kubernetes" {
  alias                  = "prod"
  host                   = "https://${google_container_cluster.prod.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.prod.master_auth[0].cluster_ca_certificate)
}

provider "kubernetes" {
  alias                  = "nonprod"
  host                   = "https://${google_container_cluster.nonprod.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.nonprod.master_auth[0].cluster_ca_certificate)
}


########################################
# Helm Providers
########################################

provider "helm" {
  alias = "prod"
  kubernetes = {
    host                   = "https://${google_container_cluster.prod.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.prod.master_auth[0].cluster_ca_certificate)
  }
}

provider "helm" {
  alias = "nonprod"
  kubernetes = {
    host                   = "https://${google_container_cluster.nonprod.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.nonprod.master_auth[0].cluster_ca_certificate)
  }
}


########################################
# Namespaces
########################################

resource "kubernetes_namespace" "prod_app" {
  provider = kubernetes.prod
  metadata { name = "prod-app" }
}

resource "kubernetes_namespace" "nonprod_app" {
  provider = kubernetes.nonprod
  metadata { name = "nonprod-app" }
}


########################################
# Helm Release (Prod)
########################################

resource "helm_release" "prod_app" {
  provider = helm.prod

  name             = "test-devops-prod"
  namespace        = kubernetes_namespace.prod_app.metadata[0].name
  create_namespace = false

  chart   = "${path.root}/../../../helm/test-devops"
  wait    = false
  timeout = 600
  atomic  = false

  values = [
    yamlencode({
      image = {
        repository = "asia-southeast1-docker.pkg.dev/${var.project_id}/test-devops-images/test-devops"
        tag        = "v1.1"
        pullPolicy = "Always"
      }

      app = {
        replicaCount = 1
        port = 3000
        env = {
          NODE_ENV = "production"
          STATSD_HOST = "graphite"
          STATSD_PORT = "8125"
        }
      }

      graphite = {
        enabled = true
        image = "graphiteapp/graphite-statsd"
        tag = "latest"
        webPort = 80
        serviceType = "LoadBalancer"
      }

      env = "production"

      ingress = {
        enabled   = true
        className = "gce"
        hosts = [{
          host = var.prod_ingress_host
          paths = [{ path = "/", pathType = "Prefix" }]
        }]
      }
    })
  ]

  depends_on = [google_container_node_pool.prod_nodes]
}


########################################
# Helm Release (Non-Prod)
########################################

resource "helm_release" "nonprod_app" {
  provider = helm.nonprod

  name             = "test-devops-nonprod"
  namespace        = kubernetes_namespace.nonprod_app.metadata[0].name
  create_namespace = false

  chart   = "${path.root}/../../../helm/test-devops"
  wait    = false
  timeout = 600
  atomic  = false

  values = [
    yamlencode({
      image = {
        repository = "asia-southeast1-docker.pkg.dev/${var.project_id}/test-devops-images/test-devops"
        tag        = "v1.1"
        pullPolicy = "Always"
      }

      app = {
        replicaCount = 1
        port = 3000
        env = {
          NODE_ENV = "non-production"
          STATSD_HOST = "graphite"
          STATSD_PORT = "8125"
        }
      }

      graphite = {
        enabled = true
        image = "graphiteapp/graphite-statsd"
        tag = "latest"
        webPort = 80
        serviceType = "LoadBalancer"
      }

      env = "non-production"

      ingress = {
        enabled   = true
        className = "gce"
        hosts = [{
          host = var.nonprod_ingress_host
          paths = [{ path = "/", pathType = "Prefix" }]
        }]
      }
    })
  ]

  depends_on = [google_container_node_pool.nonprod_nodes]
}


# ########################################
# # Ingress Resources - Removed in favor of LoadBalancer services
# # This allows direct access to applications without ingress complexity
# ########################################

# Note: Ingress resources have been removed and replaced with LoadBalancer services
# for simpler access patterns. Applications are accessible via their external IPs.
