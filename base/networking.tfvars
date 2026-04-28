vpc_and_subnet_info = {
  main-network = {
    vpc = {
      name                    = "main-network"
      auto_create_subnetworks = false
      description             = " VPC for all networking ."
    }
    subnetworks = {
      subnetwork_alpha = {
        name          = "subnetwork-alpha"
        ip_cidr_range = "10.10.0.0/16" # Primary IP Range : 65536 Ips available within this VPC
        secondary_ip_range = [
          {
            name          = "subnetwork-alpha-secondary-range"
            ip_cidr_range = "10.11.0.0/16" # Secondary IP Range:yes 65536 Ips available within this VPC
          }
        ]
        private_ip_google_access = true
      }
      subnetwork_for_prod= {
        name          = "subnetwork-prod"
        ip_cidr_range = "10.12.0.0/16" # Primary IP Range : 65536 Ips available within this VPC
        secondary_ip_range = [
          {
            name          = "subnetwork-prod-first"
            ip_cidr_range = "10.13.0.0/16" # Secondary IP Range:yes 65536 Ips available within this VPC
          },
          {
            name          = "subnetwork-prod-second"
            ip_cidr_range = "10.14.0.0/16" # Secondary IP Range:yes 65536 Ips available within this VPC
          }
        ]
        private_ip_google_access = true
      }

    }
  },
}

