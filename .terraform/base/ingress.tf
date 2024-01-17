resource "google_compute_global_address" "static" {
  name = "ipv4-address"
}

resource "kubernetes_ingress_v1" "gke-ingress" {
  wait_for_load_balancer = true
  metadata {
    name = "gke-ingress"
    annotations = {
        "kubernetes.io/ingress.global-static-ip-name"=google_compute_global_address.static.name
        "kubernetes.io/ingress.class"="gce"
        "networking.gke.io/managed-certificates"=google_compute_managed_ssl_certificate.lb_default.name
    }
  }

  spec {
    default_backend {
      service {
        name = "seqr"
        port {
          number = 80
        }
      }
    }
  }
}

