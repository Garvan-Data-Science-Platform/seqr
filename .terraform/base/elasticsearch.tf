
resource "helm_release" "elastic_master" {

  name = "esmaster"

  repository       = "https://helm.elastic.co"
  chart            = "elasticsearch"
  #version          = "7.16.3"

  depends_on = [google_container_node_pool.primary_nodes]

  set {
    name = "imageTag"
    value = "latest"
  }
  set{
    name = "esMajorVersion"
    value = 7
  }
  set{
    name = "image"
    value = "australia-southeast1-docker.pkg.dev/dsp-registry-410602/docker/elasticsearch-gcs"
  }
  set {
    name = "service.type"
    value = "LoadBalancer"
  }
  set {
    name = "replicas"
    value = var.es_master_nodes
  }
  values = [
    "${file("${path.module}/es_master.yaml")}",

    yamlencode({"extraEnvs":[{"name":"ELASTIC_PASSWORD","value":data.google_secret_manager_secret_version.es_password.secret_data}]})
  ]

}

resource "helm_release" "elastic_data" {

  name = "esdata"

  repository       = "https://helm.elastic.co"
  chart            = "elasticsearch"
  #version          = "7.16.3"

  depends_on = [google_container_node_pool.data_nodes]

  set {
    name = "imageTag"
    value = "latest"
  }
  set{
    name = "esMajorVersion"
    value = 7
  }
  set{
    name = "image"
    value = "australia-southeast1-docker.pkg.dev/dsp-registry-410602/docker/elasticsearch-gcs"
  }
  set {
    name = "service.type"
    value = "LoadBalancer"
  }
  set {
    name = "replicas"
    value = var.es_data_nodes
  }
  values = [
    "${file("${path.module}/es_data.yaml")}",
    yamlencode({"extraEnvs":[{"name":"ELASTIC_PASSWORD","value":data.google_secret_manager_secret_version.es_password.secret_data}]})
  ]

}

resource "google_secret_manager_secret" "es_password" {
  secret_id = "es-password-${var.env}"

  replication {
    user_managed {
      replicas {
        location = "australia-southeast1"
      }
    }
  }

  provisioner "local-exec" { #This creates a randomly generated password
    command = "head /dev/urandom | LC_ALL=C tr -dc A-Za-z0-9 | head -c10 | gcloud secrets versions add es-password-${var.env} --project=${var.project_id} --data-file=-"
  }
}

data "google_secret_manager_secret_version" "es_password" {
  secret = google_secret_manager_secret.es_password.secret_id
}