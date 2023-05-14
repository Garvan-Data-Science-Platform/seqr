
resource "google_dns_record_set" "frontend" {
  name = "${var.domain_name}."
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.seqr.name

  rrdatas = [data.terraform_remote_state.gke.outputs.load_balancer_ip]
}

resource "google_dns_managed_zone" "seqr" {
  name     = "seqr"
  dns_name = "dsp.garvan.org.au."
}