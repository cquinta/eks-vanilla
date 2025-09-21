variable "project_name" {
}

variable "region" {
  default = "us-east-1"
}

variable "k8s_version" {
  default = "1.33"
}

variable "ssm_vpc" {}

variable "ssm_subnets" {
  type = list(string)
}

variable "node_group_temp_desired" {
  type    = number
  default = 2
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

