variable "project" {
  type        = string
  description = "Three letter project key"
}

variable "stage" {
  type        = string
  description = "Stage for this ip"
}

variable "location" {
  type        = string
  description = "Azure location to use"
}

variable "resource_group" {
  type        = string
  description = "Azure Resource Group to use"
}

variable "tags" {
  type        = map(any)
  description = "Map of tags for the resources"
  default     = {}
}

variable "dns_prefix" {
  type        = string
  description = "DNS-Prefix to use. Defaults to cluster name"
  default     = "NONE"
}

variable "node_count" {
  type        = string
  description = "Number of Kubernetes cluster nodes to use"
}

variable "vm_size" {
  type        = string
  description = "Type of vm to use. Use az vm list-sizes --location <location> to list all available sizes"
}

variable "kubernetes_version" {
  type        = string
  description = "Version of kubernetes of the control plane"
}

variable "subnet_id" {
  type        = string
  description = "ID of subnet to host the nodes, pods and services in."
}

variable "node_storage" {
  type        = string
  description = "Disk size in GB"
  default     = "30"
}

variable "rbac_enabled" {
  type        = bool
  description = "Enables RBAC on the cluster. If true, rbac_managed_admin_groups have to be specified."
  default     = true
}

variable "ad_rbac_enabled" {
  type        = bool
  description = <<-EOF
    Defines RBAC for block azure_active_directory_role_based_access_control explicitly if set.
    Else RBAC for block azure_active_directory_role_based_access_control is set by "rbac_enabled"
  EOF
  default     = null
}

variable "rbac_managed_admin_groups" {
  type        = list(string)
  description = "The group IDs that have admin access to the cluster. Have to be specified if rbac_enabled is true"
}

variable "default_node_pool_name" {
  type        = string
  description = "Name of the default node pool"
  default     = "default"
}

variable "default_node_pool_k8s_version" {
  type        = string
  description = "Version of kubernetes for the default node pool"
}

variable "node_pools" {
  type = map(object({
    vm_size : string,
    count : number,
    os_disk_size_gb : number,
    k8s_version : string,
    node_labels : map(string),
    max_pods : number,
    mode : string,
    taints : list(string),
    availability_zones : list(number)
  }))
  default     = {}
  description = "Additional node pools to set up"
}

variable "auto_scaling_enabled" {
  type        = bool
  description = "Enable auto-scaling of node pool"
  default     = false
}

variable "auto_scaling_min_node_count" {
  type        = string
  description = "Enable auto-scaling of node pool"
  default     = "1"
}

variable "auto_scaling_max_node_count" {
  type        = string
  description = "Enable auto-scaling of node pool"
  default     = "1"
}

variable "load_balancer_sku" {
  type        = string
  description = "The SKU for the used Load Balancer"
  default     = "basic"
}

variable "max_pods" {
  type        = string
  description = "Amount of pods allowed on each node (be aware that kubernetes system pods are also counted"
  default     = "30"
}

variable "availability_zones" {
  type        = list(number)
  description = "availability zones to spread the cluster nodes across, if omitted, only one avilability zone is used"
  default     = []
}

variable "temporary_name_for_rotation" {
  type        = string
  description = "Specifies the name of the temporary node pool used to cycle the default node pool for VM resizing."
  validation {
    condition     = var.temporary_name_for_rotation != null
    error_message = "The temporary_name_for_rotation value must not be null"
  }
  default = "rotationtmp"
}

variable "sku_tier" {
  type    = string
  default = "Free"
}

variable "static_outbound_ip_count" {
  type        = number
  description = <<EOF
    On a lot of outgoing connections use this together with the maximum for outbound_ports_allocated of 64000 to not fall into network
    bottlenecks. Recommended in that case is to set the count at least +5 more than the count of kubernetes nodes.
  EOF
  validation {
    condition     = var.static_outbound_ip_count >= 0 && var.static_outbound_ip_count <= 100
    error_message = "Static_outbound_ip_count has to be between 0 and 100 including."
  }
  default = 0
}

variable "outbound_ports_allocated" {
  type        = number
  description = "Pre-allocated ports (AKS default: 0)"
  validation {
    condition     = var.outbound_ports_allocated >= 0 && var.outbound_ports_allocated <= 64000
    error_message = "Outbound_ports_allocated has to be between 0 and 64000 including."
  }
  default = 0
}

variable "network_policy" {
  type        = string
  description = "Network policy to use, currently only azure and callico are supported"
  default     = "azure"
}

variable "idle_timeout" {
  type        = number
  description = "Desired outbound flow idle timeout in minutes for the cluster load balancer. Must be between 4 and 120 inclusive."
  default     = 5
  validation {
    condition     = var.idle_timeout >= 4 && var.idle_timeout <= 120
    error_message = "Idle_timeout has to be between 4 and 120 including."
  }
}

variable "ssh_public_key" {
  type        = string
  default     = ""
  description = "SSH public key to access the kubernetes node with"
}

variable "api_server_ip_ranges" {
  type        = list(string)
  description = "The IP ranges to allow for incoming traffic to the server nodes. To disable the limitation, set an empty list as value (default)."
  default     = []
}

variable "managed_identity_security_group" {
  type        = string
  default     = ""
  description = <<-EOF
    The name of a group which is assigned to appropriate roles in the subscription to manage resources that are required by the AKS.
    Setting this to a non empty string will add the AKS managed identity to this group.

    You need the following API permissions (with admin consent) on a service prinicpal to make this work:

    * Directory.Read.All
    * Group.Read.All
    * Group.ReadWrite.All
  EOF
}

variable "azure_container_registry_ids" {
  type        = list(string)
  default     = []
  description = <<-EOF
    IDs of the azure container registries that the AKS should have pull access to
  EOF
}

variable "image_cleaner_enabled" {
  description = "Azure default settings"
  type        = bool
  default     = false
}

variable "image_cleaner_interval_hours" {
  description = "Azure default settings"
  type        = number
  default     = 48
}

variable "automatic_upgrade_channel" {
  type        = string
  default     = "none"
  description = <<-EOF
    Values:
    none, patch, stable, rapid, node-image
    see https://learn.microsoft.com/en-us/azure/aks/auto-upgrade-cluster
  EOF
}

variable "maintenance_window_auto_upgrade_day_of_week" {
  type        = string
  default     = "Monday"
  description = <<-EOF
    see https://learn.microsoft.com/en-us/azure/aks/planned-maintenance#creating-a-maintenance-window
  EOF
}

variable "maintenance_window_auto_upgrade_duration" {
  type        = string
  default     = "4"
  description = <<-EOF
    see https://learn.microsoft.com/en-us/azure/aks/planned-maintenance#creating-a-maintenance-window
  EOF
}

variable "maintenance_window_auto_upgrade_start_time" {
  type        = string
  default     = "04:00"
  description = <<-EOF
    Example: "04:00"
    see https://learn.microsoft.com/en-us/azure/aks/planned-maintenance#creating-a-maintenance-window
  EOF
}

variable "maintenance_window_auto_upgrade_utc_offset" {
  type        = string
  default     = "+00:00"
  description = <<-EOF
    Example: "+00:00"
    see https://learn.microsoft.com/en-us/azure/aks/planned-maintenance#creating-a-maintenance-window
  EOF
}

variable "maintenance_window_auto_node_upgrade_enabled" {
  type        = bool
  default     = false
  description = "Defines whether to add a schedule for node updates"
}

variable "automatic_node_upgrade_channel" {
  type        = string
  default     = "NodeImage"
  description = <<-EOF
    Values:
    None, Unmanaged, SecurityPatch, NodeImage
    see https://learn.microsoft.com/en-us/azure/aks/auto-upgrade-node-os-image
  EOF
}

variable "maintenance_window_auto_node_upgrade_day_of_week" {
  type        = string
  default     = "Monday"
  description = <<-EOF
    see https://learn.microsoft.com/en-us/azure/aks/planned-maintenance#creating-a-maintenance-window
  EOF
}

variable "maintenance_window_auto_node_upgrade_duration" {
  type        = string
  default     = "4"
  description = <<-EOF
    see https://learn.microsoft.com/en-us/azure/aks/planned-maintenance#creating-a-maintenance-window
  EOF
}

variable "maintenance_window_auto_node_upgrade_start_time" {
  type        = string
  default     = "04:00"
  description = <<-EOF
    Example: "04:00"
    see https://learn.microsoft.com/en-us/azure/aks/planned-maintenance#creating-a-maintenance-window
  EOF
}

variable "maintenance_window_auto_node_upgrade_utc_offset" {
  type        = string
  default     = "+00:00"
  description = <<-EOF
    Example: "+00:00"
    see https://learn.microsoft.com/en-us/azure/aks/planned-maintenance#creating-a-maintenance-window
  EOF
}

variable "default_node_pool_upgrade_settings_enabled" {
  type        = bool
  default     = false
  description = <<-EOF
    If true, an upgrade_settings block will be added to default_node_pool.
  EOF
}

variable "default_node_pool_upgrade_settings_max_surge" {
  type        = string
  default     = "10%"
  description = <<-EOF
    max_surge is a required parameter for an upgrade_settings block
    Example: "10%"
    see https://learn.microsoft.com/en-us/azure/aks/upgrade-aks-cluster?tabs=azure-cli#customize-node-surge-upgrade
  EOF
}

variable "default_node_pool_upgrade_settings_drain_timeout_in_minutes" {
  type        = number
  description = <<-EOF
    drain_timeout_in_minutes is a optional parameter for an upgrade_settings block
    Example: "30"
    see https://learn.microsoft.com/en-us/azure/aks/upgrade-aks-cluster?tabs=azure-cli#set-node-drain-timeout-value
  EOF
  validation {
    condition     = var.default_node_pool_upgrade_settings_drain_timeout_in_minutes >= 0 && var.default_node_pool_upgrade_settings_drain_timeout_in_minutes <= 60
    error_message = "default_node_pool_upgrade_settings_drain_timeout_in_minutes has to be between 0 and 60 including."
  }
  default = 30
}

variable "default_node_pool_node_soak_duration_in_minutes" {
  type        = number
  description = <<-EOF
    soak_duration_in_minutes is a optional parameter for an upgrade_settings block
    Example: "30"
    see https://learn.microsoft.com/en-us/azure/aks/upgrade-aks-cluster?tabs=azure-cli#set-node-soak-time-value
  EOF
  validation {
    condition     = var.default_node_pool_node_soak_duration_in_minutes >= 0 && var.default_node_pool_node_soak_duration_in_minutes <= 60
    error_message = "default_node_pool_node_soak_duration_in_minutes has to be between 0 and 60 including."
  }
  default = 0
}

variable "force_upgrade_enabled" {
  description = "Azure default settings"
  type        = bool
  default     = false
}
