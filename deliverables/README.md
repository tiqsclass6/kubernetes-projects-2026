# Project 7 Deliverables

Generated: 2026-06-18T16:40:41

## Folder Structure

```text
deliverables/
├── 01-yaml/
│   ├── key-auth-plugin.md
│   ├── key-auth-credential.md
│   ├── kong-consumer.md
│   ├── rate-limit-plugin.md
│   ├── ingress-rate-limit-plugin.md
│   ├── live-key-auth-plugin-export.md
│   ├── live-rate-limit-plugin-export.md
│   ├── live-kong-consumer-export.md
│   ├── live-key-auth-secret-export-redacted.md
│   ├── live-ingress-hello-ingress-export.md
│   └── ingress-annotation-evidence.md
├── 02-evidence/
│   ├── 00-kong-endpoint.txt
│   ├── 01-kubectl-get-kongplugin.txt
│   ├── 02-kubectl-describe-ingress-hello-ingress.txt
│   ├── 03-kubectl-get-svc.txt
│   ├── 04-kubectl-get-pods.txt
│   ├── 05-kubectl-logs-kong-controller-pod.txt
│   ├── 06-k6-run-rate-test-unauthenticated.txt
│   ├── 07-k6-run-key-rate-test-authenticated.txt
│   ├── 08-401-no-api-key-evidence.txt
│   ├── 09-200-valid-api-key-evidence.txt
│   └── 10-429-authenticated-flood-evidence.txt
└── 03-explanation/
    └── short-explanation-and-reflection.md
```

## Required Verification Commands Covered

```bash
kubectl get kongplugin
kubectl describe ingress hello-ingress
kubectl get svc
kubectl get pods
kubectl logs -n kong <kong-controller-pod>
k6 run rate-test.js
k6 run key-rate-test.js
```

## Key Answer

Request throttling is enforced **at Kong, before the upstream Kubernetes service handles the request**.

## Final Proof Pattern

```text
No API key        -> 401 Unauthorized
Valid API key     -> 200 OK
Flood after limit -> 429 Too Many Requests
```

## Note

The `01-yaml/` folder intentionally contains Markdown files only. Raw YAML files are not included in the deliverables folder.

The `02-evidence/` folder intentionally contains plain `.txt` files only. Evidence files do not use Markdown formatting.
