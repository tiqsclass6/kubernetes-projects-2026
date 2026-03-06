# How students “prove” RBAC works

## Test cases you can require

Have them attempt:

A) Sync dev (should succeed for students)
UI: click Sync on splunk-dev
or CLI (if you use argocd CLI with login)

B) Sync prod (should fail for students)
Expected: permission denied

C) Admin sync prod (should succeed)

> Optional: argocd CLI demo (very teachable)

---

## If they have argocd CLI

Port-forward:

```bash
kubectl -n argocd port-forward svc/argocd-server 9081:9081
```

Login (admin for lab):

```bash
argocd login localhost:9081 --insecure

List apps:
argocd app list

Sync dev:
argocd app sync splunk-dev

Try prod as student (should fail):
argocd app sync splunk-prod
```
