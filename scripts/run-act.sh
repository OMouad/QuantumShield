#!/usr/bin/env bash
set -euo pipefail

# Portable runner for GitHub Actions via act
# - Works on Linux/macOS and on Windows via Git Bash/WSL
# - Defaults: event=push, job=build, artifacts at ./artifacts

usage() {
  cat <<'EOF'
Usage: scripts/run-act.sh [-e event] [-j job]... [-P platform] [-A dir] [--list]

Options:
  -e, --event       GitHub event to simulate (default: push)
  -j, --job         Job name to run (repeatable; default: build)
  -P, --platform    Runner mapping (default: ubuntu-latest=ghcr.io/catthehacker/ubuntu:act-22.04)
  -A, --artifact    Artifact output dir for upload-artifact (default: ./artifacts)
      --list        List available jobs and exit
  -h, --help        Show this help

Examples:
  scripts/run-act.sh --list
  scripts/run-act.sh -j build
  scripts/run-act.sh -e push -j sbom
  scripts/run-act.sh -e push -j secrets -A ./artifacts
  scripts/run-act.sh -e pull_request -j review
EOF
}

# Find act binary
ACT_BIN=""
if command -v act >/dev/null 2>&1; then
  ACT_BIN="act"
elif [[ -x ".tools/act" ]]; then
  ACT_BIN=".tools/act"
elif [[ -x ".tools/act.exe" ]]; then
  ACT_BIN=".tools/act.exe"
else
  echo "Error: 'act' not found. Install from https://github.com/nektos/act or place binary at .tools/act(.exe)" >&2
  exit 1
fi

EVENT="push"
PLATFORM="ubuntu-latest=ghcr.io/catthehacker/ubuntu:act-22.04"
ARTIFACT_DIR="./artifacts"
JOBS=()

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    -e|--event) EVENT="$2"; shift 2;;
    -j|--job) JOBS+=("$2"); shift 2;;
    -P|--platform) PLATFORM="$2"; shift 2;;
    -A|--artifact) ARTIFACT_DIR="$2"; shift 2;;
    --list) "$ACT_BIN" -l; exit 0;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown argument: $1" >&2; usage; exit 1;;
  esac
done

mkdir -p "$ARTIFACT_DIR"

# Default job
if [[ ${#JOBS[@]} -eq 0 ]]; then
  JOBS=(build)
fi

CMD=("$ACT_BIN" "$EVENT" -P "$PLATFORM" --artifact-server-path "$ARTIFACT_DIR")
for job in "${JOBS[@]}"; do
  CMD+=( -j "$job" )
done

echo "Running: ${CMD[*]}"
"${CMD[@]}"
