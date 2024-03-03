data "terraform_remote_state" "eks" {
  backend = "local"
  config = {
    path = "./terraform.tfstate"
  }
}

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

resource "helm_release" "nginx" {
  name       = "weaviate"
  namespace  = "weaviate"
  repository = "https://weaviate.github.io/weaviate-helm"
  chart      = "weaviate"

  values = [
    file("${path.module}/values.yaml")
  ]
}