# Live Ingress Export

Timestamp: 2026-06-13T22:10:33

Command:

```bash
kubectl get ingress hello-ingress -n kong -o yaml
```

Exit code: 0

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    konghq.com/plugins: key-auth-plugin,rate-limit-plugin
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"networking.k8s.io/v1","kind":"Ingress","metadata":{"annotations":{"konghq.com/plugins":"key-auth-plugin,rate-limit-plugin"},"name":"hello-ingress","namespace":"kong"},"spec":{"ingressClassName":"kong","rules":[{"http":{"paths":[{"backend":{"service":{"name":"hello-service","port":{"number":80}}},"path":"/hello","pathType":"Prefix"}]}}]}}
  creationTimestamp: "2026-06-14T04:41:59Z"
  generation: 1
  name: hello-ingress
  namespace: kong
  resourceVersion: "1781412119738143011"
  uid: 5f11648e-4574-4b16-877c-4230bbd6a7cf
spec:
  ingressClassName: kong
  rules:
  - http:
      paths:
      - backend:
          service:
            name: hello-service
            port:
              number: 80
        path: /hello
        pathType: Prefix
status:
  loadBalancer:
    ingress:
    - ip: 34.31.86.102
```
