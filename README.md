# AWS EKS Infrastructure as Code with Terraform

This project provides a tempalte for Infrastructure as Code (IaC) solution for deploying and managing Amazon Elastic Kubernetes Service (EKS) clusters in automode, using Terraform. It implements AWS best practices for security, scalability, and maintainability.

The infrastructure setup includes a complete EKS cluster with node pools, IAM roles, security groups, and essential Kubernetes add-ons. It features automated node scaling, encrypted storage using KMS, comprehensive logging, and integration with AWS services like CloudWatch and Systems Manager.

## Repository Structure
```
.
├── assets/                    # Kubernetes manifests for applications
│   ├── chip-ingress.yaml     # Ingress configuration for the chip service
│   ├── chip-system.yaml      # System-level configuration for the chip service
│   └── chip.yaml             # Core deployment configuration for the chip service
├── docs/                      # Documentation files
│   ├── infra.dot            # Infrastructure diagram source
│   └── infra.svg            # Visual infrastructure diagram
├── terraform/                 # Terraform configuration files
│   ├── backend.tf            # Terraform state configuration
│   ├── data.tf              # Data source definitions
│   ├── eks.tf               # EKS cluster configuration
│   ├── iam_*.tf             # IAM roles and policies
│   ├── kms.tf               # KMS key configuration
│   ├── providers.tf         # Provider configurations
│   └── variables.tf         # Input variables definition
```

## Usage Instructions
### Prerequisites
- AWS CLI configured with appropriate credentials
- Terraform >= 1.0.0
- kubectl
- helm >= 3.0.0
- AWS account with permissions to create:
  - EKS clusters
  - IAM roles and policies
  - KMS keys
  - Security Groups
  - CloudWatch Log Groups

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd <repository-name>
```

2. Initialize Terraform:
```bash
terraform init
```

3. Review and customize variables:
```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your desired values
```

4. Deploy the infrastructure:
```bash
terraform plan -out=tfplan
terraform apply tfplan
```

### Quick Start

1. Configure kubectl to use the new cluster:
```bash
aws eks update-kubeconfig --name <project_name> --region <region>
```

2. Verify cluster access:
```bash
kubectl get nodes
```

3. Deploy the sample application:
```bash
kubectl apply -f assets/chip.yaml
```

### More Detailed Examples

1. Deploying with custom node pools:
```hcl
module "eks" {
  source = "./modules/eks"
  
  project_name = "my-cluster"
  node_pools = {
    system = {
      min_size = 2
      max_size = 4
      instance_types = ["t3.medium"]
    }
    application = {
      min_size = 3
      max_size = 10
      instance_types = ["t3.large"]
    }
  }
}
```

2. Enabling monitoring:
```bash
kubectl apply -f assets/monitoring/
```

### Troubleshooting

1. Cluster Creation Issues
- Error: "Cannot create cluster due to insufficient permissions"
  ```bash
  aws sts get-caller-identity
  # Verify IAM permissions match prerequisites
  ```

2. Node Registration Issues
- Check node status:
  ```bash
  kubectl get nodes
  kubectl describe node <node-name>
  ```
- Verify IAM role attachments:
  ```bash
  aws iam list-attached-role-policies --role-name <node-role-name>
  ```

## Data Flow
The infrastructure implements a secure and scalable data flow for Kubernetes workloads.

```ascii
                                                    ┌──────────────┐
                                                    │   KMS Key    │
                                                    └──────┬───────┘
                                                          │
┌──────────┐     ┌─────────────┐     ┌──────────────┐    │    ┌──────────────┐
│  Client  │────▶│ ALB Ingress │────▶│ EKS Cluster  │◀───┴───▶│ Node Pools   │
└──────────┘     └─────────────┘     └──────────────┘         └──────────────┘
                                            │
                                     ┌──────┴───────┐
                                     │ CloudWatch   │
                                     │    Logs      │
                                     └──────────────┘
```

Key component interactions:
1. External traffic is routed through ALB Ingress Controller
2. EKS control plane manages workload distribution
3. Node pools auto-scale based on demand
4. All secrets are encrypted using KMS
5. Cluster operations are logged to CloudWatch

## Infrastructure

### IAM Resources
- EKS Cluster Role (`eks_cluster_role`)
  - Permissions: Cluster management, load balancing, networking
- Node Role (`eks_nodes_role`)
  - Permissions: Container registry access, CloudWatch logging

### Node Groups
The infrastructure supports multiple types of node groups to accommodate different workload requirements:

1. Standard Node Group
   - Uses on-demand instances
   - Supports x86_64 architecture
   - Amazon Linux 2 operating system
   - Auto-scaling configuration with min/max/desired nodes
   - Standard EBS volumes

2. Custom Node Group with Launch Template
   - SPOT instances for cost optimization
   - Customized EBS configuration (50GB gp3 volumes)
   - Custom user data script for node initialization
   - Amazon Linux operating system
   - EBS-optimized instances

3. Bottlerocket Node Group
   - SPOT instances
   - Bottlerocket OS (optimized for containers)
   - x86_64 architecture
   - Enhanced security with minimalist OS
   - Auto-scaling capabilities

4. Graviton Node Group
   - ARM64 architecture using AWS Graviton processors
   - SPOT instances
   - Supports t4g.large and c7g.large instance types
   - AL2023 ARM64 AMI
   - Cost-optimized for ARM workloads

5. Spot Node Group
   - Pure SPOT instance configuration
   - Flexible instance type selection
   - Cost-optimized for non-critical workloads
   - Auto-scaling with spot instance handling

Common features across all node groups:
- IAM role with policies for:
  - Container networking (CNI)
  - Container registry access
  - Systems Manager integration
  - CloudWatch monitoring
- Automatic scaling configuration
- Kubernetes labels for capacity management
- Integration with cluster autoscaler

### Compute Resources
- EKS Cluster
  - Version: Specified in variables
  - Logging: API, audit, authenticator, controllerManager, scheduler
  - Encryption: KMS-based for secrets

### Networking
- Security Groups
  - NodePorts (30000-32768)
  - CoreDNS (TCP/UDP 53)
- VPC Integration
  - Private subnets for nodes
  - Public subnets for load balancers

### Monitoring
- Kube State Metrics
- Metrics Server
- CloudWatch Integration