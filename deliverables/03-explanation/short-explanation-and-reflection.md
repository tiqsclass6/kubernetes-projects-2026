# Project 7 Short Explanation and Reflection

Generated: 2026-06-18T16:40:41

## Where is request throttling enforced?

Request throttling is enforced **at Kong, before the upstream Kubernetes service handles the request**.

Kong Gateway evaluates authentication and rate-limiting policy before forwarding traffic to the upstream Kubernetes `hello-service`. A request without an API key is rejected with `401 Unauthorized`. A request with the valid `apikey` header is allowed through and returns `200 OK` until the configured rate limit is exceeded. Once the limit is exceeded, Kong rejects additional traffic with `429 Too Many Requests`.

## Required Deliverables Summary

### 1. YAML Documentation

The YAML deliverables are stored as Markdown files in:

```text
deliverables/01-yaml/
```

No raw `.yaml` files are written to the deliverables folder. Each Markdown file contains the relevant YAML in a fenced code block.

Included Markdown files document:

- `key-auth-plugin.yaml`
- `key-auth-credential.yaml`
- `kong-consumer.yaml`
- `rate-limit-plugin.yaml`
- `ingress-rate-limit-plugin.yaml`
- exported live KongPlugin YAML
- exported live KongConsumer YAML
- exported live Ingress YAML
- redacted live Secret metadata

### 2. Evidence

The evidence files are stored as plain text files in:

```text
deliverables/02-evidence/
```

Required proof pattern:

```text
No API key        -> 401 Unauthorized
Valid API key     -> 200 OK
Flood after limit -> 429 Too Many Requests
```

Included evidence:

- `kubectl get kongplugin`
- `kubectl describe ingress hello-ingress`
- `kubectl get svc`
- `kubectl get pods`
- Kong controller logs
- unauthenticated k6 output
- authenticated k6 output
- 401 no-key curl evidence
- 200 valid-key curl evidence
- 429 authenticated flood evidence

### 3. Short Explanation

Kong acts as the API gateway and enforces both authentication and request throttling before traffic reaches the upstream Kubernetes Service or application pods.

## Reflection Questions

### Why is authentication alone not enough?

Authentication verifies who a user or client is, but it does not control how much traffic that authenticated client can send. A valid authenticated user can still accidentally or intentionally overload an application by sending too many requests. Rate limiting adds traffic control after identity verification by limiting request volume over time.

### Why should rate limiting happen at the gateway instead of inside every microservice?

Rate limiting should happen at the gateway because the gateway is the central entry point for external traffic. Enforcing limits at Kong provides one consistent policy layer before traffic reaches backend services. This avoids duplicating rate-limiting code inside every microservice, reduces application complexity, and blocks abusive traffic earlier in the request path.

### What is the difference between 401, 403, and 429?

- `401 Unauthorized` means the request is missing valid authentication credentials.
- `403 Forbidden` means the client may be authenticated, but it does not have permission to access the requested resource.
- `429 Too Many Requests` means the client has sent too many requests in a configured time window and has been rate limited.

### How could a bad rate limit configuration break production?

A bad rate limit configuration could block legitimate users, throttle critical services, or create false outages. If the limit is too low, normal user traffic may start receiving `429 Too Many Requests`. If limits are applied globally instead of per consumer, one busy client could exhaust the shared quota for everyone. If the limit is too high, the backend services may still be overwhelmed during traffic spikes or abuse.
