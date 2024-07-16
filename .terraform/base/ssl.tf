resource "google_compute_managed_ssl_certificate" "lb_default" {
  provider = google-beta
  name     = "seqr-${var.env}-ssl-cert-2"

  managed {
    domains = ["${var.subdomain}.dsp.garvan.org.au"]
  }
}

#resource "google_compute_target_https_proxy" "lb_default" {
#  provider = google-beta
#  name     = "seqr-https-proxy"
#  url_map  = "/*"
#  ssl_certificates = [
#    google_compute_managed_ssl_certificate.lb_default.name
#  ]
#  depends_on = [
#    google_compute_managed_ssl_certificate.lb_default
#  ]
#}