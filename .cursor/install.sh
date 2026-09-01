#!/usr/bin/env bash
# Idempotent install script for Cursor Cloud Agent Builds.
# Runs on Ubuntu during environment preparation (not at agent start).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "[OpenField] Verifying repository layout..."

required=(
  "OpenField.xcodeproj/project.pbxproj"
  "OpenField/App/OpenFieldApp.swift"
  "OpenField/Services/Protocols/EventStore.swift"
  "OpenField/Services/Local/InMemoryEventStore.swift"
  "OpenField/Domain/Policies/LocationPingThrottle.swift"
)

for path in "${required[@]}"; do
  if [[ ! -f "$path" ]]; then
    echo "[OpenField] ERROR: missing required file: $path"
    exit 1
  fi
done

swift_count="$(find OpenField OpenFieldTests -name '*.swift' 2>/dev/null | wc -l | tr -d ' ')"
echo "[OpenField] Found ${swift_count} Swift source files."

# Lightweight CLI tools for agent search/inspection (safe to re-run).
if command -v apt-get >/dev/null 2>&1; then
  export DEBIAN_FRONTEND=noninteractive
  sudo apt-get update -qq
  packages=()
  command -v rg >/dev/null 2>&1 || packages+=(ripgrep)
  command -v jq >/dev/null 2>&1 || packages+=(jq)
  if ((${#packages[@]} > 0)); then
    sudo apt-get install -y -qq "${packages[@]}"
  fi
fi

echo "[OpenField] Cloud VM has no Xcode/iOS Simulator."
echo "[OpenField] Agents may edit Swift, docs, and tests here; verify iOS builds on macOS locally."
echo "[OpenField] Install complete."
