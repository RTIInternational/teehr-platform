# Platform repository for TEEHR Cloud
This repository contains Terraform Infrastructure as Code (IaC) for both AWS resources and 
deployment specific in-cluster resources such as contour, cluster autoscaler and cert-manager.

## Terraform

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
