#!/usr/bin/env bash
# =============================================================================
# Script: deployment.sh
# Purpose: Install official Argo CD, apply security lab AppProjects, apply RBAC,
#          and deploy Splunk prod/dev/test Applications for the GitOps lab.
#
# Usage:   ./scripts/deployment.sh
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
# PATHS / CONFIGURATION
# ──────────────────────────────────────────────────────────────────────────────
NAMESPACE="argocd"
MANIFESTS_DIR="manifests"
RBAC_DIR="${MANIFESTS_DIR}/rbac"
SECURITYLAB_DIR="${MANIFESTS_DIR}/securitylab"

RBAC_FILE="${RBAC_DIR}/argocd-rbac-cm.yaml"

APPPROJECT_FILES=(
  "${SECURITYLAB_DIR}/argoproject-splunk-prod.yaml"
  "${SECURITYLAB_DIR}/argoproject-splunk-dev.yaml"
  "${SECURITYLAB_DIR}/argoproject-splunk-test.yaml"
)

APPLICATION_FILES=(
  "${MANIFESTS_DIR}/splunk-prod-app.yaml"
  "${MANIFESTS_DIR}/splunk-dev-app.yaml"
  "${MANIFESTS_DIR}/splunk-test-app.yaml"
)

EXPECTED_APP_REPO="https://github.com/tiqsclass6/kubernetes-projects-2026.git"
ARGO_CD_VERSION="v2.12.5"

EXPECTED_PROJECTS=(
  "splunk-prod"
  "splunk-dev"
  "splunk-test"
)

EXPECTED_APPS=(
  "splunk:splunk-prod:splunk-prod"
  "splunk-dev:splunk-dev:splunk-dev"
  "splunk-test:splunk-test:splunk-test"
)

# ──────────────────────────────────────────────────────────────────────────────
# HELPERS
# ──────────────────────────────────────────────────────────────────────────────
check_command_exists() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || log_error "Required command not found in PATH: $cmd"
}

check_file_exists() {
  local path="$1"
  [[ -f "$path" ]] || log_error "Required file not found: $path"
}

check_kubectl_context() {
  local current_ctx=""
  current_ctx="$(kubectl config current-context 2>/dev/null || true)"

  if [[ -z "${current_ctx}" ]]; then
    log_error "kubectl current-context is not set.
Examples:
  aws eks update-kubeconfig --region us-east-1 --name demo
  kubectl config use-context arn:aws:eks:us-east-1:866340886126:cluster/demo"
  fi

  log_info "kubectl current-context: ${current_ctx}"
}

check_cluster_connectivity() {
  log_info "Checking Kubernetes API connectivity..."
  kubectl cluster-info >/dev/null 2>&1 || \
    log_error "kubectl cannot reach the Kubernetes API server for the active context."
  log_info "Kubernetes API is reachable."
}

check_node_readiness() {
  log_info "Checking node availability..."
  kubectl get nodes >/dev/null 2>&1 || \
    log_error "Unable to list cluster nodes."

  local not_ready_count
  not_ready_count="$(kubectl get nodes --no-headers 2>/dev/null | awk '$2 != "Ready" {count++} END {print count+0}')"

  if [[ "${not_ready_count}" -gt 0 ]]; then
    log_warn "One or more nodes are not Ready."
    kubectl get nodes
  else
    log_info "All cluster nodes are reporting Ready."
  fi
}

preflight_checks() {
  print_header "$MAGENTA" "0. PREFLIGHT CHECKS"

  check_command_exists kubectl
  check_command_exists awk
  check_command_exists sed
  check_kubectl_context
  check_cluster_connectivity
  check_node_readiness

  log_info "Preflight checks completed successfully."
}

wait_for_pods_ready() {
  local ns="$1"
  local timeout="${2:-300s}"
  log_info "Waiting for pods in namespace '${ns}' to become Ready (timeout: ${timeout})..."
  kubectl -n "${ns}" wait --for=condition=Ready pod --all --timeout="${timeout}" || \
    log_error "Timeout waiting for pods in '${ns}'."
  log_info "All pods in '${ns}' are Ready."
}

wait_for_applications_to_register() {
  local timeout_seconds="${1:-180}"
  local elapsed=0
  local all_present

  log_info "Waiting for Applications to register in Argo CD..."

  while true; do
    all_present=true
    for item in "${EXPECTED_APPS[@]}"; do
      local app
      app="${item%%:*}"
      if ! kubectl -n "${NAMESPACE}" get application "${app}" >/dev/null 2>&1; then
        all_present=false
        break
      fi
    done

    if [[ "${all_present}" == true ]]; then
      log_info "All expected Applications are registered."
      return 0
    fi

    if (( elapsed >= timeout_seconds )); then
      log_warn "Timed out waiting for Applications to register."
      return 1
    fi

    sleep 5
    elapsed=$((elapsed + 5))
  done
}

wait_for_app_alignment() {
  local timeout_seconds="${1:-240}"
  local elapsed=0
  local all_good

  log_info "Waiting for Applications to become aligned, synced, and healthy..."

  while true; do
    all_good=true

    for item in "${EXPECTED_APPS[@]}"; do
      local app expected_project expected_ns actual_project actual_ns sync_status health_status
      IFS=':' read -r app expected_project expected_ns <<< "${item}"

      actual_project="$(kubectl -n "${NAMESPACE}" get application "${app}" -o jsonpath='{.spec.project}' 2>/dev/null || true)"
      actual_ns="$(kubectl -n "${NAMESPACE}" get application "${app}" -o jsonpath='{.spec.destination.namespace}' 2>/dev/null || true)"
      sync_status="$(kubectl -n "${NAMESPACE}" get application "${app}" -o jsonpath='{.status.sync.status}' 2>/dev/null || true)"
      health_status="$(kubectl -n "${NAMESPACE}" get application "${app}" -o jsonpath='{.status.health.status}' 2>/dev/null || true)"

      if [[ "${actual_project}" != "${expected_project}" || \
            "${actual_ns}" != "${expected_ns}" || \
            "${sync_status}" != "Synced" || \
            "${health_status}" != "Healthy" ]]; then
        all_good=false
        break
      fi
    done

    if [[ "${all_good}" == true ]]; then
      log_info "All Applications are aligned, Synced, and Healthy."
      return 0
    fi

    if (( elapsed >= timeout_seconds )); then
      log_warn "Timed out waiting for full Application alignment."
      return 1
    fi

    sleep 10
    elapsed=$((elapsed + 10))
  done
}

# ──────────────────────────────────────────────────────────────────────────────
# MAIN EXECUTION
# ──────────────────────────────────────────────────────────────────────────────
print_header "$MAGENTA" "STARTING DEPLOYMENT"

preflight_checks

# 1. Validate required files
print_header "$MAGENTA" "1. VALIDATING MANIFEST FILES"
check_file_exists "${RBAC_FILE}"

for f in "${APPPROJECT_FILES[@]}"; do
  check_file_exists "${f}"
  log_info "Found AppProject manifest: $(basename "${f}")"
done

for f in "${APPLICATION_FILES[@]}"; do
  check_file_exists "${f}"
  log_info "Found Application manifest: $(basename "${f}")"
done

# 2. Install official Argo CD
print_header "$MAGENTA" "2. INSTALLING OFFICIAL ARGO CD (${ARGO_CD_VERSION})"
log_info "Creating namespace '${NAMESPACE}' if needed..."
kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

log_info "Applying Argo CD manifests (server-side apply)..."
kubectl apply -n "${NAMESPACE}" \
  -f "https://raw.githubusercontent.com/argoproj/argo-cd/${ARGO_CD_VERSION}/manifests/install.yaml" \
  --server-side --force-conflicts

# 3. Wait for Argo CD core components
print_header "$MAGENTA" "3. WAITING FOR ARGO CD PODS TO BE READY"
wait_for_pods_ready "${NAMESPACE}" "300s"

# 4. Apply security lab AppProjects
print_header "$MAGENTA" "4. APPLYING SECURITY LAB APPPROJECTS"
for f in "${APPPROJECT_FILES[@]}"; do
  log_info "Applying $(basename "${f}")..."
  kubectl apply -f "${f}"
done

log_info "Current Argo CD AppProjects:"
kubectl -n "${NAMESPACE}" get appprojects

# 5. Apply custom RBAC and restart server
print_header "$MAGENTA" "5. APPLYING CUSTOM RBAC & RELOADING SERVER"
log_info "Applying custom RBAC ConfigMap..."
kubectl apply -f "${RBAC_FILE}"

log_info "Restarting argocd-server to apply new RBAC policy..."
kubectl -n "${NAMESPACE}" rollout restart deployment argocd-server
kubectl -n "${NAMESPACE}" rollout status deployment argocd-server --timeout=180s

# 6. Immediate verification
print_header "$TEAL" "6. INITIAL VERIFICATION (PODS, PROJECTS & APPLICATIONS)"
log_info "Pods in namespace ${NAMESPACE}:"
kubectl -n "${NAMESPACE}" get pods -o wide
echo

log_info "Current Argo CD AppProjects:"
kubectl -n "${NAMESPACE}" get appprojects
echo

log_info "Current Argo CD Applications:"
kubectl -n "${NAMESPACE}" get applications -o wide || echo "(none yet)"

# 7. Apply Splunk Applications
print_header "$MAGENTA" "7. APPLYING SPLUNK APPLICATIONS"
log_info "Applying manifests from repo: ${EXPECTED_APP_REPO}"

for f in "${APPLICATION_FILES[@]}"; do
  log_info "Applying $(basename "${f}")..."
  kubectl apply -f "${f}" || log_error "Apply failed: $(basename "${f}")"
done

wait_for_applications_to_register 180 || true
wait_for_app_alignment 240 || true

# 8. Post-deployment verification
print_header "$TEAL" "8. POST-DEPLOYMENT VERIFICATION"

log_info "Checking namespaces created by Argo CD:"
kubectl get ns | grep -E 'argocd|splunk' || log_warn "No lab namespaces detected yet."
echo

for ns in splunk-prod splunk-dev splunk-test; do
  if kubectl get ns "${ns}" >/dev/null 2>&1; then
    log_info "Resources in namespace '${ns}':"
    kubectl -n "${ns}" get all --ignore-not-found
    kubectl -n "${ns}" get pods -o wide --ignore-not-found
    echo
  else
    log_warn "Namespace '${ns}' not yet created."
  fi
done

log_info "Final Argo CD application status:"
kubectl -n "${NAMESPACE}" get applications -o wide || echo "(none visible)"
echo

for item in "${EXPECTED_APPS[@]}"; do
  IFS=':' read -r app expected_project expected_ns <<< "${item}"
  log_info "Detailed status for '${app}':"
  echo "  Project:   $(kubectl -n "${NAMESPACE}" get application "${app}" -o jsonpath='{.spec.project}' 2>/dev/null || echo missing)"
  echo "  Namespace: $(kubectl -n "${NAMESPACE}" get application "${app}" -o jsonpath='{.spec.destination.namespace}' 2>/dev/null || echo missing)"
  echo "  Sync:      $(kubectl -n "${NAMESPACE}" get application "${app}" -o jsonpath='{.status.sync.status}' 2>/dev/null || echo unknown)"
  echo "  Health:    $(kubectl -n "${NAMESPACE}" get application "${app}" -o jsonpath='{.status.health.status}' 2>/dev/null || echo unknown)"
done

# 9. Final instructions
print_header "$MAGENTA" "DEPLOYMENT COMPLETE — NEXT STEPS"
echo -e "${GREEN}1. Retrieve admin password:${NC}"
echo "   kubectl -n ${NAMESPACE} get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 --decode; echo"
echo -e "${GREEN}2. Access the UI:${NC}"
echo "   kubectl -n ${NAMESPACE} port-forward svc/argocd-server 8080:443"
echo "   Open: https://localhost:8080 (accept self-signed certificate warning)"
echo -e "${GREEN}3. Verify AppProjects and Applications:${NC}"
echo "   kubectl -n ${NAMESPACE} get appprojects"
echo "   kubectl -n ${NAMESPACE} get applications -o wide"
echo -e "${GREEN}4. Test RBAC:${NC}"
echo "   Run: ./scripts/users.sh"
echo "   Then log in as admin1 / student1 / student2"
echo -e "${GREEN}5. Full lab validation:${NC}"
echo "   Run: ./scripts/lab-status.sh"
echo -e "${YELLOW}For production usage:${NC} configure TLS, remove port-forward, and consider HA setup."

print_header "$MAGENTA" "SCRIPT FINISHED"