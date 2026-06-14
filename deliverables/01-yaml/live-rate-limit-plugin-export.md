# Live Rate Limit KongPlugin Export

Timestamp: 2026-06-13T22:10:25

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
  creationTimestamp: "2026-06-14T04:41:58Z"
  generation: 1
  name: rate-limit-plugin
  namespace: kong
  resourceVersion: "1781412118127615017"
  uid: ecbd0161-8101-4eaf-a515-5abb9e050bc5
plugin: rate-limiting
```
