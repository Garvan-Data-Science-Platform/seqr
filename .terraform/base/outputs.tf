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

output "cluster_ca" {
  value = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}

output "sa_email" {
  value = var.sa_email
}

output "subdomain" {
  value = var.subdomain
}

output "ssl_cert" {
  value = google_compute_managed_ssl_certificate.lb_default.name
}

//output "load_balancer_ip" {
//  value = kubernetes_ingress_v1.gke-ingress.status.0.load_balancer.0.ingress.0.ip
//}