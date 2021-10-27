locals {

  ip_ranges_subnet_intranet = ["10.1.2.0/26"]
  ip_ranges_subnet_back = ["10.1.2.64/26"]
  ip_ranges_subnet_core = ["10.1.2.128/27"]
  ip_ranges_subnet_ase = ["10.1.2.192/26"]

  ip_ranges_office = ["10.200.200.0/22"]
  ip_ranges_everyone = ["10.0.0.0/8","172.16.0.0/12"]
  ip_ranges_domain_controler = ["10.100.100.1","10.100.100.2"]
  
  ports_range_office = ["22","80","135","137","139","443","445","1433","1434","3389","20604"]
  ports_range_admin = ["22","445","3389","5985","5986","20000-20010","20604","49660-49670"]
  ports_range_dc_in = ["135","137","445","3389"]

  vnet_nsgs            = [ 
      {name ="nsg_front", 
      security_rule = [ 
        { name = "global_icmp_allow", priority = "105", direction = "Inbound", access = "Allow", protocol = "ICMP", dest_port = [], src_port = [], src_ip = local.ip_ranges_everyone, dest_ip = local.ip_ranges_subnet_intranet, description = ""  },
        { name = "global_http_allow", priority = "110", direction = "Inbound", access = "Allow", protocol = "tcp", dest_port = ["80","443"], src_port = [], src_ip = local.ip_ranges_everyone, dest_ip = local.ip_ranges_subnet_intranet, description = "" },
        { name = "all_inbound_deny", priority = "4000", direction = "Inbound", access = "Deny", protocol = "*", dest_port = [], src_port = [], src_ip = [], dest_ip = [], description = "" }
        ] },
      {name ="nsg_back", 
      security_rule = [ 
        { name = "global_icmp_allow", priority = "105", direction = "Inbound", access = "Allow", protocol = "ICMP", dest_port = [], src_port = [], src_ip = local.ip_ranges_everyone, dest_ip = local.ip_ranges_subnet_back, description = ""  },
        { name = "global_http_allow", priority = "110", direction = "Inbound", access = "Allow", protocol = "tcp", dest_port = ["80","443"], src_port = [], src_ip = local.ip_ranges_everyone, dest_ip = local.ip_ranges_subnet_back, description = "" },
        { name = "all_inbound_deny", priority = "4000", direction = "Inbound", access = "Deny", protocol = "*", dest_port = [], src_port = [], src_ip = [], dest_ip = [], description = "" }
        ] },
      {name ="nsg_core", 
      security_rule = [ 
        { name = "global_icmp_allow", priority = "105", direction = "Inbound", access = "Allow", protocol = "ICMP", dest_port = [], src_port = [], src_ip = local.ip_ranges_everyone, dest_ip = local.ip_ranges_subnet_core, description = ""  },
        { name = "global_http_allow", priority = "110", direction = "Inbound", access = "Allow", protocol = "tcp", dest_port = ["80","443"], src_port = [], src_ip = local.ip_ranges_everyone, dest_ip = local.ip_ranges_subnet_core, description = "" },
        { name = "all_inbound_deny", priority = "4000", direction = "Inbound", access = "Deny", protocol = "*", dest_port = [], src_port = [], src_ip = [], dest_ip = [], description = "" }
         ] },
      {name ="nsg_ase", 
      security_rule = [ 
        { name = "global_icmp_allow", priority = "105", direction = "Inbound", access = "Allow", protocol = "ICMP", dest_port = [], src_port = [], src_ip = local.ip_ranges_everyone, dest_ip = local.ip_ranges_subnet_core, description = ""  },
        { name = "global_http_allow", priority = "110", direction = "Inbound", access = "Allow", protocol = "tcp", dest_port = ["80","443"], src_port = [], src_ip = local.ip_ranges_everyone, dest_ip = local.ip_ranges_subnet_core, description = "" },
        { name = "all_inbound_deny", priority = "4000", direction = "Inbound", access = "Deny", protocol = "*", dest_port = [], src_port = [], src_ip = [], dest_ip = [], description = "" }
        ] },
        ]
}