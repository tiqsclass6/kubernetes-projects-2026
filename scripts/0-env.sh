#!/usr/bin/env bash
# =============================================================================
# Script: 0-env.sh
# Purpose: Define shared environment variables for the Project 4 Flux workflow.
#
# Usage:   source ./scripts/0-env.sh
#          ./scripts/0-env.sh
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

export PROJECT_ID="${PROJECT_ID:-class-6-5-tiqs}"
export REGION="${REGION:-us-central1}"
export CLUSTER_NAME="${CLUSTER_NAME:-demo}"
export GOOGLE_APPLICATION_CREDENTIALS="$(pwd)/class-6-5-tiqs-095c33bf9f57.json"

export TF_DIR="${TF_DIR:-./terraform}"
export FLUX_DIR="${FLUX_DIR:-./flux}"
export LAB_GITHUB_DIR="${LAB_GITHUB_DIR:-./flux/lab_github}"

export GIT_PROVIDER="${GIT_PROVIDER:-github}"
export GIT_OWNER="${GIT_OWNER:-tiqsclass6}"
export GIT_REPO="${GIT_REPO:-kubernetes-projects-2026}"
export GIT_BRANCH="${GIT_BRANCH:-project-4}"
export FLUX_PATH="${FLUX_PATH:-clusters/dev}"

export FLUX_NAMESPACE="${FLUX_NAMESPACE:-flux-system}"
export SPLUNK_NAMESPACE="${SPLUNK_NAMESPACE:-splunk-dev}"

export SPLUNK_HOSTNAME="${SPLUNK_HOSTNAME:-splunk-dev.example.com}"
export LETSENCRYPT_EMAIL="${LETSENCRYPT_EMAIL:-daquietstorm22@gmail.com}"

print_header "$MAGENTA" "LOADING PROJECT 4 FLUX ENVIRONMENT"

log_info "PROJECT_ID=${PROJECT_ID}"
log_info "REGION=${REGION}"
log_info "CLUSTER_NAME=${CLUSTER_NAME}"
log_info "TF_DIR=${TF_DIR}"
log_info "FLUX_DIR=${FLUX_DIR}"
log_info "GIT_PROVIDER=${GIT_PROVIDER}"
log_info "GIT_OWNER=${GIT_OWNER}"
log_info "GIT_REPO=${GIT_REPO}"
log_info "GIT_BRANCH=${GIT_BRANCH}"
log_info "FLUX_PATH=${FLUX_PATH}"
log_info "FLUX_NAMESPACE=${FLUX_NAMESPACE}"
log_info "SPLUNK_NAMESPACE=${SPLUNK_NAMESPACE}"
log_info "SPLUNK_HOSTNAME=${SPLUNK_HOSTNAME}"
log_info "LETSENCRYPT_EMAIL=${LETSENCRYPT_EMAIL}"