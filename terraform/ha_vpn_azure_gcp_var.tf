variable "gcp_asn" {
  type    = number
  default = 65530
}

variable "azure_asn" {
  type    = number
  default = 65531
}


variable "AZURE_GW_IP_0" {
  type    = string
  default = "98.64.177.249"
}
variable "AZURE_GW_IP_1" {
  type    = string
  default = "108.142.38.164"
}

#openssl rand -base64 32
variable "shared_secret" {
  type    = string
  default = "0AwwSpM32ZG6QzwjryRY8tbyfjLOYSWhyXZTQXsClr0="
}
