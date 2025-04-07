resource "helm_release" "nginx_ingress" {
  name             = "nginx-ingress"
  repository       = var.ingress_repository
  chart            = var.ingress_chart
  version          = var.ingress_version
  namespace        = var.ingress_namespace
  create_namespace = true
  wait             = var.ingress_wait

  values = [file("${path.module}/k8s/nginx-ingress/values.yaml")]

  depends_on = [
    module.eks
  ]
}
