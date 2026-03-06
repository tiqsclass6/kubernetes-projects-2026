# Deploying ArgoCD and Splunk

```bash
kubectl apply -f argoproject-splunk-prod.yaml
kubectl apply -f argoproject-splunk-dev.yaml
kubectl apply -f argoproject-splunk-test.yaml
```

```bash
kubectl -n argocd get appprojects
```

```bash
kubectl apply -f 30-app-splunk-prod.yaml
kubectl apply -f 31-app-splunk-dev.yaml
kubectl apply -f 32-app-splunk-test.yaml
```
