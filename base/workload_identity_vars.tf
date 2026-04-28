variable "azure_tenant_id" {
  type    = string
  default = "30131f05-99e7-440a-a5e9-d3e8201e730c"
}

variable "azure_application" {
  type    = string
  default = "api://f51eb1bf-8eb1-46a3-86cb-fa2c07a0f3cd"
}

variable "azure_client_id" {
  type    = string
  # managed identity id in azure wich is added to azure VM
  #default = "7ada3266-1592-406f-862a-e006c77ecbb7"
  # the application id 
  default = "f51eb1bf-8eb1-46a3-86cb-fa2c07a0f3cd"
}


