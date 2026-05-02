variable "vpc_and_subnet_info" {
  type = map(
    object({
      vpc = object({
        name                    = string
        auto_create_subnetworks = bool
        description             = string
      })
      subnetworks = map(object({
        name          = string
        ip_cidr_range = string
        secondary_ip_range = optional(list(object({
          name          = string
          ip_cidr_range = string
        })))
        private_ip_google_access = bool
      }))
    })
  )
}
