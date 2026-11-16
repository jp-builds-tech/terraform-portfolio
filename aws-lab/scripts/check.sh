#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

for tool in terraform tflint checkov; do
  command -v "$tool" >/dev/null || { echo "missing tool: $tool"; exit 1; }
done

echo "== fmt =="
terraform fmt -check -recursive -diff
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/tf-check/aws-lab"

for dir in bootstrap network modules/vpc; do
  echo "== validate $dir =="
  export TF_DATA_DIR="$CACHE/$dir"
  mkdir -p "$TF_DATA_DIR"
  terraform -chdir="$dir" init -backend=false -input=false >/dev/null
  terraform -chdir="$dir" validate
done
unset TF_DATA_DIR

echo "== tflint =="
tflint --recursive --config "$ROOT/.tflint.hcl"

echo "== unit tests =="
terraform -chdir=modules/vpc test

echo "== checkov (baseline: findings are listed but do not fail this script) =="
checkov -d "$ROOT" --framework terraform --quiet --soft-fail

echo "All checks passed."
