# Key Auth Credential

Source manifest:

```text
C:\Users\bjett\Documents\TheoWAF\class6\AWS\Terraform\Kubernetes\Theo\theo-labs\project-7\manifests\key-auth-credential.yaml
```

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: key-auth-super-secret
  namespace: kong
  labels:
    konghq.com/credential: key-auth
  annotations:
    kubernetes.io/ingress.class: kong
type: Opaque
stringData:
  key: super-secret-key
```
