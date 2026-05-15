data "aws_eks_cluster" "kong" {
  name = aws_eks_cluster.demo.name
}

data "aws_eks_cluster_auth" "kong" {
  name = aws_eks_cluster.demo.name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.kong.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.kong.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.kong.token
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.kong.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.kong.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.kong.token
  }
}

provider "kubectl" {
  host                   = data.aws_eks_cluster.kong.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.kong.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.kong.token
  load_config_file       = false
}