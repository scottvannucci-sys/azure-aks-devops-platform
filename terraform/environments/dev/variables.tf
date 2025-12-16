variable "location" {
  type    = string
  default = "eastus"
}

variable "prefix" {
  type    = string
  default = "sv-aksplat-dev"
}

variable "kubernetes_version" {
  type    = string
  default = null
}

variable "node_count" {
  type    = number
  default = 2
}

variable "node_vm_size" {
  type    = string
  default = "Standard_B2s"
}

variable "aks_admin_group_object_ids" {
  type        = list(string)
  description = "Azure AD group object IDs to be AKS cluster admins."
  default     = []
}