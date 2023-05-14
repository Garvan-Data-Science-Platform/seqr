output "region" {
  value       = var.region
  description = "GCloud Region"
}

output "location" {
    value = var.location
    description = "GCloud Location"
}

output "project_id" {
  value       = var.project_id
  description = "GCloud Project ID"
}

output "kubernetes_cluster_name" {
  value       = google_container_cluster.primary.name
  description = "GKE Cluster Name"
}

output "kubernetes_cluster_host" {
  value       = google_container_cluster.primary.endpoint
  description = "GKE Cluster Host"
}

output "load_balancer_ip" {
  value = kubernetes_ingress_v1.gke-ingress.status.0.load_balancer.0.ingress.0.ip
}