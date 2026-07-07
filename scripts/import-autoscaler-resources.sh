#!/usr/bin/env bash
set -euo pipefail

# Import existing autoscaler resources into Terraform state.
# - Helm release: cluster-autoscaler
# - Kubernetes manifests: aws-node-termination-handler resources

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TF_DIR="$REPO_ROOT/terraform"
MANIFEST_FILE="$TF_DIR/manifests/node-termination-handler.yaml"
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

# Import autoscaler helm release if not already in state.
if terraform state show helm_release.cluster_autoscaler >/dev/null 2>&1; then
  echo "helm_release.cluster_autoscaler already in state; skipping import"
else
  terraform import -var-file="$TF_VAR_FILE" helm_release.cluster_autoscaler kube-system/cluster-autoscaler
fi

# Import existing NTH objects.
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
      address="kubernetes_manifest.node_termination_handler[\"$key\"]"
      if terraform state show "$address" >/dev/null 2>&1; then
        echo "$address already in state; skipping import"
      else
        echo "terraform import -var-file=$TF_VAR_FILE $address $id"
        terraform import -var-file="$TF_VAR_FILE" "$address" "$id"
      fi
    done

echo "Done. Run: terraform plan -var-file=$TF_VAR_FILE"
