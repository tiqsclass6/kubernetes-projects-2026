#!/usr/bin/env bash
# =============================================================================
# Script: teardown.sh
# Purpose: Cleanly remove Argo CD, Splunk apps, AppProjects, RBAC,
#          local users, and namespaces so Terraform destroy can run cleanly.
#
# Usage:   ./scripts/teardown.sh
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
log_error() { printf "${RED}[ERROR]${NC} %s\n" "$*" >&2; exit 1; }

# ──────────────────────────────────────────────────────────────────────────────
# CONFIGURATION
# ──────────────────────────────────────────────────────────────────────────────

NAMESPACE="argocd"
ARGO_CD_VERSION="v2.12.5"

APP_NAMES=(
  "splunk"
  "splunk-dev"
  "splunk-test"
)

PROJECTS=(
  "splunk-prod"
  "splunk-dev"
  "splunk-test"
)

APP_NAMESPACES=(
  "splunk-prod"
  "splunk-dev"
  "splunk-test"
)

USERS=(
  "admin1"
  "student1"
  "student2"
)

# ──────────────────────────────────────────────────────────────────────────────
# PREFLIGHT CHECKS
# ──────────────────────────────────────────────────────────────────────────────

check_command_exists() {
  command -v "$1" >/dev/null 2>&1 || log_error "Required command not found: $1"
}

check_cluster() {
  print_header "$MAGENTA" "0. PREFLIGHT CHECKS"

  check_command_exists kubectl

  local ctx
  ctx="$(kubectl config current-context 2>/dev/null || true)"

  [[ -n "$ctx" ]] || log_error "kubectl current-context not set."

  log_info "kubectl current-context: ${ctx}"

  kubectl cluster-info >/dev/null || log_error "Cannot reach cluster API"

  log_info "Cluster connectivity verified."
}

# ──────────────────────────────────────────────────────────────────────────────
# DELETE APPLICATIONS
# ──────────────────────────────────────────────────────────────────────────────

delete_apps() {
  print_header "$MAGENTA" "1. DELETING ARGO CD APPLICATIONS"

  for app in "${APP_NAMES[@]}"; do

    if kubectl -n "${NAMESPACE}" get application "$app" >/dev/null 2>&1; then
      log_info "Deleting application: $app"
      kubectl -n "${NAMESPACE}" delete application "$app" --timeout=120s || true
    else
      log_warn "Application not found: $app"
    fi

  done

  log_info "Waiting for ArgoCD resource pruning..."
  sleep 30
}

# ──────────────────────────────────────────────────────────────────────────────
# DELETE APPPROJECTS
# ──────────────────────────────────────────────────────────────────────────────

delete_projects() {

  print_header "$MAGENTA" "2. DELETING APPPROJECTS"

  for project in "${PROJECTS[@]}"; do

    if kubectl -n "${NAMESPACE}" get appproject "$project" >/dev/null 2>&1; then
      log_info "Deleting AppProject: $project"
      kubectl -n "${NAMESPACE}" delete appproject "$project" || true
    else
      log_warn "AppProject not found: $project"
    fi

  done
}

# ──────────────────────────────────────────────────────────────────────────────
# DELETE SPLUNK NAMESPACES
# ──────────────────────────────────────────────────────────────────────────────

delete_namespaces() {

  print_header "$MAGENTA" "3. DELETING SPLUNK NAMESPACES"

  for ns in "${APP_NAMESPACES[@]}"; do

    if kubectl get ns "$ns" >/dev/null 2>&1; then
      log_info "Deleting namespace: $ns"
      kubectl delete ns "$ns" --timeout=180s || true
    else
      log_warn "Namespace not found: $ns"
    fi

  done
}

# ──────────────────────────────────────────────────────────────────────────────
# REMOVE RBAC + USERS
# ──────────────────────────────────────────────────────────────────────────────

remove_rbac_users() {

  print_header "$MAGENTA" "4. REMOVING RBAC + LOCAL USERS"

  if kubectl -n "${NAMESPACE}" get cm argocd-rbac-cm >/dev/null 2>&1; then
    kubectl -n "${NAMESPACE}" delete cm argocd-rbac-cm || true
    log_info "RBAC ConfigMap removed."
  fi

  if kubectl -n "${NAMESPACE}" get cm argocd-cm >/dev/null 2>&1; then
    log_info "Removing local users from argocd-cm"

    for user in "${USERS[@]}"; do
      kubectl -n "${NAMESPACE}" patch cm argocd-cm \
        --type json \
        -p "[{\"op\":\"remove\",\"path\":\"/data/accounts.${user}\"}]" 2>/dev/null || true
    done
  fi

  if kubectl -n "${NAMESPACE}" get secret argocd-secret >/dev/null 2>&1; then
    log_info "Removing password hashes"

    for user in "${USERS[@]}"; do
      kubectl -n "${NAMESPACE}" patch secret argocd-secret \
        --type json \
        -p "[{\"op\":\"remove\",\"path\":\"/data/accounts.${user}.password\"}]" 2>/dev/null || true

      kubectl -n "${NAMESPACE}" patch secret argocd-secret \
        --type json \
        -p "[{\"op\":\"remove\",\"path\":\"/data/accounts.${user}.passwordMtime\"}]" 2>/dev/null || true
    done
  fi

}

# ──────────────────────────────────────────────────────────────────────────────
# REMOVE ARGOCD INSTALL
# ──────────────────────────────────────────────────────────────────────────────

remove_argocd() {

  print_header "$MAGENTA" "5. REMOVING ARGO CD INSTALLATION"

  if kubectl get ns "${NAMESPACE}" >/dev/null 2>&1; then

    kubectl delete -n "${NAMESPACE}" \
      -f https://raw.githubusercontent.com/argoproj/argo-cd/${ARGO_CD_VERSION}/manifests/install.yaml \
      --ignore-not-found=true || true

    log_info "ArgoCD install manifest removed."

  else
    log_warn "argocd namespace missing."
  fi

}

# ──────────────────────────────────────────────────────────────────────────────
# DELETE ARGOCD NAMESPACE
# ──────────────────────────────────────────────────────────────────────────────

delete_argocd_ns() {

  print_header "$MAGENTA" "6. DELETING ARGO CD NAMESPACE"

  kubectl delete ns "${NAMESPACE}" --ignore-not-found=true || true

}

# ──────────────────────────────────────────────────────────────────────────────
# FINAL CHECK
# ──────────────────────────────────────────────────────────────────────────────

final_check() {

  print_header "$TEAL" "7. FINAL VERIFICATION"

  kubectl get ns | grep -E "argocd|splunk" && \
    log_warn "Some namespaces still exist." || \
    log_info "All lab namespaces removed."

  kubectl get applications -A 2>/dev/null || \
    log_info "No ArgoCD Applications remain."

}

# ──────────────────────────────────────────────────────────────────────────────
# MAIN
# ──────────────────────────────────────────────────────────────────────────────

print_header "$MAGENTA" "STARTING LAB TEARDOWN"

check_cluster
delete_apps
delete_projects
delete_namespaces
remove_rbac_users
remove_argocd
delete_argocd_ns
final_check

print_header "$MAGENTA" "TEARDOWN COMPLETE"

echo -e "${GREEN}Cluster-side GitOps resources removed.${NC}"
echo "Next step:"
echo "  terraform destroy"
echo
echo -e "${YELLOW}If a namespace is stuck in Terminating, check finalizers.${NC}"