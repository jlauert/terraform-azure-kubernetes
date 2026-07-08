/**
 * # General notes
 *
 * When using more than one node pool, the load balancer sku "Basic" is not supported. It needs to be at least "Standard", see
 * https://docs.microsoft.com/azure/aks/use-multiple-node-pools
 *
 * All "System" mode pools must be able to reach all pods/subnets
 */

locals {
  cluster_name = "${lower(var.project)}${lower(var.stage)}k8s"
  has_automatic_channel_upgrade_maintenance_window = var.automatic_upgrade_channel != "none" ? [
    var.automatic_upgrade_channel
  ] : []
  has_automatic_node_channel_upgrade_maintenance_window = var.maintenance_window_auto_node_upgrade_enabled ? [
    var.automatic_node_upgrade_channel
  ] : []
  has_default_node_pool_upgrade_settings = var.default_node_pool_upgrade_settings_enabled == true ? [
    var.default_node_pool_upgrade_settings_enabled
  ] : []
}

# Log analytics required for OMS Agent result processing - usually other logging solutions are used. Hence the affected tfsec rule is
# ignored here
#
# IP limit for API is not really ignored, since the variable requires to enter something. However one can decide to disable the limitation
# and it would trigger the tfsec rule. Hence the affected tfsec rule is ignored here
#
#tfsec:ignore:azure-container-logging tfsec:ignore:azure-container-limit-authorized-ips
resource "azurerm_kubernetes_cluster" "k8s" {
  name                = local.cluster_name
  location            = var.location
  resource_group_name = var.resource_group
  tags                = var.tags
  dns_prefix          = var.dns_prefix == "NONE" ? local.cluster_name : var.dns_prefix
  sku_tier            = var.sku_tier
  kubernetes_version  = var.kubernetes_version

  image_cleaner_enabled        = var.image_cleaner_enabled
  image_cleaner_interval_hours = var.image_cleaner_interval_hours

  automatic_upgrade_channel = var.automatic_upgrade_channel != "none" ? var.automatic_upgrade_channel : null

  dynamic "upgrade_override" {
    for_each = var.force_upgrade_enabled == null ? [] : [var.force_upgrade_enabled]
    content {
      force_upgrade_enabled = upgrade_override.value
      effective_until       = var.force_upgrade_effective_until
    }
  }

  dynamic "maintenance_window_auto_upgrade" {
    for_each = local.has_automatic_channel_upgrade_maintenance_window
    content {
      frequency   = "Weekly"
      interval    = "1"
      duration    = var.maintenance_window_auto_upgrade_duration
      day_of_week = var.maintenance_window_auto_upgrade_day_of_week
      start_time  = var.maintenance_window_auto_upgrade_start_time
      utc_offset  = var.maintenance_window_auto_upgrade_utc_offset
    }
  }

  dynamic "maintenance_window_node_os" {
    for_each = local.has_automatic_node_channel_upgrade_maintenance_window
    content {
      frequency   = "Weekly"
      interval    = "1"
      duration    = var.maintenance_window_auto_node_upgrade_duration
      day_of_week = var.maintenance_window_auto_node_upgrade_day_of_week
      start_time  = var.maintenance_window_auto_node_upgrade_start_time
      utc_offset  = var.maintenance_window_auto_node_upgrade_utc_offset
    }
  }

  default_node_pool {
    name                        = var.default_node_pool_name
    type                        = "VirtualMachineScaleSets"
    node_count                  = var.node_count
    vm_size                     = var.vm_size
    os_disk_size_gb             = var.node_storage
    vnet_subnet_id              = var.subnet_id
    max_pods                    = var.max_pods
    orchestrator_version        = var.default_node_pool_k8s_version
    zones                       = var.availability_zones
    temporary_name_for_rotation = var.temporary_name_for_rotation
    auto_scaling_enabled        = var.auto_scaling_enabled
    min_count                   = var.auto_scaling_min_node_count
    max_count                   = var.auto_scaling_max_node_count
    dynamic "upgrade_settings" {
      for_each = local.has_default_node_pool_upgrade_settings
      content {
        max_surge                     = var.default_node_pool_upgrade_settings_max_surge
        drain_timeout_in_minutes      = var.default_node_pool_upgrade_settings_drain_timeout_in_minutes
        node_soak_duration_in_minutes = var.default_node_pool_node_soak_duration_in_minutes
      }
    }
  }

  dynamic "api_server_access_profile" {
    for_each = length(var.api_server_ip_ranges) > 0 ? [var.api_server_ip_ranges] : []
    content {
      authorized_ip_ranges = api_server_access_profile.value
    }
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control_enabled = var.rbac_enabled
  azure_active_directory_role_based_access_control {
    admin_group_object_ids = var.rbac_managed_admin_groups
    azure_rbac_enabled     = var.ad_rbac_enabled != null ? var.ad_rbac_enabled : var.rbac_enabled
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = var.network_policy
    load_balancer_sku = length(var.node_pools) > 0 ? "standard" : var.load_balancer_sku
    dynamic "load_balancer_profile" {
      for_each = azurerm_public_ip.public-ip-outbound
      content {
        outbound_ip_address_ids  = azurerm_public_ip.public-ip-outbound[*].id
        outbound_ports_allocated = var.outbound_ports_allocated
        idle_timeout_in_minutes  = var.idle_timeout
      }
    }
  }

  dynamic "linux_profile" {
    for_each = var.ssh_public_key == "" ? [] : [var.ssh_public_key]
    content {
      admin_username = var.project
      ssh_key {
        key_data = linux_profile.value
      }
    }
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "additional" {
  for_each = var.node_pools

  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
  name                  = each.key
  node_count            = each.value.count
  vm_size               = each.value.vm_size
  os_disk_size_gb       = each.value.os_disk_size_gb
  vnet_subnet_id        = var.subnet_id
  node_labels           = each.value.node_labels
  max_pods              = each.value.max_pods
  orchestrator_version  = each.value.k8s_version
  mode                  = each.value.mode
  node_taints           = each.value.taints
  zones                 = each.value.availability_zones
}

resource "azurerm_public_ip" "public-ip-outbound" {
  count = var.static_outbound_ip_count

  name                = "${local.cluster_name}ippublicoutbound${count.index}"
  allocation_method   = "Static"
  location            = var.location
  resource_group_name = var.resource_group
  sku                 = "Standard"
}
