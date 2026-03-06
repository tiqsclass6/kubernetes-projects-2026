# Argo CD RBAC Instructions

Argo CD RBAC is usually configured via the argocd-rbac-cm ConfigMap in the argocd namespace using a Casbin policy.

---

## Below is a solid template you can use immediately

1) Decide your identity source (quick)

> Argo RBAC assigns permissions to users/groups that come from:

- SSO (OIDC/SAML) groups (best)
- local Argo users (OK for labs)

> For class labs, you can start with simple group names like:

- students
- admins

> Even if you don’t wire SSO yet, this teaches the RBAC mechanics.

1) Create/Update argocd-rbac-cm
argocd-rbac-cm.yaml

Then Apply:

```bash
kubectl apply -f argocd-rbac-cm.yaml
kubectl -n argocd rollout restart deployment argocd-server
kubectl -n argocd get cm argocd-rbac-cm -o yaml | sed -n '1,200p'
```

1) Name alignment (IMPORTANT)
Those RBAC rules reference application “project/name” patterns like:

    ```text
    splunk-dev/*
    splunk-test/*
    splunk-prod/*
    ```

This assumes:
  Your Argo AppProject names are splunk-dev, splunk-test, splunk-prod
  Your Applications are in those projects

Confirm:

```bash
kubectl -n argocd get appprojects
kubectl -n argocd get applications -o wide
```

---
