# Satellite Connector Agent — Vulnerability Scanning

This folder contains a script that queries the IBM Vulnerability Advisor (VA) scan results for both `satellite-connector-agent` images used by IBM Cloud Satellite Connector customers.

## Images

| Image | Registry | Pull auth |
|-------|----------|-----------|
| `us.icr.io/armada-master/satellite-connector-agent:<TAG>` | us.icr.io (us-south) | Public — no auth required |
| `icr.io/ibm/satellite-connector/satellite-connector-agent:<TAG>` | icr.io (global) | IBM Cloud CR credentials required |

> The script queries the VA scan cache — you do **not** need to pull the images locally.

---

## Prerequisites

### 1. IBM Cloud CLI (`ibmcloud`)

Install from: <https://cloud.ibm.com/docs/cli?topic=cli-install-ibmcloud-cli>

The script will detect if `ibmcloud` is missing and print the install URL before exiting.

### 2. Container Registry plugin

The `ibmcloud cr` commands are provided by the container-registry plugin. Install it once:

```bash
ibmcloud plugin install container-registry
```

### 3. Log in to IBM Cloud

The script checks for an active, non-expired session using `ibmcloud cr info` before running any scans. If the session is missing or timed out it exits with a clear message.

```bash
# Federated / SSO accounts (most IBM employees)
ibmcloud login --sso

# Standard accounts
ibmcloud login -u <YOUR_EMAIL>
```

### 4. `jq` (curl method only)

Only needed when using `--method curl`. Install via your package manager:

```bash
brew install jq        # macOS
apt-get install jq     # Debian/Ubuntu
dnf install jq         # RHEL/Fedora
```

---

## Usage

```
./satellite-connector-agent-vulns.sh [OPTIONS]

OPTIONS
  -t, --tag TAG         Image tag to scan (default: latest)
  -m, --method METHOD   'cli' (default) or 'curl'
  -e, --extended        Show full per-package fix details  (cli method only)
  -j, --json            Output raw JSON                    (cli method only)
  -h, --help            Show this help
```

Make the script executable first:

```bash
chmod +x satellite-connector-agent-vulns.sh
```

---

## Examples

```bash
# Scan the latest tag (both images, default cli method)
./satellite-connector-agent-vulns.sh

# Scan a specific version
./satellite-connector-agent-vulns.sh --tag v1.2.7

# Show full package-level fix details
./satellite-connector-agent-vulns.sh --tag v1.2.7 --extended

# Use the curl / REST API method instead of the CLI
./satellite-connector-agent-vulns.sh --tag v1.2.7 --method curl

# Output raw JSON (useful for piping to other tools)
./satellite-connector-agent-vulns.sh --json
```

---

## How it works

### Method: `cli` (default)

Uses `ibmcloud cr vulnerability-assessment`. The two images live in different registry regions so the script automatically switches between `us-south` and `global` before each query.

```bash
# Behind the scenes for Image 1:
ibmcloud cr region-set us-south
ibmcloud cr vulnerability-assessment us.icr.io/armada-master/satellite-connector-agent:latest

# Behind the scenes for Image 2:
ibmcloud cr region-set global
ibmcloud cr vulnerability-assessment icr.io/ibm/satellite-connector/satellite-connector-agent:latest
```

### Method: `curl`

Calls the IBM VA v4 REST API directly using an IAM bearer token. Returns structured JSON with CVE details, OS distribution, scan timestamp, and per-package fix versions.

```bash
TOKEN=$(ibmcloud iam oauth-tokens --output json | jq -r .iam_token)

curl -s \
  -H "Scan-Engines: ibm_va" \
  -H "Authorization: $TOKEN" \
  "https://us.icr.io/va/api/v4/report/image/us.icr.io/armada-master/satellite-connector-agent:latest"
```

---

## Validation

Running against `v1.2.7` (a known-vulnerable release) is a good way to verify everything is wired up correctly. It should report **36 CVEs** on both images:

```bash
./satellite-connector-agent-vulns.sh --tag v1.2.7
```

Expected output (truncated):

```
Satellite Connector Agent — Vulnerability Assessment
Tag: v1.2.7
...
The scan results show that 36 ISSUES were found for the image.
```
