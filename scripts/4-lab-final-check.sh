#!/usr/bin/env bash
# =============================================================================
# Script: lab-status.sh
# Purpose: Validate the full Argo CD security lab environment in one command.
#          Checks cluster connectivity, Argo CD health, AppProjects,
#          Applications, RBAC policy, local users, and password-secret keys.
#
# Usage:   ./scripts/lab-status.sh
# =============================================================================

set -euo pipefail
IFS=$'\n\t'

# ──────────────────────────────────────────────────────────────────────────────
# COLOR DEFINITIONS
# ──────────────────────────────────────────────────────────────────────────────
MAGENTA='\033[0;95m'
TEAL='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

print_header() {
  local color="$1"
  local text="$2"
  printf "\n${color}══════════════════════════════════════════════════════════════════════${NC}\n"
  printf "${color}  %s${NC}\n" "$text"
  printf "${color}══════════════════════════════════════════════════════════════════════${NC}\n\n"
}

log_info()  { printf "${GREEN}[INFO]${NC}  %s\n" "$*"; }
log_warn()  { printf "${YELLOW}[WARN]${NC}  %s\n" "$*"; }
log_error() { printf "${RED}[ERROR]${NC} %s\n" "$*" >&2; }
log_pass()  { printf "${GREEN}[PASS]${NC}  %s\n" "$*"; }
log_fail()  { printf "${RED}[FAIL]${NC}  %s\n" "$*"; }

# ──────────────────────────────────────────────────────────────────────────────
# CONFIGURATION
# ──────────────────────────────────────────────────────────────────────────────
NAMESPACE="argocd"

PROJECTS=(
  "splunk-prod"
  "splunk-dev"
  "splunk-test"
)

APPLICATIONS=(
  "splunk:splunk-prod"
  "splunk-dev:splunk-dev"
  "splunk-test:splunk-test"
)

USERS=(
  "admin1"
  "student1"
  "student2"
)

EXPECTED_RBAC_LINES=(
  "g, admin1, role:admin"
  "g, student1, role:devtest-operator"
  "g, student2, role:devtest-operator"
  "p, role:devtest-operator, applications, sync, splunk-dev/*, allow"
  "p, role:devtest-operator, applications, sync, splunk-test/*, allow"
  "p, role:devtest-operator, applications, sync, splunk-prod/*, deny"
)

FAILURES=0

# ──────────────────────────────────────────────────────────────────────────────
# HELPERS
# ──────────────────────────────────────────────────────────────────────────────
check_command_exists() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || {
    log_fail "Required command not found in PATH: $cmd"
    FAILURES=$((FAILURES + 1))
    return 1
  }
}

record_failure() {
  FAILURES=$((FAILURES + 1))
}

# ──────────────────────────────────────────────────────────────────────────────
# CHECKS
# ──────────────────────────────────────────────────────────────────────────────
preflight_checks() {
  print_header "$MAGENTA" "0. PREFLIGHT CHECKS"

  check_command_exists kubectl || true
  check_command_exists grep || true
  check_command_exists sed || true

  if kubectl cluster-info >/dev/null 2>&1; then
    log_pass "Kubernetes cluster is reachable."
  else
    log_fail "Cannot reach Kubernetes cluster."
    record_failure
  fi

  local current_ctx
  current_ctx="$(kubectl config current-context 2>/dev/null || true)"
  if [[ -n "${current_ctx}" ]]; then
    log_pass "kubectl current-context: ${current_ctx}"
  else
    log_fail "kubectl current-context is not set."
    record_failure
  fi
}

check_argocd_core() {
  print_header "$MAGENTA" "1. ARGO CD CORE HEALTH"

  if kubectl get namespace "${NAMESPACE}" >/dev/null 2>&1; then
    log_pass "Namespace '${NAMESPACE}' exists."
  else
    log_fail "Namespace '${NAMESPACE}' does not exist."
    record_failure
    return
  fi

  local pods_output
  pods_output="$(kubectl -n "${NAMESPACE}" get pods --no-headers 2>/dev/null || true)"

  if [[ -z "${pods_output}" ]]; then
    log_fail "No Argo CD pods found in namespace '${NAMESPACE}'."
    record_failure
  else
    kubectl -n "${NAMESPACE}" get pods -o wide
    echo

    local not_running
    not_running="$(printf '%s\n' "${pods_output}" | awk '$3 != "Running" {count++} END {print count+0}')"
    if [[ "${not_running}" -eq 0 ]]; then
      log_pass "All Argo CD pods are Running."
    else
      log_fail "One or more Argo CD pods are not Running."
      record_failure
    fi
  fi

  if kubectl -n "${NAMESPACE}" get deploy argocd-server >/dev/null 2>&1; then
    log_pass "argocd-server deployment exists."
  else
    log_fail "argocd-server deployment missing."
    record_failure
  fi

  if kubectl -n "${NAMESPACE}" get svc argocd-server >/dev/null 2>&1; then
    log_pass "argocd-server service exists."
  else
    log_fail "argocd-server service missing."
    record_failure
  fi
}

check_appprojects() {
  print_header "$MAGENTA" "2. APPPROJECT VALIDATION"

  kubectl -n "${NAMESPACE}" get appprojects || true
  echo

  for project in "${PROJECTS[@]}"; do
    if kubectl -n "${NAMESPACE}" get appproject "${project}" >/dev/null 2>&1; then
      log_pass "AppProject exists: ${project}"
    else
      log_fail "Missing AppProject: ${project}"
      record_failure
    fi
  done
}

check_applications() {
  print_header "$MAGENTA" "3. APPLICATION VALIDATION"

  kubectl -n "${NAMESPACE}" get applications -o wide || true
  echo

  for item in "${APPLICATIONS[@]}"; do
    local app="${item%%:*}"
    local expected_project="${item##*:}"

    if ! kubectl -n "${NAMESPACE}" get application "${app}" >/dev/null 2>&1; then
      log_fail "Missing Application: ${app}"
      record_failure
      continue
    fi

    local actual_project sync_status health_status dest_namespace
    actual_project="$(kubectl -n "${NAMESPACE}" get application "${app}" -o jsonpath='{.spec.project}' 2>/dev/null || true)"
    sync_status="$(kubectl -n "${NAMESPACE}" get application "${app}" -o jsonpath='{.status.sync.status}' 2>/dev/null || true)"
    health_status="$(kubectl -n "${NAMESPACE}" get application "${app}" -o jsonpath='{.status.health.status}' 2>/dev/null || true)"
    dest_namespace="$(kubectl -n "${NAMESPACE}" get application "${app}" -o jsonpath='{.spec.destination.namespace}' 2>/dev/null || true)"

    if [[ "${actual_project}" == "${expected_project}" ]]; then
      log_pass "Application '${app}' is aligned to project '${expected_project}'."
    else
      log_fail "Application '${app}' project mismatch. Expected '${expected_project}', found '${actual_project:-missing}'."
      record_failure
    fi

    if [[ "${sync_status}" == "Synced" ]]; then
      log_pass "Application '${app}' sync status is Synced."
    else
      log_fail "Application '${app}' sync status is '${sync_status:-unknown}'."
      record_failure
    fi

    if [[ "${health_status}" == "Healthy" ]]; then
      log_pass "Application '${app}' health status is Healthy."
    else
      log_fail "Application '${app}' health status is '${health_status:-unknown}'."
      record_failure
    fi

    log_info "Application '${app}' destination namespace: ${dest_namespace:-unknown}"
  done
}

check_rbac() {
  print_header "$MAGENTA" "4. RBAC VALIDATION"

  if ! kubectl -n "${NAMESPACE}" get cm argocd-rbac-cm >/dev/null 2>&1; then
    log_fail "ConfigMap argocd-rbac-cm is missing."
    record_failure
    return
  fi

  local rbac_yaml policy_csv
  rbac_yaml="$(kubectl -n "${NAMESPACE}" get cm argocd-rbac-cm -o yaml)"
  policy_csv="$(kubectl -n "${NAMESPACE}" get cm argocd-rbac-cm -o jsonpath='{.data.policy\.csv}' 2>/dev/null || true)"

  printf '%s\n' "${rbac_yaml}" | sed -n '1,220p'
  echo

  for line in "${EXPECTED_RBAC_LINES[@]}"; do
    if printf '%s\n' "${policy_csv}" | grep -Fqx "${line}"; then
      log_pass "RBAC rule present: ${line}"
    else
      log_fail "Missing RBAC rule: ${line}"
      record_failure
    fi
  done

  local policy_default match_mode
  policy_default="$(kubectl -n "${NAMESPACE}" get cm argocd-rbac-cm -o jsonpath='{.data.policy\.default}' 2>/dev/null || true)"
  match_mode="$(kubectl -n "${NAMESPACE}" get cm argocd-rbac-cm -o jsonpath='{.data.policy\.matchMode}' 2>/dev/null || true)"

  [[ "${policy_default}" == "role:readonly" ]] && \
    log_pass "RBAC default policy is role:readonly." || {
      log_fail "RBAC default policy is '${policy_default:-missing}', expected 'role:readonly'."
      record_failure
    }

  [[ "${match_mode}" == "glob" ]] && \
    log_pass "RBAC match mode is glob." || {
      log_fail "RBAC match mode is '${match_mode:-missing}', expected 'glob'."
      record_failure
    }
}

check_local_users() {
  print_header "$MAGENTA" "5. LOCAL USER VALIDATION"

  if ! kubectl -n "${NAMESPACE}" get cm argocd-cm >/dev/null 2>&1; then
    log_fail "ConfigMap argocd-cm is missing."
    record_failure
    return
  fi

  if ! kubectl -n "${NAMESPACE}" get secret argocd-secret >/dev/null 2>&1; then
    log_fail "Secret argocd-secret is missing."
    record_failure
    return
  fi

  local cm_yaml secret_yaml
  cm_yaml="$(kubectl -n "${NAMESPACE}" get cm argocd-cm -o yaml)"
  secret_yaml="$(kubectl -n "${NAMESPACE}" get secret argocd-secret -o yaml)"

  printf '%s\n' "${cm_yaml}" | grep "accounts\." || true
  echo

  for user in "${USERS[@]}"; do
    if printf '%s\n' "${cm_yaml}" | grep -Fq "accounts.${user}: login"; then
      log_pass "Local account enabled: ${user}"
    else
      log_fail "Local account missing in argocd-cm: ${user}"
      record_failure
    fi

    if printf '%s\n' "${secret_yaml}" | grep -Fq "accounts.${user}.password:"; then
      log_pass "Password hash key present for ${user}."
    else
      log_fail "Password hash key missing for ${user}."
      record_failure
    fi

    if printf '%s\n' "${secret_yaml}" | grep -Fq "accounts.${user}.passwordMtime:"; then
      log_pass "Password mtime key present for ${user}."
    else
      log_fail "Password mtime key missing for ${user}."
      record_failure
    fi
  done
}

print_lab_summary() {
  print_header "$TEAL" "6. LAB SUMMARY"

  echo -e "${GREEN}Validated components:${NC}"
  echo "  - Kubernetes cluster connectivity"
  echo "  - Argo CD core pods, deployment, and service"
  echo "  - AppProjects: splunk-prod / splunk-dev / splunk-test"
  echo "  - Applications: splunk / splunk-dev / splunk-test"
  echo "  - RBAC policy rules and local-user mappings"
  echo "  - Local users: admin1 / student1 / student2"
  echo "  - Password keys stored in argocd-secret"
  echo
  echo -e "${GREEN}UI access reminder:${NC}"
  echo "  kubectl -n ${NAMESPACE} port-forward svc/argocd-server 8080:443"
  echo "  Open: https://localhost:8080"
  echo
  echo -e "${GREEN}Expected login behavior:${NC}"
  echo "  admin1   -> full access"
  echo "  student1 -> dev/test only"
  echo "  student2 -> dev/test only"
}

final_status() {
  print_header "$MAGENTA" "LAB STATUS RESULT"

  if [[ "${FAILURES}" -eq 0 ]]; then
    log_pass "All validation checks passed."
    exit 0
  else
    log_fail "Validation completed with ${FAILURES} issue(s)."
    exit 1
  fi
}

# ──────────────────────────────────────────────────────────────────────────────
# MAIN
# ──────────────────────────────────────────────────────────────────────────────
print_header "$MAGENTA" "STARTING LAB STATUS VERIFICATION"

preflight_checks
check_argocd_core
check_appprojects
check_applications
check_rbac
check_local_users
print_lab_summary
final_status