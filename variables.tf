variable "project_name" {
  type        = string
  description = "Nome do projeto / cluster"
}

variable "region" {
  type        = string
  description = "Nome da região onde os recursos serão entregues"
}

variable "ssm_vpc" {
  type        = string
  description = "ID do SSM onde está o id da VPC onde o projeto será criado"
}

variable "ssm_public_subnets" {
  type        = list(string)
  description = "Lista dos ID's do SSM onde estão as subnets públicas do projeto"
}

variable "ssm_private_subnets" {
  type        = list(string)
  description = "Lista dos ID's do SSM onde estão as subnets privadas do projeto"
}

variable "ssm_pods_subnets" {
  type        = list(string)
  description = "Lista dos ID's do SSM onde estão as subnets de pods do projeto"
}

variable "k8s_version" {
  type        = string
  description = "versão do kubernetes"
}

variable "auto_scale_options" {
  type = object({
    min     = number
    max     = number
    desired = number
  })
  description = "Configurações de Autoscaling do Cluster"
}



variable "nodes_instance_sizes" {
  type        = list(string)
  description = "Lista de tamanhos das instâncias do projeto"
}

variable "addon_cni_version" {
  type        = string
  default     = "v1.19.2-eksbuild.1"
  description = "Versão do Addon da VPC CNI"
}

variable "addon_coredns_version" {
  type        = string
  default     = "v1.11.4-eksbuild.2"
  description = "Versão do Addon do CoreDNS"
}

variable "addon_kubeproxy_version" {
  type        = string
  default     = "v1.32.0-eksbuild.2"
  description = "Versão do Addon do Kube-Proxy"
}

variable "custom_ami" {
  type        = string
  description = "AMI ID customizada para os nodes"
  default     = "ami-03571be2203184664"
}

variable "karpenter_capacity" {
  type = list(object({
    name               = string
    workload           = string
    ami_family         = string
    ami_ssm            = string
    instance_family    = list(string)
    instance_sizes     = list(string)
    capacity_type      = list(string)
    availability_zones = list(string)
  }))
}

variable "dns_name" {
  type        = string
  description = "Nome do DNS"
  default     = "*.cquinta.com"
}

variable "route53_hosted_zone" {
  type    = string
  default = "Z040960237M3RMXIT1WRJ"
}



variable "addon_pod_identity_version" {
  type        = string
  default     = "v1.3.4-eksbuild.1"
  description = "Versão do Addon do Pod Identity"
}



variable "addon_efs_csi_version" {
  type        = string
  default     = "v2.1.8-eksbuild.1"
  description = "Versão do Addon do EFS CSI"

}

variable "grafana_host" {
  type        = string
  default     = "grafana.cquinta.com"
  description = "Host do Grafana"
}

variable "istio_version" {
  type        = string
  description = "Versão do Istio"
  default     = "1.25.0"
}

variable "istio_min_replicas" {
  type        = string
  description = "value of min replicas"
  default     = "3"
}

variable "istio_max_replicas" {
  type        = string
  description = "value of min replicas"
  default     = "6"
}

variable "istio_cpu_threshold" {
  type        = string
  description = "value of cpu threshold"
  default     = "60"
}

variable "jaeger_host" {
  type        = string
  description = "Host do Jaeger"
  default     = "jaeger.cquinta.com"
}

variable "kiali_host" {
  type        = string
  description = "Host do Kiali"
  default     = "kiali.cquinta.com"
}

variable "kiali_version" {
  type        = string
  description = "value of kiali version"
  default     = "2.5"
} 