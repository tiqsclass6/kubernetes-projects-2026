# Live Key Auth KongPlugin Export

Timestamp: 2026-06-13T22:10:24

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
  creationTimestamp: "2026-06-14T04:41:57Z"
  generation: 1
  name: key-auth-plugin
  namespace: kong
  resourceVersion: "1781412117147903023"
  uid: d0260b14-a7e8-4ae4-a04a-844fb70bd2ca
plugin: key-auth
```
