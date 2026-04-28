resource "google_compute_network" "main-vpc-network" {
  name                    = var.vpc_and_subnet_info.main-network.vpc.name
  auto_create_subnetworks = var.vpc_and_subnet_info.main-network.vpc.auto_create_subnetworks
  project                 = google_project.saintgobain-sdx.project_id
  description             = var.vpc_and_subnet_info.main-network.vpc.description
}

resource "google_compute_subnetwork" "main-vpc-subnetworks" {
  for_each = {
    for subn_key, subn_info in var.vpc_and_subnet_info.main-network.subnetworks :
    subn_key => subn_info
  }
  name          = each.value.name
  ip_cidr_range = each.value.ip_cidr_range
  region        = var.region
  dynamic "secondary_ip_range" {
    for_each = each.value.secondary_ip_range

    content {
      range_name    = secondary_ip_range.value.name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }
  private_ip_google_access = each.value.private_ip_google_access
  network                  = google_compute_network.main-vpc-network.id
  project                  = google_project.saintgobain-sdx.project_id

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

#add restriction to firewall defaults rules 
resource "google_compute_firewall" "main-vpc-network-firewall-restriction" {
  name     = "main-vpc-network-firewall-restriction"
  network  = google_compute_network.main-vpc-network.name
  #ssh
  deny {
    protocol = "tcp"
    ports    = ["22"]
  }
  #rdp
  deny {
    protocol = "tcp"
    ports    = ["3389"]
  }

  #http
  deny {
    protocol = "tcp"
    ports    = ["80"]
  }
  #MongoDB
  deny {
    protocol = "tcp"
    ports    = ["27017"]
  }

  #MySQL
  deny {
    protocol = "tcp"
    ports    = ["3306"]
  }

  #Telnet
  deny {
    protocol = "tcp"
    ports    = ["23"]
  }

  #PostgreSQL
  deny {
    protocol = "tcp"
    ports    = ["5432"]
  }

  #FTP
  deny {
    protocol = "tcp"
    ports    = ["21"]
  }
  #oracle 
  deny {
    protocol = "tcp"
    ports    = ["1521"]
  }
  #smtp
  deny {
    protocol = "tcp"
    ports    = ["25"]
  }
  priority = 90
  source_ranges = ["0.0.0.0/0"]
  project       = google_project.saintgobain-sdx.project_id
}



#add authorisatioin  to firewall to  main-vpc-network on specific port
resource "google_compute_firewall" "main-vpc-network-firewall-authorisatioin" {
  name     = "main-vpc-network-firewall-authorisatioin"
  network  = google_compute_network.main-vpc-network.name
  #mysql
  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }
  #ssh
  allow {
    protocol = "tcp"
    ports    = ["22", "3389", "2022" ,"8080"]
  }
  #EO SFTP
  allow {
    protocol = "tcp"
    ports    = ["2124"]
  }

  priority      = 50
  direction     = "INGRESS"
  source_ranges = ["10.10.0.0/16", "10.11.0.0/16", "10.12.0.0/16" ,"10.13.0.0/16", "10.14.0.0/16", 
  "35.235.240.0/20" #all IP addresses that IAP uses for TCP forwarding
  ]
  project       = google_project.saintgobain-sdx.project_id
 
}








