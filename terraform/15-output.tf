output "cluster_name" {
  value = aws_eks_cluster.demo.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.demo.endpoint
}

output "eks_cluster_info" {
  value = {
    name        = aws_eks_cluster.demo.name
    endpoint    = aws_eks_cluster.demo.endpoint
    arn         = aws_eks_cluster.demo.arn
    id          = aws_eks_cluster.demo.id
    description = "EKS cluster info"
  }
}


output "eks_node_group_summary" {
  value = format("Node group '%s' runs %s instance(s) of type %s",
    aws_eks_node_group.private-nodes.node_group_name,
    aws_eks_node_group.private-nodes.scaling_config[0].desired_size,
    join(", ", aws_eks_node_group.private-nodes.instance_types)
  )
  description = "Summary of EKS node group configuration"
}

output "hello_service_name" {
  value = kubernetes_service.hello_service.metadata[0].name
}

output "hello_ingress_name" {
  value = kubernetes_ingress_v1.hello_ingress.metadata[0].name
}

output "kong_namespace" {
  value = var.kong_namespace
}

output "next_steps" {
  value = <<EOT
Run the following after apply:

kubectl get pods
kubectl get svc
kubectl get ingress
kubectl get pods -n ${var.kong_namespace}
kubectl get svc -n ${var.kong_namespace}

Then test:
kubectl port-forward -n kong svc/kong-gateway-proxy 5678:80
curl http://localhost:5678/hello
EOT
}

# Output: AWS IAM Open ID Connect Provider ARN
output "openid_connect_provider" {
  description = "AWS IAM Open ID Connect Provider ARN"
  value = {
    arn = aws_iam_openid_connect_provider.oidc_provider.arn
    url = aws_eks_cluster.demo.identity[0].oidc[0].issuer
  }
}