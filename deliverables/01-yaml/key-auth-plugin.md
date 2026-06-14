# Key Auth Plugin

Source manifest:

```text
C:\Users\bjett\Documents\TheoWAF\class6\AWS\Terraform\Kubernetes\Theo\theo-labs\project-7\manifests\key-auth-plugin.yaml
```

```yaml
apiVersion: configuration.konghq.com/v1
kind: KongPlugin
metadata:
  name: key-auth-plugin
  namespace: kong
plugin: key-auth
config:
  key_names:
    - apikey
  key_in_header: true
  key_in_query: false
  key_in_body: false
  hide_credentials: true
```
