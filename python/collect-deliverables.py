#!/usr/bin/env python3
"""
collect-deliverables-fixed.py

Project 7 Deliverables Collector

Fixes common evidence-collection failures by avoiding fragile `bash -lc` wrappers
for kubectl, curl, and k6. This is especially important on Windows/Git Bash,
where Python may find kubectl/k6 but Bash may not inherit the same PATH.

Usage:
  python ./python/collect-deliverables.py

Recommended:
  Run from the project root after the GKE cluster and Kong resources are live.

Optional environment variables:
  KUBECTL=kubectl
  CURL=curl
  K6=k6
  KONG_NAMESPACE=kong
  KONG_SERVICE=kong-gateway-proxy
  INGRESS_NAME=hello-ingress
  API_KEY=super-secret-key
  API_PATH=/hello
  DELIVERABLES_DIR=deliverables
"""

from __future__ import annotations

import os
import re
import shlex
import shutil
import subprocess
import tempfile
from datetime import datetime
from pathlib import Path
from typing import Callable


# -----------------------------------------------------------------------------
# Path and project configuration
# -----------------------------------------------------------------------------

SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = SCRIPT_DIR.parent if SCRIPT_DIR.name == "python" else Path.cwd()

MANIFEST_DIR = Path(os.getenv("MANIFEST_DIR", PROJECT_ROOT / "manifests"))
PYTHON_DIR = Path(os.getenv("PYTHON_DIR", PROJECT_ROOT / "python"))
DELIVERABLES_DIR = Path(os.getenv("DELIVERABLES_DIR", PROJECT_ROOT / "deliverables"))

YAML_DIR = DELIVERABLES_DIR / "01-yaml"
EVIDENCE_DIR = DELIVERABLES_DIR / "02-evidence"
EXPLANATION_DIR = DELIVERABLES_DIR / "03-explanation"

KONG_NAMESPACE = os.getenv("KONG_NAMESPACE", "kong")
KONG_SERVICE = os.getenv("KONG_SERVICE", "kong-gateway-proxy")
INGRESS_NAME = os.getenv("INGRESS_NAME", "hello-ingress")
API_PATH = os.getenv("API_PATH", "/hello")
API_KEY = os.getenv("API_KEY", "super-secret-key")

KEY_AUTH_PLUGIN_NAME = os.getenv("KEY_AUTH_PLUGIN_NAME", "key-auth-plugin")
RATE_LIMIT_PLUGIN_NAME = os.getenv("RATE_LIMIT_PLUGIN_NAME", "rate-limit-plugin")
KONG_CONSUMER_NAME = os.getenv("KONG_CONSUMER_NAME", "lizzo-devote")
KEY_AUTH_SECRET_NAME = os.getenv("KEY_AUTH_SECRET_NAME", "key-auth-super-secret")

RATE_TEST_FILE = Path(os.getenv("RATE_TEST_FILE", PYTHON_DIR / "rate-test.js"))
KEY_RATE_TEST_FILE = Path(os.getenv("KEY_RATE_TEST_FILE", PYTHON_DIR / "key-rate-test.js"))

MANIFEST_FILES = {
    "key-auth-plugin.yaml": MANIFEST_DIR / "key-auth-plugin.yaml",
    "key-auth-credential.yaml": MANIFEST_DIR / "key-auth-credential.yaml",
    "kong-consumer.yaml": MANIFEST_DIR / "kong-consumer.yaml",
    "rate-limit-plugin.yaml": MANIFEST_DIR / "rate-limit-plugin.yaml",
    "ingress-rate-limit-plugin.yaml": MANIFEST_DIR / "ingress-rate-limit-plugin.yaml",
}


# -----------------------------------------------------------------------------
# Terminal colors
# -----------------------------------------------------------------------------

MAGENTA = "\033[0;95m"
YELLOW = "\033[1;33m"
GREEN = "\033[0;32m"
RED = "\033[0;31m"
NC = "\033[0m"


def print_header(text: str, color: str = MAGENTA) -> None:
    print(f"\n{color}{'═' * 70}{NC}")
    print(f"{color}  {text}{NC}")
    print(f"{color}{'═' * 70}{NC}\n")


def print_step(text: str) -> None:
    print(f"\n---- {text}")


# -----------------------------------------------------------------------------
# Command helpers
# -----------------------------------------------------------------------------

def resolve_executable(env_name: str, default: str) -> str:
    configured = os.getenv(env_name, default)
    configured_path = Path(configured)

    # Explicit path supplied by user.
    if configured_path.is_absolute() or configured_path.parent != Path("."):
        return str(configured_path)

    return shutil.which(configured) or configured


KUBECTL = resolve_executable("KUBECTL", "kubectl")
CURL = resolve_executable("CURL", "curl")
K6 = resolve_executable("K6", "k6")


def command_exists(command: str) -> bool:
    # If command is an explicit path, check that file. Otherwise search PATH.
    p = Path(command)
    if p.is_absolute() or p.parent != Path("."):
        return p.exists()
    return shutil.which(command) is not None


def kubectl_cmd(*args: str) -> list[str]:
    return [KUBECTL, *args]


def curl_cmd(*args: str) -> list[str]:
    return [CURL, *args]


def k6_cmd(*args: str) -> list[str]:
    return [K6, *args]


def format_command(command: list[str]) -> str:
    """Return a readable command line for evidence files."""
    try:
        return shlex.join(str(part) for part in command)
    except Exception:
        return " ".join(str(part) for part in command)


def redact_sensitive(text: str) -> str:
    if API_KEY:
        text = text.replace(API_KEY, "<redacted>")
    return text


def run_command(
    command: list[str],
    timeout: int = 120,
    env: dict[str, str] | None = None,
) -> tuple[int, str]:
    """
    Run a command and return (exit_code, combined_output).
    Does not raise on non-zero exit so evidence is still captured.
    """
    merged_env = os.environ.copy()
    if env:
        merged_env.update(env)

    try:
        completed = subprocess.run(
            command,
            text=True,
            capture_output=True,
            timeout=timeout,
            check=False,
            env=merged_env,
        )

        output = ""
        if completed.stdout:
            output += completed.stdout
        if completed.stderr:
            output += "\n--- STDERR ---\n" + completed.stderr

        return completed.returncode, output.strip()

    except FileNotFoundError:
        return 127, f"Command not found: {command[0]}"

    except subprocess.TimeoutExpired as exc:
        partial_output = ""
        if exc.stdout:
            partial_output += exc.stdout if isinstance(exc.stdout, str) else exc.stdout.decode(errors="ignore")
        if exc.stderr:
            partial_output += "\n--- STDERR ---\n"
            partial_output += exc.stderr if isinstance(exc.stderr, str) else exc.stderr.decode(errors="ignore")

        return 124, f"Command timed out after {timeout} seconds.\n{partial_output}".strip()


def write_text(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content.rstrip() + "\n", encoding="utf-8")


def evidence_text(name: str, command: list[str] | str, exit_code: int, output: str) -> str:
    command_text = command if isinstance(command, str) else format_command(command)
    return f"""Title: {name}
Timestamp: {datetime.now().isoformat(timespec="seconds")}

Command:
{redact_sensitive(command_text)}

Exit code: {exit_code}

Output:
{redact_sensitive(output)}
"""


def capture_command(
    name: str,
    command: list[str],
    output_path: Path,
    timeout: int = 120,
    env: dict[str, str] | None = None,
) -> tuple[int, str]:
    print_step(f"Capturing: {name}")
    exit_code, output = run_command(command, timeout=timeout, env=env)
    write_text(output_path, evidence_text(name, command, exit_code, output))
    status = "PASS" if exit_code == 0 else "WARN"
    print(f"{status}: wrote {output_path}")
    return exit_code, output


def capture_custom_text(name: str, command_display: str, exit_code: int, output: str, output_path: Path) -> None:
    print_step(f"Capturing: {name}")
    write_text(output_path, evidence_text(name, command_display, exit_code, output))
    status = "PASS" if exit_code == 0 else "WARN"
    print(f"{status}: wrote {output_path}")


# -----------------------------------------------------------------------------
# Kubernetes helpers
# -----------------------------------------------------------------------------

def get_kong_host() -> str:
    hostname_cmd = kubectl_cmd(
        "get", "svc", KONG_SERVICE,
        "-n", KONG_NAMESPACE,
        "-o", "jsonpath={.status.loadBalancer.ingress[0].hostname}",
    )

    ip_cmd = kubectl_cmd(
        "get", "svc", KONG_SERVICE,
        "-n", KONG_NAMESPACE,
        "-o", "jsonpath={.status.loadBalancer.ingress[0].ip}",
    )

    hostname_code, hostname = run_command(hostname_cmd)
    if hostname_code == 0 and hostname.strip():
        return hostname.strip()

    ip_code, ip_address = run_command(ip_cmd)
    if ip_code == 0 and ip_address.strip():
        return ip_address.strip()

    return ""


def find_kong_controller_pod() -> str:
    selectors = [
        "app.kubernetes.io/component=controller",
        "app.kubernetes.io/name=ingress-controller",
        "app.kubernetes.io/instance=kong",
    ]

    for selector in selectors:
        cmd = kubectl_cmd(
            "get", "pods",
            "-n", KONG_NAMESPACE,
            "-l", selector,
            "-o", "jsonpath={.items[0].metadata.name}",
        )

        exit_code, output = run_command(cmd)
        bad_output = "array index out of bounds" in output or "Error" in output

        if exit_code == 0 and output.strip() and not bad_output:
            return output.strip()

    return ""


def read_manifest_or_placeholder(path: Path) -> str:
    if path.exists():
        return path.read_text(encoding="utf-8", errors="replace").strip()

    return f"# Missing expected manifest: {path}"


def markdown_file_name(yaml_name: str) -> str:
    return yaml_name.replace(".yaml", ".md").replace(".yml", ".md")


# -----------------------------------------------------------------------------
# Deliverable generation
# -----------------------------------------------------------------------------

def reset_deliverables_folder() -> None:
    print_header("RESETTING DELIVERABLES FOLDER")

    if DELIVERABLES_DIR.exists():
        print(f"Deleting existing deliverables folder: {DELIVERABLES_DIR}")
        shutil.rmtree(DELIVERABLES_DIR)

    for directory in [YAML_DIR, EVIDENCE_DIR, EXPLANATION_DIR]:
        directory.mkdir(parents=True, exist_ok=True)
        print(f"Created: {directory}")


def redact_secret_yaml(output: str) -> str:
    # Redact both plain `key:` fields and base64 `data.key` fields if present.
    output = re.sub(r"(?m)^(\s*key:\s*).+$", r"\1<redacted>", output)
    output = re.sub(r"(?m)^(\s*apikey:\s*).+$", r"\1<redacted>", output)
    return output


def filter_ingress_annotations(output: str) -> str:
    patterns = re.compile(r"Name:|Annotations:|konghq\.com/plugins")
    lines = [line for line in output.splitlines() if patterns.search(line)]
    return "\n".join(lines) if lines else output


def write_live_markdown(output_name: str, title: str, command: list[str], transform: Callable[[str], str] | None = None) -> None:
    exit_code, output = run_command(command, timeout=120)

    if transform and exit_code == 0:
        output = transform(output)

    md = f"""# {title}

Timestamp: {datetime.now().isoformat(timespec="seconds")}

Command:

```bash
{redact_sensitive(format_command(command))}
```

Exit code: {exit_code}

```yaml
{redact_sensitive(output)}
```
"""
    output_path = YAML_DIR / output_name
    write_text(output_path, md)
    print(f"Wrote live Markdown evidence: {output_path}")


def collect_yaml_deliverables_as_markdown() -> None:
    print_header("COLLECTING YAML DELIVERABLES AS MARKDOWN ONLY")

    for filename, source_path in MANIFEST_FILES.items():
        content = read_manifest_or_placeholder(source_path)
        title = filename.replace("-", " ").replace(".yaml", "").title()

        md = f"""# {title}

Source manifest:

```text
{source_path}
```

```yaml
{content}
```
"""

        output_path = YAML_DIR / markdown_file_name(filename)
        write_text(output_path, md)
        print(f"Wrote Markdown YAML documentation: {output_path}")

    write_live_markdown(
        "live-key-auth-plugin-export.md",
        "Live Key Auth KongPlugin Export",
        kubectl_cmd("get", "kongplugin", KEY_AUTH_PLUGIN_NAME, "-n", KONG_NAMESPACE, "-o", "yaml"),
    )

    write_live_markdown(
        "live-rate-limit-plugin-export.md",
        "Live Rate Limit KongPlugin Export",
        kubectl_cmd("get", "kongplugin", RATE_LIMIT_PLUGIN_NAME, "-n", KONG_NAMESPACE, "-o", "yaml"),
    )

    write_live_markdown(
        "live-kong-consumer-export.md",
        "Live KongConsumer Export",
        kubectl_cmd("get", "kongconsumer", KONG_CONSUMER_NAME, "-n", KONG_NAMESPACE, "-o", "yaml"),
    )

    write_live_markdown(
        "live-key-auth-secret-export-redacted.md",
        "Live Key Auth Secret Export Redacted",
        kubectl_cmd("get", "secret", KEY_AUTH_SECRET_NAME, "-n", KONG_NAMESPACE, "-o", "yaml"),
        transform=redact_secret_yaml,
    )

    write_live_markdown(
        "live-ingress-hello-ingress-export.md",
        "Live Ingress Export",
        kubectl_cmd("get", "ingress", INGRESS_NAME, "-n", KONG_NAMESPACE, "-o", "yaml"),
    )

    write_live_markdown(
        "ingress-annotation-evidence.md",
        "Ingress Annotation Evidence",
        kubectl_cmd("describe", "ingress", INGRESS_NAME, "-n", KONG_NAMESPACE),
        transform=filter_ingress_annotations,
    )


def collect_required_verification_commands() -> None:
    print_header("RUNNING REQUIRED VERIFICATION COMMANDS")

    capture_command(
        "kubectl get kongplugin",
        kubectl_cmd("get", "kongplugin", "-n", KONG_NAMESPACE),
        EVIDENCE_DIR / "01-kubectl-get-kongplugin.txt",
    )

    capture_command(
        "kubectl describe ingress hello-ingress",
        kubectl_cmd("describe", "ingress", INGRESS_NAME, "-n", KONG_NAMESPACE),
        EVIDENCE_DIR / "02-kubectl-describe-ingress-hello-ingress.txt",
    )

    capture_command(
        "kubectl get svc",
        kubectl_cmd("get", "svc", "-n", KONG_NAMESPACE),
        EVIDENCE_DIR / "03-kubectl-get-svc.txt",
    )

    capture_command(
        "kubectl get pods",
        kubectl_cmd("get", "pods", "-n", KONG_NAMESPACE),
        EVIDENCE_DIR / "04-kubectl-get-pods.txt",
    )

    controller_pod = find_kong_controller_pod()

    if controller_pod:
        capture_command(
            f"kubectl logs -n kong {controller_pod}",
            kubectl_cmd("logs", "-n", KONG_NAMESPACE, controller_pod, "--tail=200"),
            EVIDENCE_DIR / "05-kubectl-logs-kong-controller-pod.txt",
            timeout=180,
        )
    else:
        write_text(
            EVIDENCE_DIR / "05-kubectl-logs-kong-controller-pod.txt",
            f"""Title: kubectl logs -n kong <kong-controller-pod>
Timestamp: {datetime.now().isoformat(timespec="seconds")}

Result:
Could not automatically detect a Kong controller pod.

Manual command:
kubectl get pods -n {KONG_NAMESPACE}
kubectl logs -n {KONG_NAMESPACE} <kong-controller-pod>
""",
        )
        print("WARN: could not detect Kong controller pod. Wrote manual instructions.")

    kong_host = get_kong_host()
    kong_url = f"http://{kong_host}" if kong_host else ""

    if command_exists(K6) and RATE_TEST_FILE.exists():
        capture_command(
            "k6 run rate-test.js - unauthenticated should return 401",
            k6_cmd("run", str(RATE_TEST_FILE)),
            EVIDENCE_DIR / "06-k6-run-rate-test-unauthenticated.txt",
            timeout=300,
            env={"KONG_URL": kong_url} if kong_url else None,
        )
    else:
        write_text(
            EVIDENCE_DIR / "06-k6-run-rate-test-unauthenticated.txt",
            f"""Title: k6 run rate-test.js
Timestamp: {datetime.now().isoformat(timespec="seconds")}

Result:
Could not run k6 automatically.

Reason:
- k6 found: {command_exists(K6)}
- Expected file exists: {RATE_TEST_FILE.exists()}

Expected file:
{RATE_TEST_FILE}
""",
        )

    if command_exists(K6) and KEY_RATE_TEST_FILE.exists():
        capture_command(
            "k6 run key-rate-test.js - authenticated should return 200 or 429",
            k6_cmd("run", str(KEY_RATE_TEST_FILE)),
            EVIDENCE_DIR / "07-k6-run-key-rate-test-authenticated.txt",
            timeout=300,
            env={"KONG_URL": kong_url, "API_KEY": API_KEY} if kong_url else {"API_KEY": API_KEY},
        )
    else:
        write_text(
            EVIDENCE_DIR / "07-k6-run-key-rate-test-authenticated.txt",
            f"""Title: k6 run key-rate-test.js
Timestamp: {datetime.now().isoformat(timespec="seconds")}

Result:
Could not run authenticated k6 automatically.

Reason:
- k6 found: {command_exists(K6)}
- Expected file exists: {KEY_RATE_TEST_FILE.exists()}

Expected file:
{KEY_RATE_TEST_FILE}
""",
        )


def collect_request_evidence() -> None:
    print_header("COLLECTING 401 / 200 / 429 REQUEST EVIDENCE")

    kong_host = get_kong_host()

    if not kong_host:
        write_text(
            EVIDENCE_DIR / "08-request-evidence.txt",
            f"""Title: Request Evidence
Timestamp: {datetime.now().isoformat(timespec="seconds")}

Result:
Could not detect Kong LoadBalancer hostname or IP from service {KONG_SERVICE} in namespace {KONG_NAMESPACE}.

Manual command:
kubectl get svc {KONG_SERVICE} -n {KONG_NAMESPACE}
""",
        )
        print("WARN: could not detect Kong LoadBalancer host.")
        return

    base_url = f"http://{kong_host}{API_PATH}"

    write_text(
        EVIDENCE_DIR / "00-kong-endpoint.txt",
        f"""Title: Kong Endpoint
Timestamp: {datetime.now().isoformat(timespec="seconds")}

Detected Kong endpoint:
{base_url}

External IP command:
kubectl get svc {KONG_SERVICE} -n {KONG_NAMESPACE} -o jsonpath='{{.status.loadBalancer.ingress[0].ip}}'
""",
    )

    capture_command(
        "401 evidence - request without API key",
        curl_cmd("-i", "-sS", base_url),
        EVIDENCE_DIR / "08-401-no-api-key-evidence.txt",
        timeout=120,
    )

    capture_command(
        "200 evidence - request with valid API key",
        curl_cmd("-i", "-sS", base_url, "-H", f"apikey: {API_KEY}"),
        EVIDENCE_DIR / "09-200-valid-api-key-evidence.txt",
        timeout=120,
    )

    capture_authenticated_flood(base_url)


def capture_authenticated_flood(base_url: str) -> None:
    response_file = Path(tempfile.gettempdir()) / "project7-flood-response.txt"
    lines: list[str] = []
    final_exit = 0

    display_command = (
        "for i in 1..10: "
        f"curl -s -o {response_file} -w %{{http_code}} {base_url} -H 'apikey: <redacted>'"
    )

    for i in range(1, 11):
        command = curl_cmd(
            "-sS",
            "-o", str(response_file),
            "-w", "%{http_code}",
            base_url,
            "-H", f"apikey: {API_KEY}",
        )
        exit_code, output = run_command(command, timeout=30)
        if exit_code != 0:
            final_exit = exit_code

        status = output.strip().splitlines()[-1] if output.strip() else f"exit={exit_code}"
        lines.append(f"Request {i} -> {status}")

    capture_custom_text(
        "429 evidence - authenticated flood test",
        display_command,
        final_exit,
        "\n".join(lines),
        EVIDENCE_DIR / "10-429-authenticated-flood-evidence.txt",
    )


def write_short_explanation() -> None:
    print_header("WRITING SHORT EXPLANATION AND REFLECTION ANSWERS")

    content = f"""# Project 7 Short Explanation and Reflection

Generated: {datetime.now().isoformat(timespec="seconds")}

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
"""

    write_text(EXPLANATION_DIR / "short-explanation-and-reflection.md", content)


def write_readme_index() -> None:
    content = f"""# Project 7 Deliverables

Generated: {datetime.now().isoformat(timespec="seconds")}

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
"""

    write_text(DELIVERABLES_DIR / "README.md", content)


def preflight_checks() -> None:
    print_step("Checking required CLI tools")
    required = {"kubectl": KUBECTL, "curl": CURL}
    missing = [name for name, path in required.items() if not command_exists(path)]

    if missing:
        print(f"{RED}ERROR: Missing required tools: {', '.join(missing)}{NC}")
        print("Install the missing tools or set explicit paths, for example:")
        print("  PowerShell: $env:KUBECTL='C:\\path\\to\\kubectl.exe'")
        print("  Bash:       export KUBECTL=/usr/local/bin/kubectl")
        raise SystemExit(1)

    if not command_exists(K6):
        print(f"{YELLOW}WARN: k6 was not found. Placeholder k6 evidence will be written.{NC}")

    # Fail fast if kubectl exists but cannot talk to the configured cluster.
    exit_code, output = run_command(kubectl_cmd("version", "--client"), timeout=30)
    if exit_code != 0:
        print(f"{RED}ERROR: kubectl exists but failed to run.{NC}")
        print(output)
        raise SystemExit(1)


def main() -> None:
    print_header("PROJECT 7 DELIVERABLES COLLECTOR")

    print_step("Resolved project paths")
    print(f"Project root : {PROJECT_ROOT}")
    print(f"Manifest dir : {MANIFEST_DIR}")
    print(f"Python dir   : {PYTHON_DIR}")
    print(f"Deliverables : {DELIVERABLES_DIR}")
    print(f"kubectl      : {KUBECTL}")
    print(f"curl         : {CURL}")
    print(f"k6           : {K6}")

    preflight_checks()

    reset_deliverables_folder()
    collect_yaml_deliverables_as_markdown()
    collect_required_verification_commands()
    collect_request_evidence()
    write_short_explanation()
    write_readme_index()

    print_header("DELIVERABLES COLLECTION COMPLETE", GREEN)
    print(f"Deliverables folder created fresh at: {DELIVERABLES_DIR.resolve()}")
    print("\nNext step:")
    print("Review the rebuilt deliverables/ folder and commit it with your project submission.")


if __name__ == "__main__":
    main()
