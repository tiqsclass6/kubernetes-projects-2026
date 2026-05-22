provider "kubernetes" {
  host                   = aws_eks_cluster.demo.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.demo.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "kubectl" {
  host                   = aws_eks_cluster.demo.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.demo.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

# Kong Ingress Controller via Helm
resource "helm_release" "kong" {
  depends_on = [
    aws_eks_node_group.private-nodes,
    null_resource.update_kubeconfig,
    helm_release.ebs_csi_driver
  ]

  name             = "kong"
  repository       = "https://charts.konghq.com"
  chart            = "ingress"
  namespace        = "kong"
  create_namespace = true

  set = [
    {
      name  = "ingressController.installCRDs"
      value = "true"
    },
    {
      name  = "proxy.type"
      value = "LoadBalancer"
    },
    {
      name  = "proxy.http.enabled"
      value = "true"
    },
    {
      name  = "proxy.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
      value = "nlb"
    }
  ]
}

# Hello App Deployment
resource "kubernetes_deployment_v1" "hello_app" {
  depends_on = [helm_release.kong]

  metadata {
    name      = "hello-app"
    namespace = "default"
  }

  spec {
    replicas = 2

    selector {
      match_labels = { app = "hello" }
    }

    template {
      metadata {
        labels = { app = "hello" }
      }

      spec {
        container {
          image = "nginx:alpine"
          name  = "hello"

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

# Hello Service (using v1)
resource "kubernetes_service_v1" "hello_service" {
  metadata {
    name      = "hello-service"
    namespace = "default"
  }

  spec {
    selector = { app = "hello" }

    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}

# Apply all manifests from manifests/ folder
resource "kubectl_manifest" "kong_manifests" {
  depends_on = [
    helm_release.kong,
    kubernetes_service_v1.hello_service
  ]

  for_each = fileset(path.module, "manifests/*.yaml")

  yaml_body = file("${path.module}/${each.value}")
}