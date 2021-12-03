variable "access_key" {}
variable "secret_key" {}
variable "sub_id" {}
variable "tenant_id" {}
variable "rg_name" {
  type        = string
  default     = "DemoRG"
  description = "its a Default RG name"
}
variable "loc" {
  type        = string
  default     = "eastus"
}
variable "env" {
  type        = string
  default     = "dev"
}
variable "vnet_name" {}
variable "vnet_address" {}
variable "subnet1_name" {}
variable "subnet1_prefix" {}
variable "subnet2_name" {}
variable "subnet2_prefix" {}
variable "subnet3_name" {}
variable "subnet3_prefix" {}
variable "mypip" {}
variable "nsg_name" {}
variable "vm_name" {}
variable "vm_size" {
      default = "Standard_B1s"
     # for windows default = "Standard_DS3_v2"
}
variable "username" {
  default     = "adminuser"
}
variable "password" {
   default     = "Passw0rd@123"
}
variable "publisher" {
   default     = "Canonical"
   # for windows default = "MicrosoftWindowsServer"
}
variable "offer" {
   default     = "UbuntuServer"
   # for windows default = "WindowsServer"
}
variable "sku" {
   default     = "18.04-LTS"
   # for windows default = "2016-Datacenter"
}




