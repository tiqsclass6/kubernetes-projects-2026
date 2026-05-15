resource "kubernetes_namespace" "kong" {
  metadata {
    name = var.kong_namespace
  }

  depends_on = [
    aws_eks_cluster.demo,
    aws_eks_node_group.private-nodes
  ]
}

resource "helm_release" "kong" {
  name       = "kong"
  repository = "https://charts.konghq.com"
  chart      = "ingress"
  namespace  = kubernetes_namespace.kong.metadata[0].name

  wait            = true
  timeout         = 600
  atomic          = true
  cleanup_on_fail = true

  depends_on = [
    kubernetes_namespace.kong,
    kubectl_manifest.gateway_api_standard_crds,
    aws_eks_cluster.demo,
    aws_eks_node_group.private-nodes
  ]
}