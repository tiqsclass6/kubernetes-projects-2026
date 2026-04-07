#!/usr/bin/env python3

from __future__ import annotations

import json
import re
import shutil
import socket
import subprocess
from dataclasses import dataclass, asdict
from datetime import datetime, timezone
from pathlib import Path
from typing import List, Optional


MAX_RUNS_TO_KEEP = 3


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
    stdout_file: Optional[str] = None
    stderr_file: Optional[str] = None


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


def safe_filename(value: str) -> str:
    return re.sub(r"[^a-zA-Z0-9._-]+", "-", value).strip("-").lower()


def write_text_file(path: Path, content: str) -> bool:
    if not content or not content.strip():
        return False

    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")
    return True


def save_command_artifacts(
    run_dir: Path,
    name: str,
    output: str,
    errors: str,
) -> tuple[Optional[str], Optional[str]]:
    checks_dir = run_dir / "checks"
    checks_dir.mkdir(parents=True, exist_ok=True)

    base = safe_filename(name)
    stdout_path = checks_dir / f"{base}.stdout.txt"
    stderr_path = checks_dir / f"{base}.stderr.txt"

    stdout_written = write_text_file(stdout_path, output)
    stderr_written = write_text_file(stderr_path, errors)

    return (
        str(stdout_path.relative_to(run_dir)) if stdout_written else None,
        str(stderr_path.relative_to(run_dir)) if stderr_written else None,
    )


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
        return "splunk-0" in combined and "running" in combined and "pvc" in combined
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


def collect_results(run_dir: Path) -> List[CommandResult]:
    results: List[CommandResult] = []

    has_kubectl = command_exists("kubectl")
    has_flux = command_exists("flux")

    for check in build_checks():
        command = check["command"]

        if command.startswith("kubectl") and not has_kubectl:
            stdout_file, stderr_file = save_command_artifacts(
                run_dir,
                check["name"],
                "",
                "kubectl not found in PATH",
            )
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
                    stdout_file=stdout_file,
                    stderr_file=stderr_file,
                )
            )
            continue

        if command.startswith("flux") and not has_flux:
            stdout_file, stderr_file = save_command_artifacts(
                run_dir,
                check["name"],
                "",
                "flux not found in PATH",
            )
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
                    stdout_file=stdout_file,
                    stderr_file=stderr_file,
                )
            )
            continue

        exit_code, output, errors = run_command(command)
        passed = evaluate_pass(check["name"], output, errors, exit_code)
        stdout_file, stderr_file = save_command_artifacts(
            run_dir,
            check["name"],
            output,
            errors,
        )

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
                stdout_file=stdout_file,
                stderr_file=stderr_file,
            )
        )

    localhost_ok, localhost_message = check_localhost_port(8091)
    stdout_text = localhost_message if localhost_ok else ""
    stderr_text = "" if localhost_ok else localhost_message
    stdout_file, stderr_file = save_command_artifacts(
        run_dir,
        "localhost_8091",
        stdout_text,
        stderr_text,
    )

    results.append(
        CommandResult(
            name="localhost_8091",
            description="Check whether localhost:8091 is reachable for Splunk UI.",
            command="socket check to 127.0.0.1:8091",
            required=False,
            screenshot_required=True,
            exit_code=0 if localhost_ok else 1,
            passed=localhost_ok,
            output=stdout_text,
            errors=stderr_text,
            stdout_file=stdout_file,
            stderr_file=stderr_file,
        )
    )

    return results


def capture_snapshot(run_dir: Path, name: str, command: str) -> dict:
    snapshots_dir = run_dir / "snapshots"
    snapshots_dir.mkdir(parents=True, exist_ok=True)

    exit_code, output, errors = run_command(command)
    yaml_path = snapshots_dir / f"{safe_filename(name)}.yaml"
    err_path = snapshots_dir / f"{safe_filename(name)}.stderr.txt"

    output_written = write_text_file(yaml_path, output)
    error_written = write_text_file(err_path, errors)

    return {
        "name": name,
        "command": command,
        "exit_code": exit_code,
        "output_file": str(yaml_path.relative_to(run_dir)) if output_written else None,
        "error_file": str(err_path.relative_to(run_dir)) if error_written else None,
        "captured": output_written,
    }


def capture_log(run_dir: Path, name: str, command: str) -> dict:
    logs_dir = run_dir / "logs"
    logs_dir.mkdir(parents=True, exist_ok=True)

    exit_code, output, errors = run_command(command)
    log_path = logs_dir / f"{safe_filename(name)}.log"
    err_path = logs_dir / f"{safe_filename(name)}.stderr.txt"

    log_written = write_text_file(log_path, output)
    error_written = write_text_file(err_path, errors)

    return {
        "name": name,
        "command": command,
        "exit_code": exit_code,
        "log_file": str(log_path.relative_to(run_dir)) if log_written else None,
        "error_file": str(err_path.relative_to(run_dir)) if error_written else None,
        "captured": log_written,
    }


def capture_state_artifacts(run_dir: Path) -> dict:
    snapshots = [
        capture_snapshot(
            run_dir,
            "flux-system-gitrepository",
            "kubectl -n flux-system get gitrepository github-platform -o yaml",
        ),
        capture_snapshot(
            run_dir,
            "flux-system-kustomization",
            "kubectl -n flux-system get kustomization splunk-dev -o yaml",
        ),
        capture_snapshot(
            run_dir,
            "splunk-dev-all",
            "kubectl -n splunk-dev get all -o yaml",
        ),
        capture_snapshot(
            run_dir,
            "splunk-dev-ingress",
            "kubectl -n splunk-dev get ingress -o yaml",
        ),
        capture_snapshot(
            run_dir,
            "cert-manager-clusterissuers",
            "kubectl get clusterissuer -o yaml",
        ),
        capture_snapshot(
            run_dir,
            "cert-manager-certificates",
            "kubectl -n splunk-dev get certificate -o yaml",
        ),
    ]

    logs = [
        capture_log(
            run_dir,
            "splunk-0",
            "kubectl -n splunk-dev logs splunk-0 --tail=500",
        ),
        capture_log(
            run_dir,
            "flux-kustomization-errors",
            "flux logs --level=error --kind=Kustomization --name=splunk-dev -n flux-system",
        ),
    ]

    return {"snapshots": snapshots, "logs": logs}


def build_markdown(results: List[CommandResult], state_artifacts: dict, run_id: str) -> str:
    generated_at = datetime.now(timezone.utc).astimezone().isoformat()

    required_total = sum(1 for r in results if r.required)
    required_passed = sum(1 for r in results if r.required and r.passed)
    optional_total = sum(1 for r in results if not r.required)
    optional_passed = sum(1 for r in results if not r.required and r.passed)

    lines: List[str] = []
    lines.append("# Project 4 Flux + Splunk Proof Report")
    lines.append("")
    lines.append(f"Run ID: `{run_id}`")
    lines.append(f"Generated: `{generated_at}`")
    lines.append("")
    lines.append("## Summary")
    lines.append("")
    lines.append(f"- Required checks passed: **{required_passed}/{required_total}**")
    lines.append(f"- Optional checks passed: **{optional_passed}/{optional_total}**")
    lines.append("")
    lines.append(f"- Overall required status: **{'PASS' if required_passed == required_total else 'FAIL'}**")
    lines.append("")
    lines.append("## Evidence inventory")
    lines.append("")
    lines.append("### Snapshots")
    lines.append("")
    for item in state_artifacts["snapshots"]:
        if item["output_file"] or item["error_file"]:
            lines.append(f"- `{item['name']}`")
            if item["output_file"]:
                lines.append(f"  - output: `{item['output_file']}`")
            if item["error_file"]:
                lines.append(f"  - errors: `{item['error_file']}`")
    lines.append("")
    lines.append("### Logs")
    lines.append("")
    for item in state_artifacts["logs"]:
        if item["log_file"] or item["error_file"]:
            lines.append(f"- `{item['name']}`")
            if item["log_file"]:
                lines.append(f"  - log: `{item['log_file']}`")
            if item["error_file"]:
                lines.append(f"  - errors: `{item['error_file']}`")
    lines.append("")
    lines.append("## Results")
    lines.append("")

    for result in results:
        status = "PASS" if result.passed else "FAIL"
        lines.append(f"### {result.name} — {status}")
        lines.append("")
        lines.append(f"- Description: {result.description}")
        lines.append(f"- Required: {'Yes' if result.required else 'No'}")
        lines.append(f"- Screenshot required: {'Yes' if result.screenshot_required else 'No'}")
        lines.append(f"- Exit code: `{result.exit_code}`")
        if result.stdout_file:
            lines.append(f"- Stdout artifact: `{result.stdout_file}`")
        if result.stderr_file:
            lines.append(f"- Stderr artifact: `{result.stderr_file}`")
        lines.append("")
        lines.append("```bash")
        lines.append(result.command)
        lines.append("```")
        lines.append("")

    return "\n".join(lines)


def build_json(results: List[CommandResult], state_artifacts: dict, run_id: str) -> dict:
    generated_at = datetime.now(timezone.utc).astimezone().isoformat()
    return {
        "project": "Project 4 Flux + Splunk",
        "run_id": run_id,
        "generated_at": generated_at,
        "required_checks_total": sum(1 for r in results if r.required),
        "required_checks_passed": sum(1 for r in results if r.required and r.passed),
        "optional_checks_total": sum(1 for r in results if not r.required),
        "optional_checks_passed": sum(1 for r in results if not r.required and r.passed),
        "results": [asdict(r) for r in results],
        "state_artifacts": state_artifacts,
    }


def build_summary(results: List[CommandResult], run_id: str) -> dict:
    required_total = sum(1 for r in results if r.required)
    required_passed = sum(1 for r in results if r.required and r.passed)
    optional_total = sum(1 for r in results if not r.required)
    optional_passed = sum(1 for r in results if not r.required and r.passed)

    return {
        "run_id": run_id,
        "generated_at": datetime.now(timezone.utc).astimezone().isoformat(),
        "overall_required_status": "PASS" if required_passed == required_total else "FAIL",
        "required_checks_total": required_total,
        "required_checks_passed": required_passed,
        "optional_checks_total": optional_total,
        "optional_checks_passed": optional_passed,
        "failed_required_checks": [r.name for r in results if r.required and not r.passed],
        "failed_optional_checks": [r.name for r in results if not r.required and not r.passed],
    }


def build_manifest(run_dir: Path) -> dict:
    files = []
    for path in sorted(run_dir.rglob("*")):
        if path.is_file():
            files.append(
                {
                    "path": str(path.relative_to(run_dir)),
                    "size_bytes": path.stat().st_size,
                }
            )
    return {
        "run_dir": str(run_dir),
        "file_count": len(files),
        "files": files,
    }


def refresh_latest(artifacts_root: Path, run_dir: Path) -> None:
    latest_dir = artifacts_root / "latest"
    if latest_dir.exists():
        shutil.rmtree(latest_dir)
    shutil.copytree(run_dir, latest_dir)


def enforce_retention(runs_dir: Path, keep: int = MAX_RUNS_TO_KEEP) -> None:
    if not runs_dir.exists():
        return

    run_dirs = sorted(
        [p for p in runs_dir.iterdir() if p.is_dir()],
        key=lambda p: p.name,
        reverse=True,
    )

    for old_dir in run_dirs[keep:]:
        shutil.rmtree(old_dir, ignore_errors=True)


def main() -> None:
    project_root = Path(__file__).resolve().parent.parent
    artifacts_root = project_root / "artifacts"
    runs_dir = artifacts_root / "runs"
    runs_dir.mkdir(parents=True, exist_ok=True)

    run_id = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")
    run_dir = runs_dir / run_id
    run_dir.mkdir(parents=True, exist_ok=True)

    results = collect_results(run_dir)
    state_artifacts = capture_state_artifacts(run_dir)

    proof_md_path = run_dir / "proof-of-project.md"
    proof_json_path = run_dir / "proof-resources.json"
    summary_path = run_dir / "summary.json"
    manifest_path = run_dir / "manifest.json"

    proof_md_path.write_text(
        build_markdown(results, state_artifacts, run_id),
        encoding="utf-8",
    )
    proof_json_path.write_text(
        json.dumps(build_json(results, state_artifacts, run_id), indent=2),
        encoding="utf-8",
    )
    summary_path.write_text(
        json.dumps(build_summary(results, run_id), indent=2),
        encoding="utf-8",
    )
    manifest_path.write_text(
        json.dumps(build_manifest(run_dir), indent=2),
        encoding="utf-8",
    )

    refresh_latest(artifacts_root, run_dir)
    enforce_retention(runs_dir, MAX_RUNS_TO_KEEP)

    required_total = sum(1 for r in results if r.required)
    required_passed = sum(1 for r in results if r.required and r.passed)

    print("Generated proof artifacts:")
    print(f"  - {run_dir}")
    print(f"  - {artifacts_root / 'latest'}")
    print(f"Required checks passed: {required_passed}/{required_total}")


if __name__ == "__main__":
    main()