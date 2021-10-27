variable "ip_rules" {
  type    = list(string)
  default = ["10.0.0.0/17", "192.168.0.0/16"]
}