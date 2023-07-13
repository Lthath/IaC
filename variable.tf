variable "backendstrgrg" {
  type        = string
  description = "maleo"
  default     = "maleo"
}

variable "backendstrg" {
  type        = string
  description = "testmaquette"
  default     = "testmaquette"
}

variable "backendctn" {
  type = string
  description = "tfstate"
  default = "tfstate"
}

variable "backendstrgkey" {
  type = string
  description = "prod.terraform.tfstate"
  default = "prod.terraform.tfstate"
}

variable "resourcegroup_name" {
  type        = string
  description = "parcmaleo"
  default     = "parcmaleo"
}

variable "location" {
  type        = string
  description = "francecentral"
  default     = "francecentral"

}
variable "virtual_network_name" {
  type = string
  description = "vnet-ad"
  default = "vnet-ad"
}

variable "subnet_name"{
  type = string
  description = "AD"
  default = "AD"
}

variable "virtual_machine_name" {
  type = string 
  description = "DC-01"
  default = "DC-01"
}

variable "virtual_machine_size" {
  type = string
  description = "Standard_D2s_v3"
  default = "Standard_D2s_v3"
}

variable "virtual_machine_username" {
  type = string 
  description = "administrateur"
  default = "administrateur"
}

variable "virtual_machine_password" {
  type = string 
  description = "Passw0rdPassw0rd"
  default = "Passw0rdPassw0rd"
}