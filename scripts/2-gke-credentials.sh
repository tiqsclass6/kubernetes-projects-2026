#!/usr/bin/env bash
# =============================================================================
# Script: 2-gke-credentials.sh
# Purpose: Authenticate to the target GCP project, ensure the current public
#          IPv4 is allowed in GKE master authorized networks, detect whether
#          the cluster is zonal or regional, fetch kubeconfig, and validate
#          cluster access.
#
# Usage:   ./scripts/2-gke-credentials.sh
# =============================================================================

set -euo pipefail

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

source "$(dirname "$0")/0-env.sh" >/dev/null

command -v gcloud >/dev/null 2>&1 || log_error "gcloud not found."
command -v kubectl >/dev/null 2>&1 || log_error "kubectl not found."
command -v curl >/dev/null 2>&1 || log_error "curl not found."
command -v gke-gcloud-auth-plugin >/dev/null 2>&1 || \
command -v gke-gcloud-auth-plugin.exe >/dev/null 2>&1 || \
  log_error "gke-gcloud-auth-plugin not found. Run: gcloud components install gke-gcloud-auth-plugin"

print_header "$MAGENTA" "1. SET ACTIVE GCP PROJECT"
gcloud config set project "${PROJECT_ID}"

print_header "$MAGENTA" "2. DETECT CURRENT PUBLIC IPV4"
CURRENT_IPV4="$(curl -4 -s ifconfig.me | tr -d '\r\n')"
[[ -n "${CURRENT_IPV4}" ]] || log_error "Failed to detect current public IPv4 address."

CURRENT_CIDR="${CURRENT_IPV4}/32"
log_info "Detected current public IPv4: ${CURRENT_IPV4}"

print_header "$MAGENTA" "3. DISCOVER CLUSTER LOCATION MODE"

CLUSTER_LOCATION="$(gcloud container clusters list \
  --project "${PROJECT_ID}" \
  --format="value(name,location)" | awk -v cluster="${CLUSTER_NAME}" '$1 == cluster {print $2; exit}')"

[[ -n "${CLUSTER_LOCATION}" ]] || log_error "Cluster ${CLUSTER_NAME} not found in project ${PROJECT_ID}."

if [[ "${CLUSTER_LOCATION}" =~ ^[a-z0-9-]+-[a-z]$ ]]; then
  CLUSTER_LOCATION_TYPE="zone"
  LOCATION_FLAG="--zone"
else
  CLUSTER_LOCATION_TYPE="region"
  LOCATION_FLAG="--region"
fi

log_info "Cluster name: ${CLUSTER_NAME}"
log_info "Cluster location: ${CLUSTER_LOCATION}"
log_info "Cluster location type: ${CLUSTER_LOCATION_TYPE}"

print_header "$MAGENTA" "4. SYNC MASTER AUTHORIZED NETWORKS"

EXISTING_CIDRS_RAW="$(gcloud container clusters describe "${CLUSTER_NAME}" \
  "${LOCATION_FLAG}" "${CLUSTER_LOCATION}" \
  --project "${PROJECT_ID}" \
  --format="value(masterAuthorizedNetworksConfig.cidrBlocks[].cidrBlock)")" || \
  log_error "Unable to describe cluster ${CLUSTER_NAME}. Verify cluster state and access."

EXISTING_CIDRS="$(printf '%s' "${EXISTING_CIDRS_RAW}" | tr ';' '\n' | sed '/^[[:space:]]*$/d')"

if printf '%s\n' "${EXISTING_CIDRS}" | grep -Fxq "${CURRENT_CIDR}"; then
  log_info "Current IPv4 already allowed in master authorized networks: ${CURRENT_CIDR}"
else
  log_warn "Current IPv4 not present in master authorized networks."
  log_info "Adding ${CURRENT_CIDR} to the allowed CIDR list."

  UPDATED_CIDRS="$(printf '%s\n%s\n' "${EXISTING_CIDRS}" "${CURRENT_CIDR}" | sed '/^[[:space:]]*$/d' | awk '!seen[$0]++')"
  UPDATED_CIDRS_CSV="$(printf '%s\n' "${UPDATED_CIDRS}" | paste -sd',' -)"

  [[ -n "${UPDATED_CIDRS_CSV}" ]] || log_error "Computed authorized CIDR list is empty."

  gcloud container clusters update "${CLUSTER_NAME}" \
    "${LOCATION_FLAG}" "${CLUSTER_LOCATION}" \
    --project "${PROJECT_ID}" \
    --enable-master-authorized-networks \
    --master-authorized-networks "${UPDATED_CIDRS_CSV}"

  log_info "Master authorized networks updated."
  log_info "Authorized CIDRs: ${UPDATED_CIDRS_CSV}"
fi

print_header "$MAGENTA" "5. FETCH GKE CREDENTIALS"
gcloud container clusters get-credentials "${CLUSTER_NAME}" \
  "${LOCATION_FLAG}" "${CLUSTER_LOCATION}" \
  --project "${PROJECT_ID}"

print_header "$TEAL" "6. VALIDATE CLUSTER ACCESS"
if kubectl cluster-info; then
  echo
  kubectl get nodes -o wide
else
  log_error "kubectl could not reach the GKE API endpoint even after updating master authorized networks."
fi

print_header "$MAGENTA" "GKE CREDENTIALS CONFIGURED"
log_info "kubectl is configured for cluster ${CLUSTER_NAME}."
log_info "Cluster location type: ${CLUSTER_LOCATION_TYPE}"
log_info "Cluster location: ${CLUSTER_LOCATION}"
log_info "Current public IPv4 authorized: ${CURRENT_CIDR}"
log_info "Next step: ./scripts/3-install-flux.sh"