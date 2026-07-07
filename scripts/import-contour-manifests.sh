#!/usr/bin/env bash
set -euo pipefail

# Import existing Contour Kubernetes objects from terraform/manifests/contour.yaml
# into kubernetes_manifest.contour[...] state addresses.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TF_DIR="$REPO_ROOT/terraform"
MANIFEST_FILE="$TF_DIR/manifests/contour.yaml"
TF_VAR_FILE="${TF_VAR_FILE:-teehr-hub.tfvars}"

if ! command -v kubectl >/dev/null 2>&1; then
  echo "ERROR: kubectl is required"
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq is required"
  exit 1
fi

cd "$TF_DIR"

echo "Generating import targets from $MANIFEST_FILE ..."
echo "Using var-file: $TF_VAR_FILE"

kubectl create --dry-run=client -f "$MANIFEST_FILE" -o json \
  | jq -rs -r '
      .[]
      | if has("items") then .items[] else . end
      | . as $obj
      | ($obj.kind + ":" + ($obj.metadata.namespace // "cluster") + ":" + $obj.metadata.name) as $key
      | ("apiVersion=" + $obj.apiVersion + ",kind=" + $obj.kind + ",name=" + $obj.metadata.name
        + (if $obj.metadata.namespace then ",namespace=" + $obj.metadata.namespace else "" end)) as $id
      | [$key, $id]
      | @tsv' \
  | while IFS=$'\t' read -r key id; do
      echo "terraform import -var-file=$TF_VAR_FILE kubernetes_manifest.contour[\"$key\"] $id"
      terraform import -var-file="$TF_VAR_FILE" "kubernetes_manifest.contour[\"$key\"]" "$id"
    done

echo "Done. Run: terraform plan -var-file=teehr-hub.tfvars"
