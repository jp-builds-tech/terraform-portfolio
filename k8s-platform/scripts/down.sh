#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if [ -d "$ROOT/platform" ]; then
  terraform -chdir="$ROOT/platform" destroy -auto-approve
fi
terraform -chdir="$ROOT/cluster" destroy -auto-approve