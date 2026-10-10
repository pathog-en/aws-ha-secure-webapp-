# Project Lifecycle

This project is intentionally not kept running continuously because AWS EKS,
load balancers, compute, and related services incur ongoing cost.

## Validate Without Deploying

Terraform:

```powershell
terraform fmt -check -recursive terraform
terraform -chdir=terraform init -backend=false -lockfile=readonly
terraform -chdir=terraform validate
terraform -chdir=terraform/ecr init -backend=false -lockfile=readonly
terraform -chdir=terraform/ecr validate
terraform -chdir=terraform/eks init -backend=false -lockfile=readonly
terraform -chdir=terraform/eks validate
```

Helm:
```powershell
helm lint platform\helm\golden-web-service
helm template aws-ha-webapp platform\helm\golden-web-service > NUL
```

Application:
```powershell
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
python -m uvicorn app.main:app --host 127.0.0.1 --port 8000
```

Verify:
```powershell
curl http://127.0.0.1:8000/health
```

Expected:
{"status":"healthy"}

## Configuration Ownership
Terraform owns AWS infrastructure.
Helm owns the Kubernetes application workload.
GitHub Actions validates Terraform, Helm, and the container build and publishes
validated images to ECR.
AWS Deployment
AWS deployment is optional and incurs cost.
Before applying infrastructure:
1. Review terraform plan.
2. Confirm the resources and expected charges.
3. Do not treat terraform apply as part of routine repository validation.

## Cleanup
Use Terraform plans and state to identify infrastructure before destroying it.
Review the destroy plan before approving destructive changes.
The EKS environment is intentionally ephemeral and can be recreated from code
when a live demonstration environment is needed.