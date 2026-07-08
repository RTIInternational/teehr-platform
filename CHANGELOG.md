# Changelog

## 2026-07-07

### Summary
- Migrated terraform, contour, cert-manager and autoscaler for remote infrastructure components from `teehr-hub` to this repo.
- Current contour, cert-manager and autoscaler state were imported to terraform state without destroy and recreation.
- Consolidated operational guidance and separated migration history from day-to-day docs.

### What Changed
- Added Terraform for AWS resources from `teehr-hub`.
- Added Terraform for contour and cluster-autoscaler/node-termination-handler resources.
- Added contour import/adoption helper and stabilization updates for existing-cluster adoption.
- Updated migration and operational documentation structure (including migration notes split).
- Kept Terraform definitions aligned and cleaned up related migration script output.

### Why
- Split the application code from the platform code to allow the application to more cleanly be extended to other platforms. 
