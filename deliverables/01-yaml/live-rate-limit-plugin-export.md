# Live Rate Limit KongPlugin Export

Timestamp: 2026-06-18T16:40:23

Command:

```bash
kubectl get kongplugin rate-limit-plugin -n kong -o yaml
```

Exit code: 0

```yaml
apiVersion: configuration.konghq.com/v1
config:
  minute: 5
  policy: local
kind: KongPlugin
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"configuration.konghq.com/v1","config":{"minute":5,"policy":"local"},"kind":"KongPlugin","metadata":{"annotations":{},"name":"rate-limit-plugin","namespace":"kong"},"plugin":"rate-limiting"}
  creationTimestamp: "2026-06-18T23:30:44Z"
  generation: 1
  name: rate-limit-plugin
  namespace: kong
  resourceVersion: "1781825444148255017"
  uid: 4228a4d5-61af-446c-8038-b10eddda4b93
plugin: rate-limiting
```
