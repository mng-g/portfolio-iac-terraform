# Terraform Portfolio Project

This project demonstrates how to manage a multi-environment AWS infrastructure using Terraform Cloud. The repository contains Terraform modules for managing VPCs, EC2 instances, and monitoring (CloudTrail, CloudWatch, etc.), with separate environment folders for **dev** and **prod**.

## File Structure

```
.
├── environments
│   ├── dev
│   │   ├── main.tf
│   │   ├── terraform.tfstate
│   │   ├── terraform.tfstate.backup
│   │   └── variables.tf
│   └── prod
│       ├── main.tf
│       └── variables.tf
├── main.tf
├── modules
│   ├── ec2
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── monitoring
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── vpc
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── outputs.tf
├── README.md
└── variables.tf
```

## Prerequisites

- **AWS User:** Create an AWS IAM user, request an access key (you'll put key ID and secret on Terraform Cloud) and all the following policies:
  - `AmazonEC2FullAccess`
  - `AmazonS3FullAccess`
  - `CloudWatchLogsFullAccess`
  - `IAMFullAccess`
  - `AWSCloudTrail_FullAccess`
  
- **SSH Key:**  
  - Generate an SSH key pair to access EC2 instances:
    ```bash
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/my-key-pair
    ```

- **Terraform Cloud:**  
  - Create an account and organization on [Terraform Cloud](https://app.terraform.io/).
  - Generate a Terraform Cloud API token using `terraform login` or via the Terraform Cloud UI.
  - In your Terraform Cloud workspace(s), add the following environment variables:
    - `AWS_ACCESS_KEY_ID` (non-sensitive)
    - `AWS_SECRET_ACCESS_KEY` (sensitive)
  - In your Terraform Cloud workspace(s), add the following Terraform variable:
    - `public_key` (non-sensitive) with the content of the public key (e.g., `~/.ssh/my-key-pair.pub`) as value
  - Create separate workspaces for **dev** and **prod** (for example: *portfolio-iac-terraform-dev* and *portfolio-iac-terraform-prod*) with workflow *Version Control workflow*:
    - Set the working directory for the dev workspace to `environments/dev`
    - Set the working directory for the prod workspace to `environments/prod`
  
- **GitHub Token:**  
  - Create a GitHub secret named `TFC_TOKEN` in your repository for Terraform Cloud access. As value you have to set the API KEY provided running `terraform login`.

## Project Setup

1. **Terraform Cloud Login:**  
   Run `terraform login` locally to generate the required credentials file before pushing your code.

2. **Initialize Terraform:**  
   Navigate to each environment directory and run:
   ```bash
   terraform init
   ```
   This initializes the backend (Terraform Cloud) for each environment.

3. **Terraform Cloud Workspace Settings:**
   - Ensure your workspaces are configured with the correct working directory (`environments/dev` or `environments/prod`).
   - Ensure environment variables and secrets are added properly (AWS credentials, etc.).

4. **Deploy Infrastructure:**  
   If you've created *Version Control workflow* workspaces, you can use `terraform plan` but `terraform apply` is not available. You can git changes on the repo to trigger the resources provisioning. You can verify and confirm the `terraform apply` on Terraform Cloud UI.

5. **Post-Deployment:**  
   - SSH into your EC2 instances using:
     ```bash
     ssh -i ~/.ssh/my-key-pair ec2-user@<public-ip-address>
     ```
   - Monitor CloudTrail logs and CloudWatch alarms for activity and cost insights.

6. **Destroy resources**
   You can run `terrafom destroy` directly from the Terraform Cloud UI but keep in mind that you may need to empty the S3 buckets to avoid errors.

## CI/CD Pipeline with GitHub Actions

This repository includes a GitHub Actions pipeline (`.github/workflows/terraform-ci.yml`) that performs automated checks on the Terraform configuration. The pipeline is configured as follows:

- **Trigger Conditions:**
  - On **push** to the `main` branch.
  - On **pull requests** targeting the `main` branch.
  
- **Environments:**
  - Uses a matrix strategy to validate both **dev** and **prod** environments (located in `environments/dev` and `environments/prod`).

- **Pipeline Steps Include:**
  - **Setup:** Checkout code and create the Terraform Cloud credentials file using the `TFC_TOKEN` secret.
  - **Terraform Setup & Linting:**  
    - Run `terraform fmt -check`
    - Run `terraform init -input=false`
    - Run `terraform validate`
  - **Security Scans:**  
    - Run `tfsec`
    - Run `checkov` (with soft fail enabled)
  - (Optionally) **Cost Estimation:**  
    - Infracost steps can be integrated (e.g., via Infracost Action) to analyze cost differences.