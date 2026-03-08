#!/usr/bin/env bash
# =============================================================================
# Script: 3-apply-policies.sh
# Purpose: Apply namespaces, Gatekeeper constraint templates, and constraints
#          for the Splunk namespace and service-port enforcement lab.
#
# Usage:   ./scripts/3-apply-policies.sh
# =============================================================================

set -euo pipefail
IFS=$'\n\t'

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

HOMEWORK_DIR="${HOMEWORK_DIR:-homework}"

NS_FILE="${HOMEWORK_DIR}/00-namespaces.yaml"
ARGO_TEMPLATE="${HOMEWORK_DIR}/10-template-argo-app-env-namespace.yaml"
ARGO_CONSTRAINT="${HOMEWORK_DIR}/11-constraint-argo-app-env-namespace.yaml"
PORT_TEMPLATE="${HOMEWORK_DIR}/20-template-splunk-service-port-by-env.yaml"
PORT_CONSTRAINT="${HOMEWORK_DIR}/21-constraint-splunk-service-port-by-env.yaml"

print_header "$MAGENTA" "APPLYING GATEKEEPER POLICIES"

for f in "$NS_FILE" "$ARGO_TEMPLATE" "$ARGO_CONSTRAINT" "$PORT_TEMPLATE" "$PORT_CONSTRAINT"; do
  [[ -f "$f" ]] || log_error "Required file not found: $f"
done

print_header "$MAGENTA" "1. APPLY NAMESPACES"
kubectl apply -f "${NS_FILE}"

print_header "$MAGENTA" "2. APPLY ARGO APP ENV / NAMESPACE TEMPLATE"
kubectl apply -f "${ARGO_TEMPLATE}"

print_header "$MAGENTA" "3. APPLY ARGO APP ENV / NAMESPACE CONSTRAINT"
kubectl apply -f "${ARGO_CONSTRAINT}"

print_header "$MAGENTA" "4. APPLY SPLUNK SERVICE PORT TEMPLATE"
kubectl apply -f "${PORT_TEMPLATE}"

print_header "$MAGENTA" "5. APPLY SPLUNK SERVICE PORT CONSTRAINT"
kubectl apply -f "${PORT_CONSTRAINT}"

print_header "$TEAL" "6. VALIDATE POLICIES"
kubectl get ns --show-labels | grep splunk || true
echo
kubectl get constrainttemplates | egrep "k8sargoappenvironment|k8sserviceportbyenv" || \
  log_error "Expected constraint templates not found."
echo
kubectl get constraints | egrep "argo-app-env-namespace-lock|splunk-service-port-lock" || \
  log_error "Expected constraints not found."

print_header "$MAGENTA" "POLICY APPLICATION COMPLETE"
log_info "Namespaces, templates, and constraints are active."