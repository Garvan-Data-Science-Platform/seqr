Log in to gcloud
`gcloud auth application-default login`

To hook up kubectl:
`gcloud container clusters get-credentials $(terraform output -raw kubernetes_cluster_name) --region $(terraform output -raw region)`
This requires gcloud auth plugin
`gcloud components install gke-gcloud-auth-plugin`
