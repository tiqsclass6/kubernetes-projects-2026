# Live KongConsumer Export

Timestamp: 2026-06-18T16:40:23

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
  creationTimestamp: "2026-06-18T23:30:42Z"
  generation: 1
  name: lizzo-devote
  namespace: kong
  resourceVersion: "1781825444036159016"
  uid: 568ff56d-3faf-4138-86c8-66c10fe6631f
status:
  conditions:
  - lastTransitionTime: "2026-06-18T23:30:44Z"
    message: Object was successfully configured in Kong.
    observedGeneration: 1
    reason: Programmed
    status: "True"
    type: Programmed
username: lizzo-devote
```
