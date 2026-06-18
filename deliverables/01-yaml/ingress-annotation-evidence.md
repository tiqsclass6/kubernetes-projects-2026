# Ingress Annotation Evidence

Timestamp: 2026-06-18T16:40:31

Command:

```bash
bash -lc kubectl describe ingress hello-ingress -n kong | grep -E 'Name:|Annotations:|konghq.com/plugins' || true
```

Exit code: 0

```yaml
--- STDERR ---
/bin/bash: line 1: kubectl: command not found
```
