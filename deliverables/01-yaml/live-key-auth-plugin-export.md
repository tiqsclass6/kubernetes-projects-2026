# Live Key Auth KongPlugin Export

Timestamp: 2026-06-18T16:40:22

Command:

```bash
kubectl get kongplugin key-auth-plugin -n kong -o yaml
```

Exit code: 0

```yaml
apiVersion: configuration.konghq.com/v1
config:
  hide_credentials: true
  key_in_body: false
  key_in_header: true
  key_in_query: false
  key_names:
  - apikey
kind: KongPlugin
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"configuration.konghq.com/v1","config":{"hide_credentials":true,"key_in_body":false,"key_in_header":true,"key_in_query":false,"key_names":["apikey"]},"kind":"KongPlugin","metadata":{"annotations":{},"name":"key-auth-plugin","namespace":"kong"},"plugin":"key-auth"}
  creationTimestamp: "2026-06-18T23:30:43Z"
  generation: 1
  name: key-auth-plugin
  namespace: kong
  resourceVersion: "1781825443233711023"
  uid: 0b8c0f8e-98be-400e-b179-a4e8b6d6dbe8
plugin: key-auth
```
