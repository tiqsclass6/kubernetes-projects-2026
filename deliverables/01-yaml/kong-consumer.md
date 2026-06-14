# Kong Consumer

Source manifest:

```text
C:\Users\bjett\Documents\TheoWAF\class6\AWS\Terraform\Kubernetes\Theo\theo-labs\project-7\manifests\kong-consumer.yaml
```

```yaml
apiVersion: configuration.konghq.com/v1
kind: KongConsumer
metadata:
  name: lizzo-devote
  namespace: kong
  annotations:
    kubernetes.io/ingress.class: kong
username: lizzo-devote
credentials:
  - key-auth-super-secret
```
