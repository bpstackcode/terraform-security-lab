# 🔐 Terraform AWS Security Lab

[![Terraform](https://img.shields.io/badge/Terraform-1.7.0-7B42BC?style=for-the-badge&logo=terraform)](https://terraform.io)
[![AWS](https://img.shields.io/badge/AWS-us--east--1-FF9900?style=for-the-badge&logo=amazonwebservices)](https://aws.amazon.com)
[![GitHub Actions](https://img.shields.io/badge/CI%2FCD-GitHub_Actions-2088FF?style=for-the-badge&logo=githubactions)](https://github.com/features/actions)
[![tfsec](https://img.shields.io/badge/Security-tfsec-red?style=for-the-badge)](https://github.com/aquasecurity/tfsec)
[![S3 Backend](https://img.shields.io/badge/State-S3_Remote_Backend-569A31?style=for-the-badge&logo=amazons3)](https://developer.hashicorp.com/terraform/language/settings/backends/s3)

-----

## Why This Project Exists

Manual infrastructure deployments create two compounding problems for organizations: **inconsistency** and **invisible risk**. When engineers click through the AWS console to provision resources, there’s no audit trail, no repeatable process, and no guarantee that security configurations are applied correctly every time.

This project eliminates both problems. Every infrastructure change runs through an automated pipeline that validates, scans for misconfigurations, and produces a documented plan before anything is applied — making infrastructure changes reviewable, auditable, and secure by default.

-----

## Business Impact

|Problem                                                        |How This Solves It                                                           |
|---------------------------------------------------------------|-----------------------------------------------------------------------------|
|Misconfigured infrastructure is the #1 source of cloud breaches|Automated tfsec scanning catches vulnerabilities before they reach production|
|Manual deployments create inconsistency across environments    |IaC ensures every deployment is identical and version-controlled             |
|No visibility into who changed what, and when                  |Git history + remote state creates a full audit trail                        |
|Concurrent deployments corrupt state and cause outages         |DynamoDB state locking prevents race conditions                              |
|Sensitive state files leak credentials when stored locally     |Encrypted S3 backend keeps state off developer machines entirely             |

-----

## Architecture

```
VPC (10.0.0.0/16)
└── Public Subnet (10.0.1.0/24)
    └── Internet Gateway
        └── Security Group
            ├── Inbound: SSH (22), HTTP (80), HTTPS (443)
            └── Outbound: All traffic
```

-----

## CI/CD Pipeline

Every push to `main` triggers the full pipeline automatically — no human gate required:

|Step         |Tool                |Purpose                                                   |
|-------------|--------------------|----------------------------------------------------------|
|Format Check |`terraform fmt`     |Enforces code style — prevents reviewer debate on style   |
|Initialize   |`terraform init`    |Downloads AWS provider, connects to remote state          |
|Validate     |`terraform validate`|Catches config errors before they hit the pipeline        |
|Security Scan|`tfsec`             |Detects misconfigurations mapped to CIS benchmarks        |
|Plan         |`terraform plan`    |Documents exactly what will change — nothing is a surprise|


> Security findings are uploaded to the **GitHub Security tab** in SARIF format for centralized tracking and remediation workflow.

**Design decision:** The pipeline runs plan-only — no auto-apply. This is intentional. In a production environment, a failed `apply` mid-deployment can leave infrastructure in a partial state. The plan gate ensures a human reviews the delta before any change is committed to production.

-----

## Remote State Management

Terraform state is the source of truth for your infrastructure. Storing it locally is a liability — it gets lost, it holds sensitive values, and it breaks team workflows.

|Resource                               |Purpose                                          |
|---------------------------------------|-------------------------------------------------|
|S3 Bucket `bpstackcode-terraform-state`|Encrypted state storage with full version history|
|DynamoDB Table `terraform-state-lock`  |State locking — prevents concurrent modifications|

**Security properties:**

- State file encrypted at rest (AES-256)
- Full version history — any state can be rolled back
- State locking prevents race conditions during concurrent pipelines
- No state data stored in Git — no credential exposure

-----

## Tech Stack

|Layer                 |Technology                                           |
|----------------------|-----------------------------------------------------|
|Infrastructure as Code|Terraform 1.7.0                                      |
|Cloud Provider        |AWS (VPC, Subnet, IGW, Security Groups, S3, DynamoDB)|
|CI/CD                 |GitHub Actions                                       |
|Security Scanning     |tfsec (SARIF output)                                 |
|State Backend         |S3 + DynamoDB                                        |

-----

## Security Practices

- **Least privilege IAM** — Dedicated `terraform-github-actions` user with scoped permissions only. No root credentials, no over-permissioned admin keys.
- **No secrets in code** — Credentials injected via GitHub Actions secrets at runtime
- **State encryption** — Remote state stored in S3 with server-side encryption enabled
- **Gitignore hardened** — `.terraform/` and `*.tfstate` excluded; provider binaries never committed
- **Security findings tracked** — tfsec output in SARIF format integrates directly with GitHub Security tab for remediation workflow
- **Plan-only pipeline** — No auto-apply prevents unintended infrastructure changes from reaching production

-----

## Project Structure

```
terraform-security-lab/
├── .github/
│   └── workflows/
│       └── terraform-ci.yml   # Full CI/CD pipeline definition
├── main.tf                    # Core infrastructure + S3 backend config
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── terraform.lock.hcl         # Provider version lock (reproducible builds)
└── .gitignore                 # Excludes state & provider binaries
```

-----

## Local Setup

### Prerequisites

- Terraform >= 1.7.0
- AWS CLI configured with appropriate credentials
- S3 bucket and DynamoDB table provisioned for remote state

### Run It

```bash
git clone https://github.com/bpstackcode/terraform-security-lab.git
cd terraform-security-lab

# Initialize — connects to S3 backend
terraform init

# Preview all changes before applying
terraform plan

# Apply (run locally only — pipeline is plan-only)
terraform apply
```

### GitHub Actions Secrets Required

|Secret                 |Description        |
|-----------------------|-------------------|
|`AWS_ACCESS_KEY_ID`    |IAM user access key|
|`AWS_SECRET_ACCESS_KEY`|IAM user secret key|

-----

## Key Engineering Concepts Demonstrated

- Infrastructure as Code (IaC) — repeatable, version-controlled deployments
- DevSecOps — security scanning embedded in the CI pipeline, not bolted on after
- Remote state management — encrypted S3 backend with DynamoDB locking
- Least privilege IAM — scoped service account,
