#!/usr/bin/env python3

from __future__ import annotations

import json
import shutil
import socket
import subprocess
from dataclasses import dataclass, asdict
from datetime import datetime, timezone
from pathlib import Path
from typing import List, Optional


@dataclass
class CommandResult:
    name: str
    description: str
    command: str
    required: bool
    screenshot_required: bool
    exit_code: Optional[int]
    passed: bool
    output: str
    errors: str


def command_exists(cmd: str) -> bool:
    return shutil.which(cmd) is not None


def run_command(command: str) -> tuple[Optional[int], str, str]:
    try:
        completed = subprocess.run(
            command,
            shell=True,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
        )
        return completed.returncode, completed.stdout.strip(), completed.stderr.strip()
    except Exception as exc:
        return None, "", f"Exception while running command: {exc}"


def check_localhost_port(port: int, timeout: float = 2.0) -> tuple[bool, str]:
    try:
        with socket.create_connection(("127.0.0.1", port), timeout=timeout):
            return True, f"localhost:{port} is reachable"
    except Exception as exc:
        return False, f"localhost:{port} is not reachable: {exc}"


def build_checks() -> List[dict]:
    return [
        {
            "name": "flux_controllers",
            "description": "Verify Flux controllers are running in flux-system.",
            "command": "kubectl -n flux-system get pods",
            "required": True,
            "screenshot_required": True,
        },
        {
            "name": "git_source",
            "description": "Verify Flux GitRepository source status.",
            "command": "flux get sources git -A",
            "required": True,
            "screenshot_required": True,
        },
        {
            "name": "git_source_describe",
            "description": "Describe the GitRepository backing Flux sync.",
            "command": "kubectl -n flux-system describe gitrepository github-platform",
            "required": True,
            "screenshot_required": True,
        },
        {
            "name": "kustomizations",
            "description": "Verify Flux Kustomization status.",
            "command": "flux get kustomizations -A",
            "required": True,
            "screenshot_required": True,
        },
        {
            "name": "kustomization_describe",
            "description": "Describe the Splunk Flux Kustomization.",
            "command": "kubectl -n flux-system describe kustomization splunk-dev",
            "required": True,
            "screenshot_required": True,
        },
        {
            "name": "splunk_namespace",
            "description": "Verify the Flux-managed namespace exists.",
            "command": "kubectl get ns",
            "required": True,
            "screenshot_required": True,
        },
        {
            "name": "splunk_resources",
            "description": "Verify Splunk pod, service, and PVC.",
            "command": "kubectl -n splunk-dev get pods,svc,pvc",
            "required": True,
            "screenshot_required": True,
        },
        {
            "name": "splunk_statefulset",
            "description": "Verify Splunk StatefulSet.",
            "command": "kubectl -n splunk-dev get statefulset",
            "required": True,
            "screenshot_required": True,
        },
        {
            "name": "splunk_pod_describe",
            "description": "Describe the Splunk pod for proof/troubleshooting.",
            "command": "kubectl -n splunk-dev describe pod splunk-0",
            "required": True,
            "screenshot_required": False,
        },
        {
            "name": "splunk_logs",
            "description": "Collect Splunk logs.",
            "command": "kubectl -n splunk-dev logs splunk-0",
            "required": False,
            "screenshot_required": False,
        },
        {
            "name": "ingress_nginx_pods",
            "description": "Verify ingress-nginx controller pods.",
            "command": "kubectl -n ingress-nginx get pods",
            "required": False,
            "screenshot_required": True,
        },
        {
            "name": "ingress_nginx_service",
            "description": "Verify ingress-nginx controller service.",
            "command": "kubectl -n ingress-nginx get svc",
            "required": False,
            "screenshot_required": True,
        },
        {
            "name": "cert_manager_pods",
            "description": "Verify cert-manager pods.",
            "command": "kubectl -n cert-manager get pods",
            "required": False,
            "screenshot_required": True,
        },
        {
            "name": "cert_manager_crds",
            "description": "Verify cert-manager CRDs are installed.",
            "command": "kubectl get crd | grep cert-manager",
            "required": False,
            "screenshot_required": True,
        },
        {
            "name": "splunk_ingress",
            "description": "Verify Splunk ingress object.",
            "command": "kubectl -n splunk-dev get ingress",
            "required": False,
            "screenshot_required": True,
        },
        {
            "name": "cluster_issuers",
            "description": "Verify ClusterIssuer resources.",
            "command": "kubectl get clusterissuer",
            "required": False,
            "screenshot_required": True,
        },
        {
            "name": "tls_secret",
            "description": "Verify TLS secret exists.",
            "command": "kubectl -n splunk-dev get secret splunk-web-tls",
            "required": False,
            "screenshot_required": True,
        },
        {
            "name": "flux_reconcile_source",
            "description": "Force Flux Git source reconciliation.",
            "command": "flux reconcile source git github-platform -n flux-system",
            "required": False,
            "screenshot_required": True,
        },
        {
            "name": "flux_reconcile_kustomization",
            "description": "Force Flux Kustomization reconciliation.",
            "command": "flux reconcile kustomization splunk-dev -n flux-system --with-source",
            "required": False,
            "screenshot_required": True,
        },
    ]


def evaluate_pass(name: str, output: str, errors: str, exit_code: Optional[int]) -> bool:
    if exit_code != 0:
        return False

    combined = f"{output}\n{errors}".lower()

    if name == "flux_controllers":
        return "source-controller" in combined and "running" in combined
    if name == "git_source":
        return "github-platform" in combined and "true" in combined
    if name == "git_source_describe":
        return "github-platform" in combined and "url:" in combined
    if name == "kustomizations":
        return "splunk-dev" in combined and "true" in combined
    if name == "kustomization_describe":
        return "./clusters/dev/splunk" in combined and "prune:" in combined
    if name == "splunk_namespace":
        return "splunk-dev" in combined
    if name == "splunk_resources":
        return "splunk-0" in combined and "running" in combined and "splunk-pvc" in combined
    if name == "splunk_statefulset":
        return "splunk" in combined
    if name == "splunk_pod_describe":
        return "name:             splunk-0" in output.lower() or "name: splunk-0" in output.lower()
    if name == "splunk_logs":
        return bool(output.strip())
    if name == "ingress_nginx_pods":
        return "ingress-nginx-controller" in combined
    if name == "ingress_nginx_service":
        return "ingress-nginx-controller" in combined
    if name == "cert_manager_pods":
        return "cert-manager" in combined
    if name == "cert_manager_crds":
        return "cert-manager.io" in combined
    if name == "splunk_ingress":
        return exit_code == 0
    if name == "cluster_issuers":
        return exit_code == 0
    if name == "tls_secret":
        return "splunk-web-tls" in combined
    if name == "flux_reconcile_source":
        return exit_code == 0
    if name == "flux_reconcile_kustomization":
        return exit_code == 0

    return exit_code == 0


def collect_results() -> List[CommandResult]:
    results: List[CommandResult] = []

    has_kubectl = command_exists("kubectl")
    has_flux = command_exists("flux")

    for check in build_checks():
        command = check["command"]

        if command.startswith("kubectl") and not has_kubectl:
            results.append(
                CommandResult(
                    name=check["name"],
                    description=check["description"],
                    command=command,
                    required=check["required"],
                    screenshot_required=check["screenshot_required"],
                    exit_code=None,
                    passed=False,
                    output="",
                    errors="kubectl not found in PATH",
                )
            )
            continue

        if command.startswith("flux") and not has_flux:
            results.append(
                CommandResult(
                    name=check["name"],
                    description=check["description"],
                    command=command,
                    required=check["required"],
                    screenshot_required=check["screenshot_required"],
                    exit_code=None,
                    passed=False,
                    output="",
                    errors="flux not found in PATH",
                )
            )
            continue

        exit_code, output, errors = run_command(command)
        passed = evaluate_pass(check["name"], output, errors, exit_code)

        results.append(
            CommandResult(
                name=check["name"],
                description=check["description"],
                command=command,
                required=check["required"],
                screenshot_required=check["screenshot_required"],
                exit_code=exit_code,
                passed=passed,
                output=output,
                errors=errors,
            )
        )

    localhost_ok, localhost_message = check_localhost_port(8091)
    results.append(
        CommandResult(
            name="localhost_8091",
            description="Check whether localhost:8091 is reachable for Splunk UI.",
            command="socket check to 127.0.0.1:8091",
            required=False,
            screenshot_required=True,
            exit_code=0 if localhost_ok else 1,
            passed=localhost_ok,
            output=localhost_message if localhost_ok else "",
            errors="" if localhost_ok else localhost_message,
        )
    )

    return results


def build_markdown(results: List[CommandResult]) -> str:
    generated_at = datetime.now(timezone.utc).astimezone().isoformat()

    required_total = sum(1 for r in results if r.required)
    required_passed = sum(1 for r in results if r.required and r.passed)
    optional_total = sum(1 for r in results if not r.required)
    optional_passed = sum(1 for r in results if not r.required and r.passed)

    lines: List[str] = []
    lines.append("# Project 4 Flux + Splunk Proof Report")
    lines.append("")
    lines.append(f"Generated: `{generated_at}`")
    lines.append("")
    lines.append("## Summary")
    lines.append("")
    lines.append(f"- Required checks passed: **{required_passed}/{required_total}**")
    lines.append(f"- Optional checks passed: **{optional_passed}/{optional_total}**")
    lines.append("")

    if required_passed == required_total:
        lines.append("Overall required status: **PASS**")
    else:
        lines.append("Overall required status: **FAIL**")

    lines.append("")
    lines.append("## Learning objectives to say out loud")
    lines.append("")
    lines.append("1. GitRepository = “Flux, watch this repo”")
    lines.append("2. Kustomization = “Apply this folder continuously”")
    lines.append("3. prune=true = “If it’s removed from Git, remove it from cluster”")
    lines.append("4. Flux is a reconciler: cluster drift gets corrected back to Git state")
    lines.append("")
    lines.append("## Results")
    lines.append("")

    output_counter = 1

    for result in results:
        status = "PASS" if result.passed else "FAIL"
        required_text = "Required" if result.required else "Optional"
        screenshot_text = "Yes" if result.screenshot_required else "No"

        lines.append(f"### {result.name} — {status}")
        lines.append("")
        lines.append(f"- Description: {result.description}")
        lines.append(f"- Required: {required_text}")
        lines.append(f"- Screenshot required: {screenshot_text}")
        lines.append("")
        lines.append("```bash")
        lines.append(result.command)
        lines.append("```")
        lines.append("")

        if result.output:
            lines.append(f"### **Output {output_counter}**")
            lines.append("")
            lines.append("```text")
            lines.append(result.output)
            lines.append("```")
            lines.append("")
            output_counter += 1

        if result.errors:
            lines.append(f"### **Errors {output_counter}**")
            lines.append("")
            lines.append("```text")
            lines.append(result.errors)
            lines.append("```")
            lines.append("")
            output_counter += 1

    return "\n".join(lines)


def build_json(results: List[CommandResult]) -> dict:
    generated_at = datetime.now(timezone.utc).astimezone().isoformat()
    return {
        "project": "Project 4 Flux + Splunk",
        "generated_at": generated_at,
        "required_checks_total": sum(1 for r in results if r.required),
        "required_checks_passed": sum(1 for r in results if r.required and r.passed),
        "optional_checks_total": sum(1 for r in results if not r.required),
        "optional_checks_passed": sum(1 for r in results if not r.required and r.passed),
        "results": [asdict(r) for r in results],
    }


def main() -> None:
    project_root = Path(__file__).resolve().parent.parent
    md_path = project_root / "artifacts" / "proof-of-project.md"
    json_path = project_root / "artifacts" / "proof-resources.json"

    results = collect_results()

    md_path.write_text(build_markdown(results), encoding="utf-8")
    json_path.write_text(json.dumps(build_json(results), indent=2), encoding="utf-8")

    print("Generated proof artifacts:")
    print(f"  - {md_path}")
    print(f"  - {json_path}")

    required_total = sum(1 for r in results if r.required)
    required_passed = sum(1 for r in results if r.required and r.passed)
    print(f"Required checks passed: {required_passed}/{required_total}")


if __name__ == "__main__":
    main()