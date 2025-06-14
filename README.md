# AWS EKS Cluster with Karpenter Auto-scaling Infrastructure

This project provides an Infrastructure as Code (IaC) solution for deploying and managing a production-ready Amazon EKS cluster with Karpenter-based auto-scaling capabilities. It combines advanced node management, security features, and monitoring capabilities to deliver a robust Kubernetes infrastructure on AWS.

The infrastructure is defined using Terraform and includes comprehensive setup of EKS cluster components, IAM roles, security groups, monitoring tools, and auto-scaling configurations. It features Karpenter for intelligent node provisioning, CoreDNS for service discovery, and various AWS services integration for enhanced cluster management and monitoring.

## Repository Structure
```
.
├── access_entries.tf          # EKS cluster access configuration
├── addons.tf                 # EKS add-ons configuration (CNI, CoreDNS, Kube-proxy)
├── aws_auth.tf              # AWS authentication configuration for EKS
├── backend.tf               # Terraform S3 backend configuration
├── eks.tf                  # Main EKS cluster configuration
├── fargate.tf             # Fargate profile configuration
├── helm_karpenter.tf     # Karpenter Helm chart deployment
├── iam_*.tf             # Various IAM role configurations
├── kms.tf              # KMS key configuration for cluster encryption
├── lambda/            # Lambda functions for cluster management
│   └── coredns/      # CoreDNS configuration fix
├── files/            # Configuration files for various components
│   └── karpenter/   # Karpenter node pool and EC2 configurations
├── sg.tf           # Security group configurations
├── sqs_karpenter.tf # SQS queue for Karpenter events
└── variables.tf    # Terraform variables definition
```

## Usage Instructions
### Prerequisites
- AWS CLI configured with appropriate credentials
- Terraform >= 1.0.0
- kubectl
- helm >= 3.0.0
- An AWS S3 bucket for Terraform state
- AWS IAM permissions to create EKS clusters and related resources

### Installation

1. Configure AWS credentials:
```bash
aws configure
```

2. Initialize Terraform:
```bash
terraform init \
  -backend-config="bucket=your-terraform-state-bucket" \
  -backend-config="key=eks/terraform.tfstate" \
  -backend-config="region=your-aws-region"
```

3. Create a terraform.tfvars file:
```hcl
project_name = "your-project-name"
region = "your-aws-region"
k8s_version = "1.28"
auto_scale_options = {
  min     = 1
  max     = 10
  desired = 2
}
```

4. Apply the configuration:
```bash
terraform plan
terraform apply
```

### Quick Start

1. Configure kubectl for your new cluster:
```bash
aws eks update-kubeconfig --name your-project-name --region your-aws-region
```

2. Verify cluster access:
```bash
kubectl get nodes
```

3. Deploy a sample application:
```bash
kubectl apply -f assets/chip.yml
```

### More Detailed Examples

1. Configuring Karpenter node pools:
```yaml
# Create a custom node pool
kubectl apply -f files/karpenter/nodepool.yml
```

2. Monitoring cluster metrics:
```bash
kubectl get --raw /metrics | grep node_cpu
```

### Troubleshooting

1. CoreDNS Issues
- Symptom: CoreDNS pods stuck in pending state
- Solution: The Lambda function will automatically fix CoreDNS configuration
- Debug command:
```bash
kubectl logs -n kube-system -l k8s-app=kube-dns
```

2. Node Scaling Issues
- Check Karpenter logs:
```bash
kubectl logs -n karpenter -l app.kubernetes.io/name=karpenter
```

3. Authentication Issues
- Verify aws-auth ConfigMap:
```bash
kubectl describe configmap aws-auth -n kube-system
```

## Data Flow

The infrastructure implements a comprehensive event-driven architecture for cluster scaling and management. Karpenter monitors resource requirements and manages node lifecycle through AWS APIs.

```ascii
                                     ┌──────────────┐
                                     │   AWS EKS    │
                                     │   Cluster    │
                                     └──────┬───────┘
                                            │
                    ┌────────────────┬──────┴───────┬────────────────┐
                    │                │              │                │
              ┌─────┴─────┐   ┌─────┴─────┐  ┌─────┴─────┐    ┌─────┴─────┐
              │  Karpenter │   │  CoreDNS  │  │  Metrics  │    │   Node    │
              │  Controller│   │  Service  │  │  Server   │    │Termination│
              └─────┬─────┘   └───────────┘  └───────────┘    └─────┬─────┘
                    │                                                │
              ┌─────┴─────┐                                   ┌─────┴─────┐
              │ AWS SQS   │                                   │CloudWatch │
              │  Queue    │                                   │  Events   │
              └───────────┘                                   └───────────┘
```

Key component interactions:
1. Karpenter monitors pod scheduling events and resource utilization
2. CloudWatch Events capture EC2 instance lifecycle events
3. SQS queues buffer scaling events for reliable processing
4. CoreDNS provides cluster DNS resolution with Fargate compatibility
5. Node Termination Handler ensures graceful node shutdown
6. Metrics Server collects cluster metrics for scaling decisions
7. KMS provides encryption for cluster secrets and data

## Infrastructure

![Infrastructure diagram](./docs/infra.svg)

### Lambda Functions
- `coredns-fix`: Patches CoreDNS deployment for Fargate compatibility

### IAM Roles
- `eks-cluster-role`: Main cluster role with EKS permissions
- `eks-nodes-role`: Node group IAM role
- `fargate-role`: Fargate execution role
- `karpenter-role`: Karpenter controller role

### Security Groups
- Cluster security group with rules for:
  - NodePorts (30000-32768)
  - CoreDNS TCP/UDP (53)
  - Inter-node communication

### Auto Scaling
- Karpenter configured with custom node pools
- SQS queue for scaling events
- CloudWatch event rules for instance lifecycle management