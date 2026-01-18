aws-ha-secure-webapp-

A highly available, AWS-native containerized web application demonstrating modern cloud infrastructure, security best practices, and CI/CD using Docker, Terraform, ECR, EKS, and GitHub Actions.

📌 Project Summary

  This project shows how a simple web application can be containerized, deployed, and operated on AWS using managed services with an emphasis on:
  
  High availability across multiple Availability Zones
  
  Secure networking and IAM practices
  
  Infrastructure as Code (Terraform)
  
  Automated container builds and publishing (CI → ECR)
  
  Kubernetes-based application delivery (EKS)
  
  A live /health endpoint is exposed via an AWS-managed load balancer.

🗺 Architecture Diagram

<img width="1536" height="1024" alt="ChatGPT Image Jan 18, 2026, 02_30_40 PM" src="https://github.com/user-attachments/assets/a0bdd428-7699-4363-8eb8-67455719d972" />


🌍 High-Level Architecture (Current State)

  The application is deployed to a single AWS region.
  
  The region uses two Availability Zones (AZs) for high availability.
  
  A VPC spans both AZs and contains public and private subnets.
  
  Public subnets host:
  
  An AWS-managed load balancer created by Kubernetes
  
  Internet-facing traffic entry points
  
  Private subnets host:
  
  EKS worker nodes running application pods
  
  Amazon ECR stores container images built by CI.
  
  Amazon EKS orchestrates application workloads across nodes.

🔁 Traffic Flow

  A user sends an HTTP request to the public load balancer.
  
  The load balancer forwards traffic to a Kubernetes Service.
  
  The Service routes requests to application pods running in EKS.
  
  The FastAPI application responds to the request (e.g. /health).
  
  All internal traffic remains inside the VPC.

🧩 Application Layer

  The application is a minimal FastAPI service running on Uvicorn.
  
  It exposes a /health endpoint used for:
  
  Load balancer health checks
  
  Kubernetes readiness and liveness probes
  
  The app is fully containerized and immutable at runtime.

🐳 Container & Image Management

  Docker is used to build a portable container image.
  
  Images are stored in Amazon ECR.
  
  Images are tagged using:
  
  A semantic tag (v1)
  
  The Git commit SHA (from CI)

🚀 CI/CD Pipeline

  GitHub Actions automatically runs on pushes to main.
  
  The pipeline:
  
  Builds the Docker image
  
  Authenticates to AWS using OIDC (no static credentials)
  
  Pushes the image to Amazon ECR
  
  Each build is traceable to a specific commit.

🔐 Security Considerations (Current)

  No long-lived AWS credentials are stored in GitHub.
  
  GitHub Actions uses OIDC + IAM role assumption.
  
  Kubernetes nodes use IAM roles with least privilege.
  
  Application containers do not require SSH access.
  
  Traffic enters only through the load balancer.

📊 Monitoring & Health

  Kubernetes health probes ensure failed pods are replaced automatically.
  
  The load balancer performs continuous health checks.
  
  Logs are available via kubectl logs for troubleshooting.

💰 Cost Considerations

  This project prioritizes clarity and correctness over minimal cost.
  
  EKS and load balancers incur ongoing charges while running.
  
  Resources should be destroyed when not in use.

🔮 Future Enhancements (Planned as of 01/18/2026)

  Move worker nodes fully into private subnets with NAT or VPC endpoints
  
  Add Ingress using AWS Load Balancer Controller (ALB)
  
  Enable HTTPS with TLS certificates
  
  Add Horizontal Pod Autoscaling (HPA)
  
  Add CloudWatch Container Insights
  
  Deploy a managed database (RDS) in private subnets
  
  Introduce blue/green or canary deployments



