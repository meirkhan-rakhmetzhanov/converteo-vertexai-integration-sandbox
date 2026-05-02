# variable "project_id" {
#   type = string
# }

# variable "region" {
#   type    = string
#   default = "europe-west4"
# }

# variable "endpoint_name" {
#   type = string
# }

# variable "network_self_link" {
#   type = string
#   description = "Self link du VPC"
# }

# variable "subnet_self_link" {
#   type = string
#   description = "Self link du subnet"
# }
variable "service_account_info" {
  type = object({
    name        = string
    suffix      = string
    description = string
    disabled    = bool
  })
}