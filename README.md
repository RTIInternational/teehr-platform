# Platform repository for TEEHR Cloud
This repository contains Terraform Infrastructure as Code (IaC) for both AWS resources and 
deployment specific in-cluster resources such as contour, cluster autoscaler and cert-manager.

## Terraform

Login to AWS.  You need to login with a user that has sufficient permissions.
We used Admin for testing but need to determine the minimum set of permissions needed.
```bash
aws configure
```
Or set a profile
```bash
export AWS_PROFILE=ciroh_mdenno
```

Terraform code is located under `terraform/`.

Initialize Terraform:

```bash
cd terraform
terraform init
```

State backend configuration is defined in [terraform/versions.tf](terraform/versions.tf) and currently points to the shared state bucket `teehr-terraform-state` in `us-east-2`.

### Plan / Apply

```bash
terraform plan -var-file=teehr-hub.tfvars
terraform apply -var-file=teehr-hub.tfvars
```

### Post-Apply Checklist

1. Review Terraform outputs:

```bash
terraform output
```

2. Verify target resources exist in AWS (EKS cluster, IAM roles, S3 bucket, and ECR repositories).
3. Record key output values needed by app deployment workflows.
4. Re-run `terraform plan -var-file=teehr-hub.tfvars` and confirm it reports no pending changes.

### Cert-Manager Ownership (Terraform)

This repository now defines cert-manager via Terraform Helm provider in [terraform/cert-manager.tf](terraform/cert-manager.tf).

For existing clusters, prefer adopting the current Helm release into Terraform state instead of uninstalling cert-manager.

1. Initialize providers:

```bash
cd terraform
terraform init
```

2. Import existing cert-manager Helm release (if already installed):

```bash
terraform import helm_release.cert_manager cert-manager/cert-manager
```

3. Validate and apply:

```bash
terraform plan -var-file=teehr-hub.tfvars
terraform apply -var-file=teehr-hub.tfvars
```

### Contour Ownership (Terraform)

This repository manages Contour with Kubernetes manifests in [terraform/contour.tf](terraform/contour.tf) using [terraform/manifests/contour.yaml](terraform/manifests/contour.yaml).

For existing clusters where Contour objects already exist, import them into Terraform state before the first apply:

```bash
./scripts/import-contour-manifests.sh
```

This avoids "Cannot create resource that already exists" errors during the first Terraform apply.

```bash
cd terraform
terraform plan -var-file=teehr-hub.tfvars
terraform apply -var-file=teehr-hub.tfvars
```

### Autoscaler Ownership (Terraform)

This repository manages the Cluster Autoscaler Helm release and Node Termination Handler manifests in [terraform/autoscaler.tf](terraform/autoscaler.tf).

For existing clusters, import current resources before first apply:

```bash
./scripts/import-autoscaler-resources.sh
```

Then reconcile with Terraform:

```bash
cd terraform
terraform plan -var-file=teehr-hub.tfvars
terraform apply -var-file=teehr-hub.tfvars
```
