# Project 4 Flux + Splunk Proof Report

Run ID: `20260407-064228`
Generated: `2026-04-06T23:42:53.978764-07:00`

## Summary

- Required checks passed: **9/9**
- Optional checks passed: **11/11**

- Overall required status: **PASS**

## Evidence inventory

### Snapshots

- `flux-system-gitrepository`
  - output: `snapshots\flux-system-gitrepository.yaml`
- `flux-system-kustomization`
  - output: `snapshots\flux-system-kustomization.yaml`
- `splunk-dev-all`
  - output: `snapshots\splunk-dev-all.yaml`
- `splunk-dev-ingress`
  - output: `snapshots\splunk-dev-ingress.yaml`
- `cert-manager-clusterissuers`
  - output: `snapshots\cert-manager-clusterissuers.yaml`
- `cert-manager-certificates`
  - output: `snapshots\cert-manager-certificates.yaml`

### Logs

- `splunk-0`
  - log: `logs\splunk-0.log`

## Results

### flux_controllers — PASS

- Description: Verify Flux controllers are running in flux-system.
- Required: Yes
- Screenshot required: Yes
- Exit code: `0`
- Stdout artifact: `checks\flux_controllers.stdout.txt`

```bash
kubectl -n flux-system get pods
```

### git_source — PASS

- Description: Verify Flux GitRepository source status.
- Required: Yes
- Screenshot required: Yes
- Exit code: `0`
- Stdout artifact: `checks\git_source.stdout.txt`

```bash
flux get sources git -A
```

### git_source_describe — PASS

- Description: Describe the GitRepository backing Flux sync.
- Required: Yes
- Screenshot required: Yes
- Exit code: `0`
- Stdout artifact: `checks\git_source_describe.stdout.txt`

```bash
kubectl -n flux-system describe gitrepository github-platform
```

### kustomizations — PASS

- Description: Verify Flux Kustomization status.
- Required: Yes
- Screenshot required: Yes
- Exit code: `0`
- Stdout artifact: `checks\kustomizations.stdout.txt`

```bash
flux get kustomizations -A
```

### kustomization_describe — PASS

- Description: Describe the Splunk Flux Kustomization.
- Required: Yes
- Screenshot required: Yes
- Exit code: `0`
- Stdout artifact: `checks\kustomization_describe.stdout.txt`

```bash
kubectl -n flux-system describe kustomization splunk-dev
```

### splunk_namespace — PASS

- Description: Verify the Flux-managed namespace exists.
- Required: Yes
- Screenshot required: Yes
- Exit code: `0`
- Stdout artifact: `checks\splunk_namespace.stdout.txt`

```bash
kubectl get ns
```

### splunk_resources — PASS

- Description: Verify Splunk pod, service, and PVC.
- Required: Yes
- Screenshot required: Yes
- Exit code: `0`
- Stdout artifact: `checks\splunk_resources.stdout.txt`

```bash
kubectl -n splunk-dev get pods,svc,pvc
```

### splunk_statefulset — PASS

- Description: Verify Splunk StatefulSet.
- Required: Yes
- Screenshot required: Yes
- Exit code: `0`
- Stdout artifact: `checks\splunk_statefulset.stdout.txt`

```bash
kubectl -n splunk-dev get statefulset
```

### splunk_pod_describe — PASS

- Description: Describe the Splunk pod for proof/troubleshooting.
- Required: Yes
- Screenshot required: No
- Exit code: `0`
- Stdout artifact: `checks\splunk_pod_describe.stdout.txt`

```bash
kubectl -n splunk-dev describe pod splunk-0
```

### splunk_logs — PASS

- Description: Collect Splunk logs.
- Required: No
- Screenshot required: No
- Exit code: `0`
- Stdout artifact: `checks\splunk_logs.stdout.txt`

```bash
kubectl -n splunk-dev logs splunk-0
```

### ingress_nginx_pods — PASS

- Description: Verify ingress-nginx controller pods.
- Required: No
- Screenshot required: Yes
- Exit code: `0`
- Stdout artifact: `checks\ingress_nginx_pods.stdout.txt`

```bash
kubectl -n ingress-nginx get pods
```

### ingress_nginx_service — PASS

- Description: Verify ingress-nginx controller service.
- Required: No
- Screenshot required: Yes
- Exit code: `0`
- Stdout artifact: `checks\ingress_nginx_service.stdout.txt`

```bash
kubectl -n ingress-nginx get svc
```

### cert_manager_pods — PASS

- Description: Verify cert-manager pods.
- Required: No
- Screenshot required: Yes
- Exit code: `0`
- Stdout artifact: `checks\cert_manager_pods.stdout.txt`

```bash
kubectl -n cert-manager get pods
```

### cert_manager_crds — PASS

- Description: Verify cert-manager CRDs are installed.
- Required: No
- Screenshot required: Yes
- Exit code: `0`
- Stdout artifact: `checks\cert_manager_crds.stdout.txt`

```bash
kubectl get crd | grep cert-manager
```

### splunk_ingress — PASS

- Description: Verify Splunk ingress object.
- Required: No
- Screenshot required: Yes
- Exit code: `0`
- Stdout artifact: `checks\splunk_ingress.stdout.txt`

```bash
kubectl -n splunk-dev get ingress
```

### cluster_issuers — PASS

- Description: Verify ClusterIssuer resources.
- Required: No
- Screenshot required: Yes
- Exit code: `0`
- Stdout artifact: `checks\cluster_issuers.stdout.txt`

```bash
kubectl get clusterissuer
```

### tls_secret — PASS

- Description: Verify TLS secret exists.
- Required: No
- Screenshot required: Yes
- Exit code: `0`
- Stdout artifact: `checks\tls_secret.stdout.txt`

```bash
kubectl -n splunk-dev get secret splunk-web-tls
```

### flux_reconcile_source — PASS

- Description: Force Flux Git source reconciliation.
- Required: No
- Screenshot required: Yes
- Exit code: `0`
- Stderr artifact: `checks\flux_reconcile_source.stderr.txt`

```bash
flux reconcile source git github-platform -n flux-system
```

### flux_reconcile_kustomization — PASS

- Description: Force Flux Kustomization reconciliation.
- Required: No
- Screenshot required: Yes
- Exit code: `0`
- Stderr artifact: `checks\flux_reconcile_kustomization.stderr.txt`

```bash
flux reconcile kustomization splunk-dev -n flux-system --with-source
```

### localhost_8091 — PASS

- Description: Check whether localhost:8091 is reachable for Splunk UI.
- Required: No
- Screenshot required: Yes
- Exit code: `0`
- Stdout artifact: `checks\localhost_8091.stdout.txt`

```bash
socket check to 127.0.0.1:8091
```
