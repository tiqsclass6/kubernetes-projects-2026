#!/usr/bin/env bash
# =============================================================================
# Script: 5-run-tests.sh
# Purpose: Run the two required negative tests and confirm Gatekeeper denies
#          invalid namespace and port combinations.
#
# Usage:   ./scripts/5-run-tests.sh
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

CHEAT_NS_FILE="${HOMEWORK_DIR}/40-cheat-prod-to-dev.yaml"
CHEAT_PORT_FILE="${HOMEWORK_DIR}/41-cheat-prod-service-wrong-port.yaml"

run_expected_denial() {
  local label="$1"
  local file="$2"

  print_header "$MAGENTA" "${label}"

  [[ -f "${file}" ]] || log_error "Required file not found: ${file}"

  set +e
  OUTPUT="$(kubectl apply -f "${file}" 2>&1)"
  RC=$?
  set -e

  echo "${OUTPUT}"
  echo

  if [[ ${RC} -ne 0 ]] && echo "${OUTPUT}" | grep -qiE "denied|forbidden|violation|admission webhook"; then
    log_info "Expected denial confirmed for $(basename "${file}")"
  else
    log_error "Test did not fail the way Gatekeeper enforcement expects: $(basename "${file}")"
  fi
}

print_header "$MAGENTA" "RUNNING GATEKEEPER NEGATIVE TESTS"

run_expected_denial "1. TEST INVALID PROD APP TARGETING DEV NAMESPACE" "${CHEAT_NS_FILE}"
run_expected_denial "2. TEST INVALID PROD SERVICE PORT" "${CHEAT_PORT_FILE}"

print_header "$MAGENTA" "NEGATIVE TESTS COMPLETE"
log_info "Both Gatekeeper deny-path tests behaved as expected."