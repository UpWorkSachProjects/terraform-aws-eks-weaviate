provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
      command     = "aws"
    }
  }
}

resource "helm_release" "qdrant" {
  name       = "qdrant"
  create_namespace = true
  namespace  = "qdrant"
  repository = "https://qdrant.to/helm"
  chart      = "qdrant"

  values = [
    file("${path.module}/qdrant.yaml")
  ]
  
  depends_on = [ helm_release.nginx-ingress-controller ]
}

resource "helm_release" "nginx-ingress-controller" {
  name       = "nginx-ingress-controller"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx-ingress-controller"


  set {
    name  = "service.type"
    value = "LoadBalancer"
  }
}
