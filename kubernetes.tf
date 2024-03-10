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

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

# provider "kubernetes" {
#   host                   = module.eks.cluster_endpoint
#   cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
#   token                  = data.aws_eks_cluster_auth.cluster.token
#   load_config_file       = false
#   version                = "~> 1.9"
# }

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      module.eks.cluster_name
    ]
  }
}

# Read a Kubernetes config file
# data "local_file" "ingress" {
#   filename = "ingress.yaml"
#   depends_on = [aws_eks_addon.ebs-csi]
# }

# Parse the Kubernetes config file
# data "yamldecode" "kubernetes_config" {
#   input = data.local_file.ingress.content
# }

# # Create Kubernetes resource with the manifest
resource "kubernetes_manifest" "ingress" {
  for_each = {
    for value in [
      for yaml in split(
        "\n---\n",
        "\n${replace(file("${path.module}/ingress.yaml"), "/(?m)^---[[:blank:]]*(#.*)?$/", "---")}\n"
      ) :
      yamldecode(yaml)
      if trimspace(replace(yaml, "/(?m)(^[[:blank:]]*(#.*)?$)+/", "")) != ""
    ] : "${value["kind"]}--${value["metadata"]["name"]}" => value
  }
  manifest = each.value
}

# output the manifest content of the created resource.
output "content" {
  value = kubernetes_manifest.ingress[0].manifest
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
  
  depends_on = [kubernetes_manifest.ingress]
}