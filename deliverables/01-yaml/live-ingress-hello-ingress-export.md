# Live Ingress Export

Timestamp: 2026-06-18T16:40:31

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
  creationTimestamp: "2026-06-18T23:30:45Z"
  generation: 1
  name: hello-ingress
  namespace: kong
  resourceVersion: "1781825463113647011"
  uid: d5486d7e-b805-461e-b50f-e6e009689099
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
    - ip: 34.30.43.65
```
