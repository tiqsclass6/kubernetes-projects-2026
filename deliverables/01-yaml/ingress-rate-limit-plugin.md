# Ingress Rate Limit Plugin

Source manifest:

```text
C:\Users\bjett\Documents\TheoWAF\class6\AWS\Terraform\Kubernetes\Theo\theo-labs\project-7\manifests\ingress-rate-limit-plugin.yaml
```

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: hello-ingress
  namespace: kong
  annotations:
    konghq.com/plugins: key-auth-plugin,rate-limit-plugin
spec:
  ingressClassName: kong
  rules:
    - http:
        paths:
          - path: /hello
            pathType: Prefix
            backend:
              service:
                name: hello-service
                port:
                  number: 80
```
