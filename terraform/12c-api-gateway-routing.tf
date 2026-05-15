# Gateway API Routing for Kong
resource "kubernetes_manifest" "kong_gateway_class" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "GatewayClass"

    metadata = {
      name = "kong"
    }

    spec = {
      controllerName = "konghq.com/kic-gateway-controller"
    }
  }

  depends_on = [
    kubectl_manifest.gateway_api_standard_crds,
    helm_release.kong
  ]
}

resource "kubernetes_manifest" "kong_gateway" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "Gateway"

    metadata = {
      name      = "kong"
      namespace = var.kong_namespace
    }

    spec = {
      gatewayClassName = "kong"

      listeners = [
        {
          name     = "http"
          protocol = "HTTP"
          port     = 80

          allowedRoutes = {
            namespaces = {
              from = "All"
            }
          }
        }
      ]
    }
  }

  depends_on = [
    kubernetes_manifest.kong_gateway_class,
    helm_release.kong
  ]
}

resource "kubernetes_manifest" "hello_http_route" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"

    metadata = {
      name      = "hello-route"
      namespace = var.app_namespace
      annotations = {
        "konghq.com/strip-path" = "true"
      }
    }

    spec = {
      parentRefs = [
        {
          name      = "kong"
          namespace = var.kong_namespace
        }
      ]

      rules = [
        {
          matches = [
            {
              path = {
                type  = "PathPrefix"
                value = "/hello"
              }
            }
          ]

          backendRefs = [
            {
              name = kubernetes_service.hello_service.metadata[0].name
              port = 80
            }
          ]
        }
      ]
    }
  }

  depends_on = [
    kubernetes_manifest.kong_gateway,
    kubernetes_service.hello_service
  ]
}