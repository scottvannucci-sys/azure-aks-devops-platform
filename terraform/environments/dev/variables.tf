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
