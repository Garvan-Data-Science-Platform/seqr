resource "google_dns_record_set" "seqr" {

  name = "${module.base.subdomain}.dsp.garvan.org.au."
  type = "A"
  ttl  = 300

  managed_zone = "dsp"
  project = "ctrl-358804"

  rrdatas = [coalesce(data.google_compute_global_address.seqr-static.address,"1.1.1.1")]
}

resource "google_compute_global_address" "seqr-static" {
  name = "ipv4-address-api-dev-2"
}

data "google_compute_global_address" "seqr-static" {
  depends_on = [google_compute_global_address.seqr-static]
  name = "ipv4-address-api-dev-2"
}

resource "kubernetes_service" "primary" {
  
  metadata {
    annotations = {
      "cloud.google.com/neg": "{\"ingress\": true}",
    }
    name = "primary"
    labels = {
        App = "coldstart-nginx"
    }
  }
  spec {
    selector = {
      App = "coldstart-nginx" #This should match the kubernetes deployment
    }
    port {
      port = 80
      target_port = 80
    }

    type = "NodePort"
  }
}

resource "kubernetes_ingress_v1" "gke-ingress" {
  wait_for_load_balancer = true
  metadata {
    name = "gke-ingress"
    annotations = {
        "kubernetes.io/ingress.global-static-ip-name"=google_compute_global_address.seqr-static.name
        "kubernetes.io/ingress.class"="gce"
        "ingress.gcp.kubernetes.io/pre-shared-cert"=module.base.ssl_cert
    }
  }

  spec {
    default_backend {
      service {
        name = "primary"
        port {
          number = 80
        }
      }
    }
  }
}