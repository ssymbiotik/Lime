provider "azurerm" {
  features {}

  subscription_id = "09e30454-348c-481a-b364-08c75c6ecb26"
}

# Variables
variable "location" {
  description = "The Azure region to deploy resources"
  default     = "West Europe"
}

variable "cluster_name" {
  description = "The name of the AKS cluster"
  default     = "lime-ilian"
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  default     = "myaks"
}

variable "node_count" {
  description = "Number of nodes in the AKS cluster"
  default     = 1
}

variable "vm_size" {
  description = "Size of the VMs in the node pool"
  default     = "Standard_B2s"
}

variable "image_name" {
  description = "Name of the Docker image to deploy"
  default     = "ssymbiotik7/hat:latest"
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "lime"
  location = var.location
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.dns_prefix

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.vm_size
  }

  identity {
    type = "SystemAssigned"
  }
}

# Kubernetes Provider
provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
}

# Kubernetes Deployment
resource "kubernetes_deployment" "app" {
  metadata {
    name = "my-app"
    labels = {
      app = "my-app"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "my-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "my-app"
        }
      }

      spec {
        container {
          name  = "my-app"
          image = var.image_name

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

# Kubernetes Service
resource "kubernetes_service" "app" {
  metadata {
    name = "my-app-service"
  }

  spec {
    selector = {
      app = kubernetes_deployment.app.spec.0.template.0.metadata.0.labels.app
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}

# Outputs
output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}

output "service_ip" {
  value = kubernetes_service.app.status.0.load_balancer.0.ingress.0.ip
}
