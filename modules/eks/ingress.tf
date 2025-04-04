resource "helm_release" "nginx_ingress" {
  name                = "nginx-ingress"
  repository          = "oci://ghcr.io/nginx/charts"
  chart               = "nginx-ingress"
  version             = "2.0.1"
  namespace           = "nginx-ingress"
  create_namespace    = true

  values = [file("${path.module}/k8s/nginx-ingress/values.yaml")]

  depends_on = [
    module.eks
  ]
}
