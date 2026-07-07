resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.12.0"
  namespace        = "cert-manager"
  create_namespace = true

  values = [yamlencode({
    installCRDs = true
  })]
}
