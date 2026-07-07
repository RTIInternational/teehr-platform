# Migration Notes

This file records the platform cutover from Garden-managed in-cluster resources in teehr-hub to Terraform-managed platform components in teehr-platform.

## What Moved

- cert-manager was moved to Terraform as a Helm release in [terraform/cert-manager.tf](../terraform/cert-manager.tf).
- Contour was moved to Terraform-managed Kubernetes manifests in [terraform/contour.tf](../terraform/contour.tf) and [terraform/manifests/contour.yaml](../terraform/manifests/contour.yaml).
- Cluster Autoscaler and the Node Termination Handler were moved to Terraform in [terraform/autoscaler.tf](../terraform/autoscaler.tf) and [terraform/manifests/node-termination-handler.yaml](../terraform/manifests/node-termination-handler.yaml).

## Adoption Approach

- Existing cert-manager installations were adopted with `terraform import helm_release.cert_manager cert-manager/cert-manager`.
- Contour objects were imported with the helper script in [scripts/import-contour-manifests.sh](../scripts/import-contour-manifests.sh).
- Autoscaler resources were imported with the helper script in [scripts/import-autoscaler-resources.sh](../scripts/import-autoscaler-resources.sh).

## Notes

- Contour CRDs and the certgen Job were excluded from Terraform ownership because they caused provider drift during adoption.
- The autoscaler helper was used as a migration aid; the end state is the Terraform configuration, not the script itself.
- Future changes should follow the operational commands in [../README.md](../README.md).
