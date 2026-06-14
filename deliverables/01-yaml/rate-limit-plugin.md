# Rate Limit Plugin

Source manifest:

```text
C:\Users\bjett\Documents\TheoWAF\class6\AWS\Terraform\Kubernetes\Theo\theo-labs\project-7\manifests\rate-limit-plugin.yaml
```

```yaml
apiVersion: configuration.konghq.com/v1
kind: KongPlugin
metadata:
  name: rate-limit-plugin
  namespace: kong
plugin: rate-limiting
config:
  minute: 5
  policy: local
```
