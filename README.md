# Platform repository for TEEHR Cloud
This repository contains Terraform Infrastructure as Code (IaC) for both AWS resources and 
deployment specific in-cluster resources such as contour, cluster autoscaler and cert-manager.

## Terraform

Terraform code is located under `terraform/`.

### Backend configuration

Backend settings are intentionally not hardcoded. Initialize Terraform with a backend config file per environment/account.

1. Copy the example backend file:

```bash
cd terraform
cp backend/dev.hcl.example backend/dev.hcl
```

2. Update `backend/dev.hcl` with your bucket/table/region values.

3. Initialize Terraform with backend config:

```bash
terraform init -backend-config=backend/dev.hcl
```

### Plan / Apply

```bash
terraform plan -var-file=teehr-hub.tfvars
terraform apply -var-file=teehr-hub.tfvars
```

Use separate backend files and varfiles for each environment/account.
