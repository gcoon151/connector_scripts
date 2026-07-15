#!/usr/bin/env bash
# =============================================================================
# satellite-connector-agent-vulns.sh
#
# Displays IBM Vulnerability Advisor reports for the two satellite-connector-agent
# images used by IBM Cloud Satellite Connector customers.
#
# IMAGES
# -------
# 1. us.icr.io/armada-master/satellite-connector-agent:<TAG>
#    - Unauthenticated pull (public)
#    - Registry region : us-south  (us.icr.io)
#    - VA query method : ibmcloud cr va  OR  curl VA API
#
# 2. icr.io/ibm/satellite-connector/satellite-connector-agent:<TAG>
#    - Requires ICR credentials to pull
#    - Registry region : global  (icr.io)
#    - VA query method : ibmcloud cr va  OR  curl VA API
#
# PREREQUISITES
# -------------
#   ibmcloud CLI  – https://cloud.ibm.com/docs/cli?topic=cli-install-ibmcloud-cli
#   ibmcloud cr   – container-registry plugin (install: ibmcloud plugin install container-registry)
#   jq            – https://stedolan.github.io/jq/  (for --curl mode only)
#   An active ibmcloud login  (ibmcloud login --sso  or  ibmcloud login -u ... )
#
# USAGE
# -----
#   ./satellite-connector-agent-vulns.sh [OPTIONS]
#
# OPTIONS
#   -t, --tag TAG         Image tag to scan (default: latest)
#   -m, --method METHOD   'cli' (default) or 'curl'
#                           cli  – uses 'ibmcloud cr vulnerability-assessment'
#                           curl – uses the VA REST API directly
#   -e, --extended        Show extended fix details (cli method only)
#   -j, --json            Output raw JSON (cli method only, implies no colour)
#   -h, --help            Show this help
#
# EXAMPLES
#   # Scan latest tag with default cli method
#   ./satellite-connector-agent-vulns.sh
#
#   # Scan a specific tag
#   ./satellite-connector-agent-vulns.sh --tag v1.2.7
#
#   # Use curl-based VA API and output JSON
#   ./satellite-connector-agent-vulns.sh --tag v1.2.7 --method curl
#
#   # Show extended fix info
#   ./satellite-connector-agent-vulns.sh --extended
#
# =============================================================================

set -euo pipefail

# ---------- defaults ---------------------------------------------------------
TAG="latest"
METHOD="cli"
EXTENDED=""
JSON_OUT=""

# ---------- helpers ----------------------------------------------------------
usage() {
  sed -n '/^# USAGE/,/^# =====/p' "$0" | sed 's/^# \{0,2\}//' | sed '/^===*/d'
  exit 0
}

err() { echo "ERROR: $*" >&2; exit 1; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || err "'$1' is not installed or not in PATH"
}

check_ibmcloud() {
  if ! command -v ibmcloud >/dev/null 2>&1; then
    echo ""
    echo "ERROR: 'ibmcloud' CLI is not installed or not in PATH." >&2
    echo ""                                                        >&2
    echo "  Install it from:"                                      >&2
    echo "  https://cloud.ibm.com/docs/cli?topic=cli-install-ibmcloud-cli" >&2
    echo ""                                                        >&2
    exit 1
  fi
}

check_login() {
  # 'ibmcloud cr info' makes a live API call to the registry — if the session
  # token is expired or missing it returns a non-zero exit code with a clear
  # "Not logged in" / "token expired" message. It is much more reliable than
  # 'ibmcloud target', which can succeed even with a stale token.
  if ! ibmcloud cr info >/dev/null 2>&1; then
    echo ""
    echo "ERROR: Not logged in to IBM Cloud, or the session has expired." >&2
    echo ""                                                                >&2
    echo "  Log in with one of:"                                           >&2
    echo "    ibmcloud login --sso          # federated / SSO accounts"   >&2
    echo "    ibmcloud login -u <EMAIL>     # standard accounts"          >&2
    echo ""                                                                >&2
    exit 1
  fi
}

# ---------- arg parsing ------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    -t|--tag)      TAG="$2";     shift 2 ;;
    -m|--method)   METHOD="$2";  shift 2 ;;
    -e|--extended) EXTENDED="--extended"; shift ;;
    -j|--json)     JSON_OUT="--output json"; shift ;;
    -h|--help)     usage ;;
    *) err "Unknown option: $1. Use --help for usage." ;;
  esac
done

[[ "$METHOD" == "cli" || "$METHOD" == "curl" ]] || \
  err "Invalid method '$METHOD'. Choose 'cli' or 'curl'."

# ---------- prereqs ----------------------------------------------------------
check_ibmcloud
[[ "$METHOD" == "curl" ]] && require_cmd jq
check_login

# ---------- image definitions ------------------------------------------------
# Each entry: "<display_name>|<registry_host>|<full_image_ref>|<cr_region>"
declare -a IMAGES=(
  "Public (unauthenticated pull)|us.icr.io|us.icr.io/armada-master/satellite-connector-agent:${TAG}|us-south"
  "IBM Cloud (ICR auth required)|icr.io|icr.io/ibm/satellite-connector/satellite-connector-agent:${TAG}|global"
)

# ---------- separator --------------------------------------------------------
sep() { printf '\n%s\n' "$(printf '=%.0s' {1..72})"; }

# =============================================================================
# METHOD: ibmcloud cr vulnerability-assessment
# =============================================================================
scan_cli() {
  local display="$1"
  local registry_host="$2"
  local image="$3"
  local region="$4"

  sep
  echo "IMAGE : $image"
  echo "METHOD: ibmcloud cr vulnerability-assessment"
  echo ""

  # Switch to the correct CR region for this registry
  ibmcloud cr region-set "$region" >/dev/null 2>&1

  # shellcheck disable=SC2086
  ibmcloud cr vulnerability-assessment "$image" $EXTENDED $JSON_OUT
}

# =============================================================================
# METHOD: curl VA API
# https://us.icr.io/va/api/v4/report/image/<image>
# https://icr.io/va/api/v4/report/image/<image>
# =============================================================================
scan_curl() {
  local display="$1"
  local registry_host="$2"
  local image="$3"

  sep
  echo "IMAGE : $image"
  echo "METHOD: curl VA API (Scan-Engines: ibm_va)"
  echo ""

  local token
  token=$(ibmcloud iam oauth-tokens --output json | jq -r .iam_token)

  local va_url="https://${registry_host}/va/api/v4/report/image/${image}"
  local response
  response=$(curl -s \
    -H "Scan-Engines: ibm_va" \
    -H "Authorization: ${token}" \
    "$va_url")

  # Sanity-check: valid JSON?
  echo "$response" | jq . >/dev/null 2>&1 || {
    echo "Unexpected response from VA API:"
    echo "$response"
    return 1
  }

  # Pretty summary
  local status vuln_count cfg_count scan_date os_dist
  status=$(echo "$response"     | jq -r '.status // "UNKNOWN"')
  vuln_count=$(echo "$response" | jq    '[.vulnerabilities // [] | length] | .[0]')
  cfg_count=$(echo "$response"  | jq    '[.configuration_issues // [] | length] | .[0]')
  scan_date=$(echo "$response"  | jq -r '.scan_time // "unknown"' | \
    xargs -I{} date -r {} "+%Y-%m-%d %H:%M:%S UTC" 2>/dev/null || echo "unknown")
  os_dist=$(echo "$response"    | jq -r '(.os_distribution.distribution_id // "")
    + " " + (.os_distribution.version_id // "")' | xargs)

  echo "Status          : $status"
  echo "Scan time       : $scan_date"
  [[ -n "$os_dist" ]] && echo "OS distribution : $os_dist"
  echo "Vulnerabilities : $vuln_count"
  echo "Config issues   : $cfg_count"

  if [[ "$vuln_count" -gt 0 ]]; then
    echo ""
    echo "Vulnerability breakdown:"
    echo "$response" | jq -r '
      .vulnerabilities[] |
      "  \(.cve_id)  |  \(.security_notices[0].vulnerable_packages[0].package_name)  |  fix: \(.security_notices[0].vulnerable_packages[0].corrective_action)"
    '
  fi

  if [[ "$cfg_count" -gt 0 ]]; then
    echo ""
    echo "Configuration issues:"
    echo "$response" | jq -r '
      .configuration_issues[] |
      "  \(.id)  \(.description)"
    '
  fi
}

# =============================================================================
# MAIN
# =============================================================================
echo ""
echo "Satellite Connector Agent — Vulnerability Assessment"
echo "Tag: ${TAG}"
echo "Method: ${METHOD}"

for entry in "${IMAGES[@]}"; do
  IFS='|' read -r display registry_host image region <<< "$entry"

  echo ""
  echo ">>> Scanning: $display"

  if [[ "$METHOD" == "cli" ]]; then
    scan_cli "$display" "$registry_host" "$image" "$region"
  else
    scan_curl "$display" "$registry_host" "$image"
  fi
done

sep
echo ""
echo "Done."
