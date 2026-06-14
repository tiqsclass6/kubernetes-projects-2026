# Live KongConsumer Export

Timestamp: 2026-06-13T22:10:26

Command:

```bash
kubectl get kongconsumer lizzo-devote -n kong -o yaml
```

Exit code: 0

```yaml
apiVersion: configuration.konghq.com/v1
credentials:
- key-auth-super-secret
kind: KongConsumer
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"configuration.konghq.com/v1","credentials":["key-auth-super-secret"],"kind":"KongConsumer","metadata":{"annotations":{"kubernetes.io/ingress.class":"kong"},"name":"lizzo-devote","namespace":"kong"},"username":"lizzo-devote"}
    kubernetes.io/ingress.class: kong
  creationTimestamp: "2026-06-14T04:41:56Z"
  generation: 1
  name: lizzo-devote
  namespace: kong
  resourceVersion: "1781412116719695016"
  uid: 8606e3dc-b3d8-4ad8-bd5c-61e5413ebb38
status:
  conditions:
  - lastTransitionTime: "2026-06-14T04:41:56Z"
    message: Object was successfully configured in Kong.
    observedGeneration: 1
    reason: Programmed
    status: "True"
    type: Programmed
username: lizzo-devote
```
