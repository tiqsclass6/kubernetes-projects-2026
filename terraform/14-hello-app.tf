resource "kubernetes_deployment" "hello_app" {
  metadata {
    name      = "hello-app"
    namespace = var.app_namespace
    labels = {
      app = "hello-app"
    }
  }

  spec {
    replicas = var.hello_replicas

    selector {
      match_labels = {
        app = "hello-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "hello-app"
        }
      }

      spec {
        container {
          name  = "hello-app"
          image = "hashicorp/http-echo:1.0.0"

          args = [
            "-text=Hello from Kong Lab 1"
          ]

          port {
            container_port = 5678
          }
        }
      }
    }
  }

  depends_on = [helm_release.kong]
}

resource "kubernetes_service" "hello_service" {
  metadata {
    name      = "hello-service"
    namespace = var.app_namespace
  }

  spec {
    selector = {
      app = "hello-app"
    }

    port {
      port        = 80
      target_port = 5678
    }
  }

  depends_on = [kubernetes_deployment.hello_app]
}

resource "kubernetes_ingress_v1" "hello_ingress" {
  metadata {
    name      = "hello-ingress"
    namespace = var.app_namespace
    annotations = {
      "konghq.com/strip-path" = "true"
    }
  }

  spec {
    ingress_class_name = "kong"

    rule {
      http {
        path {
          path      = "/hello"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.hello_service.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.kong, kubernetes_service.hello_service]
}

resource "kubernetes_namespace" "app" {
  metadata {
    name = var.app_namespace
  }

  depends_on = [helm_release.kong]
}