# AWS EKS Infrastructure with Istio Service Mesh and Monitoring Stack

A comprehensive Infrastructure as Code (IaC) solution that deploys a production-ready Amazon EKS cluster with integrated service mesh, monitoring, and autoscaling capabilities using Terraform. The solution provides automated cluster management, observability, and secure networking out of the box.

This project automates the deployment of a complete Kubernetes infrastructure on AWS, including Istio service mesh for traffic management, Prometheus and Grafana for monitoring, Jaeger for distributed tracing, and Karpenter for intelligent node provisioning. It implements security best practices with proper IAM roles, KMS encryption, and network policies while providing scalability through automated node management and load balancing.

## Repository Structure
```
.
├── terraform/                      # Core Terraform configuration files
│   ├── eks.tf                     # EKS cluster configuration
│   ├── helm_istio.tf             # Istio service mesh deployment
│   ├── helm_prometheus.tf        # Prometheus monitoring stack
│   ├── iam_*.tf                  # IAM roles and policies
│   └── variables.tf              # Input variables definition
├── assets/                        # Kubernetes manifests
│   ├── chip.yaml                 # Sample application configuration
│   └── health-api.yaml          # Health check API configuration
├── helm/                         # Helm chart values
│   └── prometheus/              # Prometheus configuration
└── docs/                         # Documentation
    └── infra.dot                # Infrastructure diagram
```

## Usage Instructions
### Prerequisites
- AWS CLI configured with appropriate credentials
- Terraform >= 1.0.0
- kubectl
- helm >= 3.0.0
- An existing VPC with public and private subnets
- Route53 hosted zone (if using provided DNS features)

### Installation

1. Configure AWS credentials:
```bash
aws configure
```

2. Initialize Terraform:
```bash
terraform init
```

3. Review and modify variables:
```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

4. Deploy the infrastructure:
```bash
terraform plan
terraform apply
```

### Quick Start

1. Configure kubectl for your new cluster:
```bash
aws eks update-kubeconfig --name <cluster-name> --region <region>
```

2. Verify the installation:
```bash
kubectl get nodes
kubectl get pods -n istio-system
```

3. Access Grafana dashboard:
```bash
echo "Grafana URL: https://${var.grafana_host}"
kubectl get secret prometheus-grafana -n prometheus -o jsonpath="{.data.admin-password}" | base64 --decode
```

### More Detailed Examples

1. Deploy a sample application with Istio injection:
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: sample-app
  labels:
    istio-injection: enabled
---
apiVersion: apps/v1
kind: Deployment
# ... rest of the application deployment
```

2. Configure Prometheus monitoring:
```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: sample-app
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app: sample-app
  endpoints:
    - port: metrics
```

### Troubleshooting

1. EKS Cluster Access Issues:
- Verify IAM role permissions
- Check AWS CLI configuration
- Ensure VPC endpoints are properly configured
```bash
aws eks describe-cluster --name <cluster-name> --region <region>
```

2. Istio Service Mesh Issues:
- Check Istio pods status
- Verify sidecar injection
```bash
kubectl get pods -n istio-system
kubectl describe pod <pod-name> -n istio-system
```

3. Monitoring Stack Issues:
- Verify Prometheus operator status
- Check Grafana persistent volume claims
```bash
kubectl get prometheuses -n prometheus
kubectl get pvc -n prometheus
```

## Data Flow
The infrastructure implements a multi-tier architecture with secure communication between components through the Istio service mesh.

```ascii
External Traffic → NLB → Istio Ingress Gateway → Service Mesh → Pods
                                ↓
                        Monitoring Stack
                    (Prometheus/Grafana)
                                ↓
                     Distributed Tracing
                         (Jaeger)
```

Key component interactions:
1. External traffic enters through AWS Network Load Balancer
2. Istio Ingress Gateway routes traffic based on virtual service rules
3. Service mesh handles inter-service communication and telemetry
4. Prometheus collects metrics from services and infrastructure
5. Grafana visualizes metrics and provides dashboards
6. Jaeger collects and visualizes distributed traces
7. Karpenter manages node provisioning based on workload demands

## Infrastructure

![Infrastructure diagram](./docs/infra.svg)

### Compute Resources
- EKS Cluster (AWS::EKS::Cluster)
- Node Groups managed by Karpenter
- Fargate Profiles for serverless workloads

### IAM Resources
- EKS Cluster Role
- Node Instance Role
- Service Account Roles
- Load Balancer Controller Role

### Storage Resources
- EFS for Prometheus storage
- EFS for Grafana storage

### Networking Resources
- Security Groups for cluster and EFS
- Network Load Balancer
- Target Groups

### Monitoring Resources
- Prometheus Operator
- Grafana Dashboards
- Jaeger Tracing
- Kiali Service Mesh Dashboard