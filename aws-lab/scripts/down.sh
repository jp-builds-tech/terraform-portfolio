#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

docker rm -f moto >/dev/null 2>&1 || true
rm -f "$ROOT"/bootstrap/terraform.tfstate* "$ROOT"/network/terraform.tfstate*
echo "Emulator removed and local state files cleared."
