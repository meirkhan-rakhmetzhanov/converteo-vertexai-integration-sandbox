#####################################
# GCP HA VPN + ROUTER
#####################################

resource "google_compute_ha_vpn_gateway" "gcp-ha-vpn" {
  name    = "gcp-ha-vpn"
  network = google_compute_network.main-vpc-network.id
  region  = var.region
}

resource "google_compute_router" "gcp-router" {
  name    = "gcp-router"
  network = google_compute_network.main-vpc-network.name
  region  = var.region

  bgp {
    asn = var.gcp_asn
  }
}





#####################################
# AZURE NETWORK
#####################################

# resource "azurerm_resource_group" "rg" {
#   name     = "rg-vpn"
#   location = var.azure_location
# }

# resource "azurerm_virtual_network" "vnet" {
#   name                = "azure-vnet"
#   address_space       = ["10.20.0.0/16"]
#   location            = var.azure_location
#   resource_group_name = azurerm_resource_group.rg.name
# }

# resource "azurerm_subnet" "gateway_subnet" {
#   name                 = "GatewaySubnet"
#   resource_group_name  = azurerm_resource_group.rg.name
#   virtual_network_name = azurerm_virtual_network.vnet.name
#   address_prefixes     = ["10.20.255.0/27"]
# }

#####################################
# AZURE PUBLIC IPS
#####################################

# resource "azurerm_public_ip" "vpn_pip1" {
#   name                = "vpn-pip-1"
#   location            = var.azure_location
#   resource_group_name = azurerm_resource_group.rg.name
#   allocation_method   = "Static"
#   sku                 = "Standard"
# }

# resource "azurerm_public_ip" "vpn_pip2" {
#   name                = "vpn-pip-2"
#   location            = var.azure_location
#   resource_group_name = azurerm_resource_group.rg.name
#   allocation_method   = "Static"
#   sku                 = "Standard"
# }

#####################################
# AZURE VPN GATEWAY
#####################################

# resource "azurerm_virtual_network_gateway" "vpn" {
#   name                = "azure-vpn-gateway"
#   location            = var.azure_location
#   resource_group_name = azurerm_resource_group.rg.name

#   type     = "Vpn"
#   vpn_type = "RouteBased"
#   sku      = "VpnGw2"

#   active_active = true
#   enable_bgp    = true

#   ip_configuration {
#     name                          = "ipconf1"
#     public_ip_address_id          = azurerm_public_ip.vpn_pip1.id
#     private_ip_address_allocation = "Dynamic"
#     subnet_id                     = azurerm_subnet.gateway_subnet.id
#   }

#   ip_configuration {
#     name                          = "ipconf2"
#     public_ip_address_id          = azurerm_public_ip.vpn_pip2.id
#     private_ip_address_allocation = "Dynamic"
#     subnet_id                     = azurerm_subnet.gateway_subnet.id
#   }

#   bgp_settings {
#     asn = var.azure_asn
#   }
# }

#####################################
# GCP EXTERNAL GATEWAY (AZURE)
#####################################

resource "google_compute_external_vpn_gateway" "azure-gcp-gateway" {
  name            = "azure-gcp-gateway"
  redundancy_type = "TWO_IPS_REDUNDANCY"

  interface {
    id         = 0
    ip_address = var.AZURE_GW_IP_0
  }

  interface {
    id         = 1
    ip_address = var.AZURE_GW_IP_1
  }
}

#####################################
# GCP VPN TUNNELS
#####################################

resource "google_compute_vpn_tunnel" "gcp-azure-tunnels" {
  count = 2

  name                            = "gcp-tunnel-${count.index}"
  region                          = var.region
  vpn_gateway                     = google_compute_ha_vpn_gateway.gcp-ha-vpn.id
  vpn_gateway_interface           = count.index % 2
  peer_external_gateway           = google_compute_external_vpn_gateway.azure-gcp-gateway.id
  peer_external_gateway_interface = floor(count.index / 2)

  shared_secret = var.shared_secret
  router        = google_compute_router.gcp-router.id
}

#####################################
# GCP ROUTER INTERFACES + PEERS
#####################################
locals {
  bgp_sessions = {
    session1 = {
      interface_ip = "169.254.21.1/30"
      peer_ip      = "169.254.21.2"
    }
    session2 = {
      interface_ip = "169.254.22.1/30"
      peer_ip      = "169.254.22.2"
    }
  }
  session_index_map = {
    session1 = 0
    session2 = 1
  }
}









resource "google_compute_router_interface" "router_interface" {
  for_each   = local.bgp_sessions

  name       = "router-interface-${each.key}"
  router     = google_compute_router.gcp-router.name
  region     = var.region
  ip_range   = each.value.interface_ip
  vpn_tunnel = google_compute_vpn_tunnel.gcp-azure-tunnels[local.session_index_map[each.key]].name
}

resource "google_compute_router_peer" "router_peer" {
  for_each = local.bgp_sessions

  name            = "router-peer-${each.key}"
  router          = google_compute_router.gcp-router.name
  region          = var.region
  interface       = google_compute_router_interface.router_interface[each.key].name

  peer_ip_address = each.value.peer_ip
  peer_asn        = var.azure_asn
}

# resource "google_compute_router_peer" "router_peer" {
#   count   = 2
#   name    = "router-peer-${count.index}"
#   router  = google_compute_router.gcp-router.name
#   region  = var.region

#   interface       = google_compute_router_interface.router_interface[count.index].name
#   peer_asn        = var.azure_asn
#   peer_ip_address = "169.254.21.${count.index}"
# }



# resource "google_compute_router_peer" "router_peer" {
#   for_each = local.bgp_sessions

#   name   = "router-peer-${each.key}"
#   router = google_compute_router.gcp-router.name
#   region = var.region

#   interface = google_compute_router_interface.router_interface[each.key].name

#   peer_ip_address = each.value.peer_ip
#   peer_asn        = var.azure_asn
# }
#####################################
# AZURE LOCAL NETWORK GATEWAY (GCP)
#####################################

# resource "azurerm_local_network_gateway" "gcp" {
#   count               = 2
#   name                = "gcp-lng-${count.index}"
#   location            = var.azure_location
#   resource_group_name = azurerm_resource_group.rg.name

#   gateway_address = google_compute_ha_vpn_gateway.ha_vpn.vpn_interfaces[count.index].ip_address
#   address_space   = ["10.10.0.0/16"]

#   bgp_settings {
#     asn                 = var.gcp_asn
#     bgp_peering_address = "169.254.${count.index}.2"
#   }
# }

#####################################
# AZURE VPN CONNECTIONS (4)
#####################################

# resource "azurerm_virtual_network_gateway_connection" "conn" {
#   count               = 4
#   name                = "conn-${count.index}"
#   location            = var.azure_location
#   resource_group_name = azurerm_resource_group.rg.name

#   type                       = "IPsec"
#   virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn.id
#   local_network_gateway_id   = azurerm_local_network_gateway.gcp[floor(count.index / 2)].id

#   shared_key = var.shared_secret

#   enable_bgp = true
# }

