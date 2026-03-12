# 🔐 Terraform AWS Security Lab

![Terraform](https://img.shields.io/badge/Terraform-1.7.0-7B42BC?style=for-the-badge&logo=terraform)
![AWS](https://img.shields.io/badge/AWS-us--east--1-FF9900?style=for-the-badge&logo=amazonaws)
![GitHub Actions](https://img.shields.io/badge/CI%2FCD-GitHub_Actions-2088FF?style=for-the-badge&logo=githubactions)
![tfsec](https://img.shields.io/badge/Security-tfsec-red?style=for-the-badge)
![S3 Backend](https://img.shields.io/badge/State-S3%20Remote%20Backend-569A31?style=for-the-badge&logo=amazons3)

A hands-on cloud security lab provisioning AWS infrastructure using Terraform, with a fully automated CI/CD pipeline featuring security scanning, infrastructure validation, and live plan output reporting.

-----

## 🏗️ Architecture

```
VPC (10.0.0.0/16)
└── Public Subnet (10.0.1.0/24)
    └── Internet Gateway
        └── Security Group
            ├── Inbound: SSH (22), HTTP (80), HTTPS (443)
            └── Outbound: All traffic
```

-----

## 🚀 CI/CD Pipeline

Every push to `main` automatically triggers the full pipeline:

|Step         |Tool                |Purpose                                    |
|-------------|--------------------|-------------------------------------------|
|Format Check |`terraform fmt`     |Enforces code style standards              |
|Initialize   |`terraform init`    |Downloads AWS provider                     |
|Validate     |`terraform validate`|Catches config errors before deploy        |
|Security Scan|`tfsec`             |Detects misconfigurations & vulnerabilities|
|Plan         |`terraform plan`    |Previews infrastructure changes safely     |


> Security findings are uploaded to the **GitHub Security tab** in SARIF format for tracking and remediation.

-----

## 🗄️ Remote State Management

Terraform state is stored remotely in AWS for team collaboration and safety:

|Resource                               |Purpose                                |
|---------------------------------------|---------------------------------------|
|S3 Bucket `bpstackcode-terraform-state`|Stores encrypted Terraform state file  |
|DynamoDB Table `terraform-state-lock`  |Prevents concurrent state modifications|

**Benefits:**

- State file encrypted at rest (AES-256)
- Full version history of state changes
- State locking prevents race conditions
- No sensitive state data stored in Git

-----

## 🛠️ Tech Stack

- **Terraform** — Infrastructure as Code
- **AWS** — VPC, Subnet, Internet Gateway, Security Groups, S3, DynamoDB
- **GitHub Actions** — CI/CD automation
- **tfsec** — Static security analysis for Terraform
- **SARIF** — Security findings reporting (GitHub Security tab)

-----

## 📁 Project Structure

```
terraform-security-lab/
├── .github/
│   └── workflows/
│       └── terraform-ci.yml   # CI/CD pipeline
├── main.tf                    # Core infrastructure + S3 backend config
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── terraform.lock.hcl         # Provider version lock
└── .gitignore                 # Excludes state & provider binaries
```

-----

## ⚙️ Setup & Usage

### Prerequisites

- Terraform >= 1.7.0
- AWS CLI configured
- AWS account with appropriate IAM permissions
- S3 bucket and DynamoDB table for remote state (see Remote State Management)

### Local Development

```bash
# Clone the repo
git clone https://github.com/bpstackcode/terraform-security-lab.git
cd terraform-security-lab

# Initialize Terraform (connects to S3 backend)
terraform init

# Preview changes
terraform plan

# Apply infrastructure
terraform apply
```

### GitHub Actions Setup

Add these secrets to your repository (**Settings → Secrets → Actions**):

|Secret                 |Description        |
|-----------------------|-------------------|
|`AWS_ACCESS_KEY_ID`    |IAM user access key|
|`AWS_SECRET_ACCESS_KEY`|IAM user secret key|

-----

## 🔒 Security Practices

- Dedicated IAM user (`terraform-github-actions`) with scoped permissions — no root credentials
- `.terraform/` and `*.tfstate` excluded from version control
- Terraform state stored remotely in encrypted S3 with DynamoDB locking
- Automated tfsec scanning on every push
- Security findings tracked via GitHub Security tab (SARIF)
- Terraform plan-only pipeline — no auto-apply to prevent unintended changes

-----

## 📌 Key Concepts Demonstrated

- Infrastructure as Code (IaC) with Terraform
- AWS networking fundamentals (VPC, subnets, IGW, security groups)
- Remote state management with S3 backend and DynamoDB locking
- CI/CD pipeline design with GitHub Actions
- DevSecOps — security scanning integrated into the pipeline
- IAM least privilege principles
- GitOps workflow — infrastructure changes tracked via Git history

-----

## 👤 Author

**Bryan Peterson**

- GitHub: [@bpstackcode](https://github.com/bpstackcode)

-----

*Part of an ongoing cloud engineering & cybersecurity portfolio.*
