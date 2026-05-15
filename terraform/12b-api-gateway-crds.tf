# Gateway API CRDs
data "http" "gateway_api_standard_crds" {
  url = "https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/standard-install.yaml"
}

data "kubectl_file_documents" "gateway_api_standard_crds" {
  content = data.http.gateway_api_standard_crds.response_body
}

resource "kubectl_manifest" "gateway_api_standard_crds" {
  for_each  = data.kubectl_file_documents.gateway_api_standard_crds.manifests
  yaml_body = each.value

  server_side_apply = true
  force_conflicts   = true

  depends_on = [
    aws_eks_cluster.demo,
    aws_eks_node_group.private-nodes
  ]
}