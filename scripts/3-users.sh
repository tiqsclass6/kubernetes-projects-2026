#!/usr/bin/env bash
# =============================================================================
# Script: users.sh
# Purpose: Create local Argo CD users, map them to RBAC roles, set bcrypt
#          password hashes in argocd-secret, restart Argo CD, and verify config.
#
# Usage:   ./scripts/users.sh
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

ADMIN_USER="admin1"
STUDENT1="student1"
STUDENT2="student2"

# ──────────────────────────────────────────────────────────────────────────────
# PREFLIGHT CHECKS
# ──────────────────────────────────────────────────────────────────────────────
check_command_exists() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || log_error "Required command not found in PATH: $cmd"
}

check_cluster() {
  print_header "$MAGENTA" "0. PREFLIGHT CHECKS"

  check_command_exists kubectl
  check_command_exists argocd
  check_command_exists sed
  check_command_exists grep
  check_command_exists mktemp
  check_command_exists date

  kubectl cluster-info >/dev/null 2>&1 || \
    log_error "Cannot reach Kubernetes cluster."

  kubectl -n "${NAMESPACE}" get deploy argocd-server >/dev/null 2>&1 || \
    log_error "Argo CD deployment 'argocd-server' not found."

  kubectl -n "${NAMESPACE}" get cm argocd-cm >/dev/null 2>&1 || \
    log_error "ConfigMap 'argocd-cm' not found."

  kubectl -n "${NAMESPACE}" get cm argocd-rbac-cm >/dev/null 2>&1 || \
    log_error "ConfigMap 'argocd-rbac-cm' not found."

  kubectl -n "${NAMESPACE}" get secret argocd-secret >/dev/null 2>&1 || \
    log_error "Secret 'argocd-secret' not found."

  log_info "Cluster connectivity verified."
}

# ──────────────────────────────────────────────────────────────────────────────
# ENABLE LOCAL USERS
# ──────────────────────────────────────────────────────────────────────────────
create_users() {
  print_header "$MAGENTA" "1. CREATING LOCAL ARGO CD USERS"

  log_info "Adding admin and student accounts to argocd-cm..."

  kubectl -n "${NAMESPACE}" patch configmap argocd-cm \
    --type merge \
    -p "{
      \"data\": {
        \"accounts.${ADMIN_USER}\": \"login\",
        \"accounts.${STUDENT1}\": \"login\",
        \"accounts.${STUDENT2}\": \"login\"
      }
    }"

  log_info "Local users enabled in argocd-cm."
}

# ──────────────────────────────────────────────────────────────────────────────
# MAP USERS TO ROLES
# ──────────────────────────────────────────────────────────────────────────────
configure_rbac_mapping() {
  print_header "$MAGENTA" "2. MAPPING USERS TO RBAC ROLES"

  local tmp_file
  local current_policy
  local policy_default
  local policy_match_mode

  tmp_file="$(mktemp)"
  current_policy="$(kubectl -n "${NAMESPACE}" get cm argocd-rbac-cm -o jsonpath='{.data.policy\.csv}')"
  policy_default="$(kubectl -n "${NAMESPACE}" get cm argocd-rbac-cm -o jsonpath='{.data.policy\.default}')"
  policy_match_mode="$(kubectl -n "${NAMESPACE}" get cm argocd-rbac-cm -o jsonpath='{.data.policy\.matchMode}')"

  [[ -n "${policy_default}" ]] || policy_default="role:readonly"
  [[ -n "${policy_match_mode}" ]] || policy_match_mode="glob"

  [[ "${current_policy}" == *"g, ${ADMIN_USER}, role:admin"* ]] || \
    current_policy="${current_policy}"$'\n'"g, ${ADMIN_USER}, role:admin"

  [[ "${current_policy}" == *"g, ${STUDENT1}, role:devtest-operator"* ]] || \
    current_policy="${current_policy}"$'\n'"g, ${STUDENT1}, role:devtest-operator"

  [[ "${current_policy}" == *"g, ${STUDENT2}, role:devtest-operator"* ]] || \
    current_policy="${current_policy}"$'\n'"g, ${STUDENT2}, role:devtest-operator"

  cat > "${tmp_file}" <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-rbac-cm
  namespace: ${NAMESPACE}
data:
  policy.csv: |
$(printf '%s\n' "${current_policy}" | sed 's/^/    /')
  policy.default: ${policy_default}
  policy.matchMode: ${policy_match_mode}
EOF

  kubectl apply -f "${tmp_file}"
  rm -f "${tmp_file}"

  log_info "Users mapped to RBAC roles."
}

# ──────────────────────────────────────────────────────────────────────────────
# SET PASSWORD HASHES
# ──────────────────────────────────────────────────────────────────────────────
prompt_for_password() {
  local user_label="$1"
  local pass1=""
  local pass2=""

  while true; do
    read -rsp "Enter password for ${user_label}: " pass1
    echo
    read -rsp "Confirm password for ${user_label}: " pass2
    echo

    [[ -n "${pass1}" ]] || { log_warn "Password cannot be empty."; continue; }
    [[ "${pass1}" == "${pass2}" ]] || { log_warn "Passwords do not match for ${user_label}. Try again."; continue; }

    printf '%s' "${pass1}"
    return 0
  done
}

set_password_hashes() {
  print_header "$MAGENTA" "3. SETTING LOCAL USER PASSWORD HASHES"

  local now admin_pass student1_pass student2_pass
  local admin_hash student1_hash student2_hash

  now="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

  admin_pass="$(prompt_for_password "${ADMIN_USER}")"
  student1_pass="$(prompt_for_password "${STUDENT1}")"
  student2_pass="$(prompt_for_password "${STUDENT2}")"

  log_info "Generating bcrypt hashes with Argo CD CLI..."
  admin_hash="$(argocd account bcrypt --password "${admin_pass}")"
  student1_hash="$(argocd account bcrypt --password "${student1_pass}")"
  student2_hash="$(argocd account bcrypt --password "${student2_pass}")"

  log_info "Patching argocd-secret with local account password hashes..."
  kubectl -n "${NAMESPACE}" patch secret argocd-secret \
    --type merge \
    -p "{
      \"stringData\": {
        \"accounts.${ADMIN_USER}.password\": \"${admin_hash}\",
        \"accounts.${ADMIN_USER}.passwordMtime\": \"${now}\",
        \"accounts.${STUDENT1}.password\": \"${student1_hash}\",
        \"accounts.${STUDENT1}.passwordMtime\": \"${now}\",
        \"accounts.${STUDENT2}.password\": \"${student2_hash}\",
        \"accounts.${STUDENT2}.passwordMtime\": \"${now}\"
      }
    }"

  unset admin_pass student1_pass student2_pass
  log_info "Password hashes written to argocd-secret."
}

# ──────────────────────────────────────────────────────────────────────────────
# RESTART ARGO CD
# ──────────────────────────────────────────────────────────────────────────────
restart_argocd() {
  print_header "$MAGENTA" "4. RESTARTING ARGO CD"

  kubectl -n "${NAMESPACE}" rollout restart deployment argocd-server
  kubectl -n "${NAMESPACE}" rollout status deployment argocd-server --timeout=180s

  log_info "Argo CD restarted successfully."
}

# ──────────────────────────────────────────────────────────────────────────────
# VERIFY CONFIGURATION
# ──────────────────────────────────────────────────────────────────────────────
verify_users() {
  print_header "$TEAL" "5. VERIFYING USERS"

  log_info "Configured local accounts:"
  kubectl -n "${NAMESPACE}" get cm argocd-cm -o yaml | grep "accounts\." || true
  echo

  log_info "RBAC policy:"
  kubectl -n "${NAMESPACE}" get cm argocd-rbac-cm -o yaml | sed -n '1,220p'
  echo

  log_info "Password keys present in argocd-secret:"
  kubectl -n "${NAMESPACE}" get secret argocd-secret -o yaml | \
    grep -E "accounts\.(admin1|student1|student2)\.(password|passwordMtime):" || true
}

# ──────────────────────────────────────────────────────────────────────────────
# LOGIN INSTRUCTIONS
# ──────────────────────────────────────────────────────────────────────────────
print_login_info() {
  print_header "$TEAL" "6. LOGIN TESTING"

  echo -e "${GREEN}Argo CD UI:${NC}"
  echo "  https://localhost:8080"
  echo
  echo -e "${GREEN}Test accounts:${NC}"
  echo "  ${ADMIN_USER}   -> role:admin"
  echo "  ${STUDENT1} -> role:devtest-operator"
  echo "  ${STUDENT2} -> role:devtest-operator"
  echo
  echo -e "${GREEN}Expected permissions:${NC}"
  echo "  ${ADMIN_USER}   -> full access to prod, dev, and test"
  echo "  ${STUDENT1} -> access to splunk-dev and splunk-test only"
  echo "  ${STUDENT2} -> access to splunk-dev and splunk-test only"
  echo "  ${STUDENT1}/${STUDENT2} -> denied access to splunk-prod sync/update/actions"
  echo
  echo -e "${YELLOW}Reminder:${NC}"
  echo "  Keep this running in another terminal when using the UI:"
  echo "  kubectl -n ${NAMESPACE} port-forward svc/argocd-server 8080:443"
}

# ──────────────────────────────────────────────────────────────────────────────
# MAIN
# ──────────────────────────────────────────────────────────────────────────────
print_header "$MAGENTA" "CREATING ARGO CD LAB USERS"

check_cluster
create_users
configure_rbac_mapping
set_password_hashes
restart_argocd
verify_users
print_login_info

print_header "$MAGENTA" "USER SETUP COMPLETE"