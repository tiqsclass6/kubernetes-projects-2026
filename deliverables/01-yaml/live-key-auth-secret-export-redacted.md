# Live Key Auth Secret Export Redacted

Timestamp: 2026-06-13T22:10:32

Command:

```bash
bash -lc kubectl get secret key-auth-super-secret -n kong -o yaml | sed -E 's/(key: ).*/\1<redacted>/'
```

Exit code: 0

```yaml
--- STDERR ---
/bin/bash: line 1: kubectl: command not found
```
