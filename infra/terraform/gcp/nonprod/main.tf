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
# Network (VPC + Subnet) - NONPROD
########################################

resource "google_compute_network" "main" {
  name                    = "gke-nonprod-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "main" {
  name          = "gke-nonprod-subnet"
  ip_cidr_range = "10.60.0.0/16"
  region        = var.region
  network       = google_compute_network.main.id
}

########################################
# GKE Cluster (Non-Prod)
########################################

locals {
  gke_zone = "${var.region}-a"
}

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
    # 4 vCPU / 16GB
    machine_type = "e2-standard-4"
    disk_type    = "pd-standard"
    disk_size_gb = 50

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
# Kubernetes Provider (Non-Prod)
########################################

provider "kubernetes" {
  alias                  = "nonprod"
  host                   = "https://${google_container_cluster.nonprod.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.nonprod.master_auth[0].cluster_ca_certificate)
}

########################################
# Helm Provider (Non-Prod)
########################################

provider "helm" {
  alias = "nonprod"
  kubernetes = {
    host                   = "https://${google_container_cluster.nonprod.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.nonprod.master_auth[0].cluster_ca_certificate)
  }
}

########################################
# Namespaces (Non-Prod)
########################################

resource "kubernetes_namespace" "nonprod_app" {
  provider = kubernetes.nonprod
  metadata {
    name = "nonprod-app"
  }
}

########################################
# Helm Release (Non-Prod)
########################################

resource "helm_release" "nonprod_app" {
  provider = helm.nonprod

  name             = "test-devops-nonprod"
  namespace        = kubernetes_namespace.nonprod_app.metadata[0].name
  create_namespace = false

  # NOTE: ถ้าย้ายตำแหน่งโฟลเดอร์ terraform แล้ว path นี้อาจต้องปรับตามโครงสร้าง repo จริง
  chart   = "${path.root}/../../../../helm/test-devops"
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
        port         = 3000
        env = {
          NODE_ENV    = "non-production"
          STATSD_HOST = "graphite"
          STATSD_PORT = "8125"
        }
      }

      graphite = {
        enabled     = true
        image       = "graphiteapp/graphite-statsd"
        tag         = "latest"
        webPort     = 80
        serviceType = "LoadBalancer"
      }

      env = "non-production"

      ingress = {
        enabled   = true
        className = "gce"
        hosts = [{
          host  = var.ingress_host
          paths = [{ path = "/", pathType = "Prefix" }]
        }]
      }
    })
  ]

  depends_on = [google_container_node_pool.nonprod_nodes]
}
