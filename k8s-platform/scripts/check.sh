#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

for tool in terraform tflint checkov; do
  command -v "$tool" >/dev/null || { echo "missing tool: $tool"; exit 1; }
done

echo "== fmt =="
terraform fmt -check -recursive -diff

for dir in cluster platform modules/app; do
  echo "== validate $dir =="
  terraform -chdir="$dir" init -backend=false -input=false >/dev/null
  terraform -chdir="$dir" validate
done

echo "== tflint =="
tflint --recursive --config "$ROOT/.tflint.hcl"

echo "== unit tests =="
terraform -chdir=modules/app test

echo "== checkov =="
checkov -d "$ROOT" --framework terraform --quiet

echo "All checks passed."
