data "azurerm_resource_group" "pocboomirg" {
  name = var.aks_resource_group
}

data "azurerm_subnet" "subnetaks" {
  name                 = var.aks_subnet_name
  virtual_network_name = var.aks_vnet_name
  resource_group_name  = var.aks_subnet_resource_group
}

data "azurerm_private_dns_zone" "aksdns" {
  count               = var.aks_dns_zone_enable ? 1 : 0
  name                = var.aks_dns_zone_name 
  resource_group_name = var.aks_dns_zone_rg 
}

data "azurerm_user_assigned_identity" "aksidentity" {
  count               = var.aks_assigned_identity_enable ? 1 : 0
  name                = var.aks_assigned_identity_name 
  resource_group_name = var.aks_assigned_identity_rg 
}

data "azuread_group" "aksadmin" {
  count            = length(var.aks_agent_admin_group)
  display_name     = var.aks_agent_admin_group[count.index] #"IT_133-SG-EC-IT-A-ADMINS"
  security_enabled = true
}
resource "azurerm_kubernetes_cluster" "aks01" {
  name                = var.aks_name
  location            = data.azurerm_resource_group.pocboomirg.location
  resource_group_name = data.azurerm_resource_group.pocboomirg.name

  private_cluster_enabled       = true
  public_network_access_enabled = false
  private_dns_zone_id           = var.aks_dns_zone_enable ? data.azurerm_private_dns_zone.aksdns[0].id : null
  dns_prefix                    = "${var.aks_name}"
  node_resource_group           = var.aks_node_resource_group
  automatic_channel_upgrade     = "patch"
  sku_tier                      = var.aks_sku

  network_profile {
    network_plugin     = "azure"              # CNI
    outbound_type      = "userDefinedRouting" # no public ip
    service_cidr       = "10.0.0.0/16"
    dns_service_ip     = "10.0.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
  }

  default_node_pool {
    name                = var.aks_agent_pool_name
    node_count          = var.aks_agent_pool_node_count
    max_pods            = var.aks_agent_pool_max_pods
    vm_size             = var.aks_agent_pool_vm_size
    enable_auto_scaling = true
    max_count           = var.aks_agent_pool_max_count
    min_count           = var.aks_agent_pool_min_count
    vnet_subnet_id      = data.azurerm_subnet.subnetaks.id 
    zones               = var.aks_agent_pool_zones
  }

  azure_active_directory_role_based_access_control {
    managed                = true
    #admin_group_object_ids = var.aks_agent_admin_group
    admin_group_object_ids = data.azuread_group.aksadmin[*].object_id
    azure_rbac_enabled     = true
  }

  identity {
    type = var.aks_assigned_identity_enable ? "UserAssigned" : "SystemAssigned"
    identity_ids = var.aks_assigned_identity_enable ? [data.azurerm_user_assigned_identity.aksidentity[0].id] : null
  }

  tags = var.aks_agent_tags
}

/*
data "azurerm_subnet" "subnetpool" {
  for_each = {for i, v in var.aks_agent_nodes:  i => v}
  name                 = each.value.subnet
  virtual_network_name = var.aks_vnet_name
  resource_group_name  = var.aks_subnet_resource_group
}
output "subnet_id" {
   value = tomap({
    for inst in data.azurerm_subnet.subnetpool : inst.name => inst.id
  })  
}
*/
resource "azurerm_kubernetes_cluster_node_pool" "applications" {
  for_each = {for i, v in var.aks_agent_nodes:  i => v}
  name                  = each.value.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks01.id
  vm_size               = each.value.vm_size # "Standard_D4s_v4"
  mode                  = "User"
  os_type               = "Linux"
  node_count            = each.value.node_count
  enable_auto_scaling   = true
  max_count             = each.value.max_count
  min_count             = each.value.min_count
  max_pods              = each.value.max_pods
  vnet_subnet_id        = data.azurerm_subnet.subnetaks.id # EC-SubNet-AKS001-NPE
  zones                 = var.aks_agent_pool_zones
  #pod_subnet_id         = each.value.subnet != "" ? data.azurerm_subnet.subnetpool[each.key].id : null

  tags = var.aks_agent_tags
}
