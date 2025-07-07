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

variable "addon_pod_identity_version" {
  type        = string
  default     = "v1.3.4-eksbuild.1"
  description = "Versão do Addon do Pod Identity"
}

