#!/usr/bin/env bash
# =============================================================================
# Script: rbac.sh
#
# Purpose: Deploy Argo CD AppProjects for the security lab and apply RBAC
#          policies using argocd-rbac-cm.yaml.
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
# Configuration
# ──────────────────────────────────────────────────────────────────────────────
NAMESPACE="argocd"

SECURITY_DIR="manifests/securitylab"
RBAC_DIR="manifests/rbac"

RBAC_FILE="${RBAC_DIR}/argocd-rbac-cm.yaml"

PROD_PROJECT="${SECURITY_DIR}/argoproject-splunk-prod.yaml"
DEV_PROJECT="${SECURITY_DIR}/argoproject-splunk-dev.yaml"
TEST_PROJECT="${SECURITY_DIR}/argoproject-splunk-test.yaml"

# ──────────────────────────────────────────────────────────────────────────────
# Preflight checks
# ──────────────────────────────────────────────────────────────────────────────

check_command_exists() {
  command -v "$1" >/dev/null 2>&1 || log_error "Missing required command: $1"
}

check_kubectl_context() {
  local ctx
  ctx="$(kubectl config current-context 2>/dev/null || true)"
  [[ -z "$ctx" ]] && log_error "kubectl context not set."
  log_info "Using kubectl context: $ctx"
}

check_cluster_connectivity() {
  kubectl cluster-info >/dev/null 2>&1 || \
  log_error "Cannot reach Kubernetes API server."
  log_info "Cluster connectivity verified."
}

preflight() {
  print_header "$MAGENTA" "0. PREFLIGHT CHECKS"

  check_command_exists kubectl
  check_kubectl_context
  check_cluster_connectivity

  [[ -f "$PROD_PROJECT" ]] || log_error "Missing $PROD_PROJECT"
  [[ -f "$DEV_PROJECT" ]] || log_error "Missing $DEV_PROJECT"
  [[ -f "$TEST_PROJECT" ]] || log_error "Missing $TEST_PROJECT"
  [[ -f "$RBAC_FILE" ]] || log_error "Missing $RBAC_FILE"

  log_info "All required files located."
}

# ──────────────────────────────────────────────────────────────────────────────
# Deploy AppProjects
# ──────────────────────────────────────────────────────────────────────────────

deploy_appprojects() {

  print_header "$MAGENTA" "1. DEPLOYING SECURITY LAB APPPROJECTS"

  log_info "Applying Splunk PROD project..."
  kubectl apply -f "$PROD_PROJECT"

  log_info "Applying Splunk DEV project..."
  kubectl apply -f "$DEV_PROJECT"

  log_info "Applying Splunk TEST project..."
  kubectl apply -f "$TEST_PROJECT"

}

verify_projects() {

  print_header "$TEAL" "2. VERIFYING ARGO CD PROJECTS"

  kubectl -n "$NAMESPACE" get appprojects

}

# ──────────────────────────────────────────────────────────────────────────────
# Apply RBAC
# ──────────────────────────────────────────────────────────────────────────────

apply_rbac() {

  print_header "$MAGENTA" "3. APPLYING ARGO CD RBAC POLICY"

  log_info "Applying RBAC ConfigMap..."
  kubectl apply -f "$RBAC_FILE"

  log_info "Restarting argocd-server..."
  kubectl -n "$NAMESPACE" rollout restart deployment argocd-server

  log_info "Waiting for argocd-server rollout..."
  kubectl -n "$NAMESPACE" rollout status deployment argocd-server --timeout=180s

}

verify_rbac() {

  print_header "$TEAL" "4. VERIFYING RBAC CONFIGMAP"

  kubectl -n "$NAMESPACE" get cm argocd-rbac-cm -o yaml | sed -n '1,200p'

}

verify_apps() {

  print_header "$MAGENTA" "5. VERIFYING APPLICATION ALIGNMENT"

  log_info "Applications and their projects:"
  kubectl -n "$NAMESPACE" get applications -o wide

}

lab_summary() {

  print_header "$TEAL" "6. LAB RBAC SUMMARY"

  echo -e "${GREEN}RBAC MODEL${NC}"
  echo "Admins group:"
  echo "  → Full Argo CD control"
  echo
  echo "Students group:"
  echo "  → Access to splunk-dev/*"
  echo "  → Access to splunk-test/*"
  echo "  → No access to splunk-prod/*"
  echo
  echo -e "${GREEN}Verification commands:${NC}"
  echo "kubectl -n argocd get appprojects"
  echo "kubectl -n argocd get applications -o wide"
  echo "kubectl -n argocd get cm argocd-rbac-cm -o yaml"
}

# ──────────────────────────────────────────────────────────────────────────────
# MAIN
# ──────────────────────────────────────────────────────────────────────────────

print_header "$MAGENTA" "STARTING SECURITY LAB RBAC SETUP"

preflight
deploy_appprojects
verify_projects
apply_rbac
verify_rbac
verify_apps
lab_summary

print_header "$MAGENTA" "RBAC LAB COMPLETE"