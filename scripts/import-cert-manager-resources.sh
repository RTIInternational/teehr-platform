#!/usr/bin/env bash
set -euo pipefail

# Import existing cert-manager resources into Terraform state.
# - Helm release: cert-manager
# - Kubernetes manifests: resources from terraform/manifests/cert-manager.yaml

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TF_DIR="$REPO_ROOT/terraform"
MANIFEST_FILE="$TF_DIR/manifests/cert-manager.yaml"
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

echo "Using var-file: $TF_VAR_FILE"
echo "Generating import targets from $MANIFEST_FILE ..."

# Import cert-manager helm release if not already in state.
if terraform state show helm_release.cert_manager >/dev/null 2>&1; then
  echo "helm_release.cert_manager already in state; skipping import"
else
  terraform import -var-file="$TF_VAR_FILE" helm_release.cert_manager cert-manager/cert-manager
fi

# Import existing cert-manager manifest objects.
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
      address="kubernetes_manifest.cert_manager[\"$key\"]"
      if terraform state show "$address" >/dev/null 2>&1; then
        echo "$address already in state; skipping import"
      else
        echo "terraform import -var-file=$TF_VAR_FILE $address $id"
        terraform import -var-file="$TF_VAR_FILE" "$address" "$id"
      fi
    done

echo "Done. Run: terraform plan -var-file=$TF_VAR_FILE"
