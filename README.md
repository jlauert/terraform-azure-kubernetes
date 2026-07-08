# Azure Kubernetes Services

## Introduction

This module manages a Azure Kubernetes Services cluser. Besides the cluster itself it manages a defined amount of outbound IPs

## Usage

Instantiate the module by calling it from Terraform like this:

```hcl
module "azure-k8s" {
  source  = "dodevops/kubernetes/azure"
  version = "<version>"
}
```

<!-- BEGIN_TF_DOCS -->
# General notes

When using more than one node pool, the load balancer sku "Basic" is not supported. It needs to be at least "Standard", see
https://docs.microsoft.com/azure/aks/use-multiple-node-pools

All "System" mode pools must be able to reach all pods/subnets

## Requirements

The following requirements are needed by this module:

- terraform (>=1.0.0)

- azuread (>=2.41.0)

- azurerm (>=3.63.0)

## Providers

The following providers are used by this module:

- azuread (>=2.41.0)

- azurerm (>=3.63.0)

## Modules

No modules.

## Resources

The following resources are used by this module:

- [azuread_group_member.k8smember](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group_member) (resource)
- [azurerm_kubernetes_cluster.k8s](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) (resource)
- [azurerm_kubernetes_cluster_node_pool.additional](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) (resource)
- [azurerm_public_ip.public-ip-outbound](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) (resource)
- [azurerm_role_assignment.aksacr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azuread_group.ownersgroup](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) (data source)

## Required Inputs

The following input variables are required:

### default\_node\_pool\_k8s\_version

Description: Version of kubernetes for the default node pool

Type: `string`

### kubernetes\_version

Description: Version of kubernetes of the control plane

Type: `string`

### location

Description: Azure location to use

Type: `string`

### node\_count

Description: Number of Kubernetes cluster nodes to use

Type: `string`

### project

Description: Three letter project key

Type: `string`

### rbac\_managed\_admin\_groups

Description: The group IDs that have admin access to the cluster. Have to be specified if rbac\_enabled is true

Type: `list(string)`

### resource\_group

Description: Azure Resource Group to use

Type: `string`

### stage

Description: Stage for this ip

Type: `string`

### subnet\_id

Description: ID of subnet to host the nodes, pods and services in.

Type: `string`

### vm\_size

Description: Type of vm to use. Use az vm list-sizes --location <location> to list all available sizes

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### ad\_rbac\_enabled

Description: Defines RBAC for block azure\_active\_directory\_role\_based\_access\_control explicitly if set.  
Else RBAC for block azure\_active\_directory\_role\_based\_access\_control is set by "rbac\_enabled"

Type: `bool`

Default: `null`

### api\_server\_ip\_ranges

Description: The IP ranges to allow for incoming traffic to the server nodes. To disable the limitation, set an empty list as value (default).

Type: `list(string)`

Default: `[]`

### auto\_scaling\_enabled

Description: Enable auto-scaling of node pool

Type: `bool`

Default: `false`

### auto\_scaling\_max\_node\_count

Description: Enable auto-scaling of node pool

Type: `string`

Default: `"1"`

### auto\_scaling\_min\_node\_count

Description: Enable auto-scaling of node pool

Type: `string`

Default: `"1"`

### automatic\_node\_upgrade\_channel

Description: Values:  
None, Unmanaged, SecurityPatch, NodeImage  
see https://learn.microsoft.com/en-us/azure/aks/auto-upgrade-node-os-image

Type: `string`

Default: `"NodeImage"`

### automatic\_upgrade\_channel

Description: Values:  
none, patch, stable, rapid, node-image  
see https://learn.microsoft.com/en-us/azure/aks/auto-upgrade-cluster

Type: `string`

Default: `"none"`

### availability\_zones

Description: availability zones to spread the cluster nodes across, if omitted, only one avilability zone is used

Type: `list(number)`

Default: `[]`

### azure\_container\_registry\_ids

Description: IDs of the azure container registries that the AKS should have pull access to

Type: `list(string)`

Default: `[]`

### default\_node\_pool\_name

Description: Name of the default node pool

Type: `string`

Default: `"default"`

### default\_node\_pool\_node\_soak\_duration\_in\_minutes

Description: soak\_duration\_in\_minutes is a optional parameter for an upgrade\_settings block  
Example: "30"  
see https://learn.microsoft.com/en-us/azure/aks/upgrade-aks-cluster?tabs=azure-cli#set-node-soak-time-value

Type: `number`

Default: `0`

### default\_node\_pool\_upgrade\_settings\_drain\_timeout\_in\_minutes

Description: drain\_timeout\_in\_minutes is a optional parameter for an upgrade\_settings block  
Example: "30"  
see https://learn.microsoft.com/en-us/azure/aks/upgrade-aks-cluster?tabs=azure-cli#set-node-drain-timeout-value

Type: `number`

Default: `30`

### default\_node\_pool\_upgrade\_settings\_enabled

Description: If true, an upgrade\_settings block will be added to default\_node\_pool.

Type: `bool`

Default: `false`

### default\_node\_pool\_upgrade\_settings\_max\_surge

Description: max\_surge is a required parameter for an upgrade\_settings block  
Example: "10%"  
see https://learn.microsoft.com/en-us/azure/aks/upgrade-aks-cluster?tabs=azure-cli#customize-node-surge-upgrade

Type: `string`

Default: `"10%"`

### dns\_prefix

Description: DNS-Prefix to use. Defaults to cluster name

Type: `string`

Default: `"NONE"`

### force\_upgrade\_enabled

Description: Azure default settings

Type: `bool`

Default: `false`

### idle\_timeout

Description: Desired outbound flow idle timeout in minutes for the cluster load balancer. Must be between 4 and 120 inclusive.

Type: `number`

Default: `5`

### image\_cleaner\_enabled

Description: Azure default settings

Type: `bool`

Default: `false`

### image\_cleaner\_interval\_hours

Description: Azure default settings

Type: `number`

Default: `48`

### load\_balancer\_sku

Description: The SKU for the used Load Balancer

Type: `string`

Default: `"basic"`

### maintenance\_window\_auto\_node\_upgrade\_day\_of\_week

Description: see https://learn.microsoft.com/en-us/azure/aks/planned-maintenance#creating-a-maintenance-window

Type: `string`

Default: `"Monday"`

### maintenance\_window\_auto\_node\_upgrade\_duration

Description: see https://learn.microsoft.com/en-us/azure/aks/planned-maintenance#creating-a-maintenance-window

Type: `string`

Default: `"4"`

### maintenance\_window\_auto\_node\_upgrade\_enabled

Description: Defines whether to add a schedule for node updates

Type: `bool`

Default: `false`

### maintenance\_window\_auto\_node\_upgrade\_start\_time

Description: Example: "04:00"  
see https://learn.microsoft.com/en-us/azure/aks/planned-maintenance#creating-a-maintenance-window

Type: `string`

Default: `"04:00"`

### maintenance\_window\_auto\_node\_upgrade\_utc\_offset

Description: Example: "+00:00"  
see https://learn.microsoft.com/en-us/azure/aks/planned-maintenance#creating-a-maintenance-window

Type: `string`

Default: `"+00:00"`

### maintenance\_window\_auto\_upgrade\_day\_of\_week

Description: see https://learn.microsoft.com/en-us/azure/aks/planned-maintenance#creating-a-maintenance-window

Type: `string`

Default: `"Monday"`

### maintenance\_window\_auto\_upgrade\_duration

Description: see https://learn.microsoft.com/en-us/azure/aks/planned-maintenance#creating-a-maintenance-window

Type: `string`

Default: `"4"`

### maintenance\_window\_auto\_upgrade\_start\_time

Description: Example: "04:00"  
see https://learn.microsoft.com/en-us/azure/aks/planned-maintenance#creating-a-maintenance-window

Type: `string`

Default: `"04:00"`

### maintenance\_window\_auto\_upgrade\_utc\_offset

Description: Example: "+00:00"  
see https://learn.microsoft.com/en-us/azure/aks/planned-maintenance#creating-a-maintenance-window

Type: `string`

Default: `"+00:00"`

### managed\_identity\_security\_group

Description: The name of a group which is assigned to appropriate roles in the subscription to manage resources that are required by the AKS.  
Setting this to a non empty string will add the AKS managed identity to this group.

You need the following API permissions (with admin consent) on a service prinicpal to make this work:

* Directory.Read.All
* Group.Read.All
* Group.ReadWrite.All

Type: `string`

Default: `""`

### max\_pods

Description: Amount of pods allowed on each node (be aware that kubernetes system pods are also counted

Type: `string`

Default: `"30"`

### network\_policy

Description: Network policy to use, currently only azure and callico are supported

Type: `string`

Default: `"azure"`

### node\_pools

Description: Additional node pools to set up

Type:

```hcl
map(object({
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
```

Default: `{}`

### node\_storage

Description: Disk size in GB

Type: `string`

Default: `"30"`

### outbound\_ports\_allocated

Description: Pre-allocated ports (AKS default: 0)

Type: `number`

Default: `0`

### rbac\_enabled

Description: Enables RBAC on the cluster. If true, rbac\_managed\_admin\_groups have to be specified.

Type: `bool`

Default: `true`

### sku\_tier

Description: n/a

Type: `string`

Default: `"Free"`

### ssh\_public\_key

Description: SSH public key to access the kubernetes node with

Type: `string`

Default: `""`

### static\_outbound\_ip\_count

Description:     On a lot of outgoing connections use this together with the maximum for outbound\_ports\_allocated of 64000 to not fall into network  
    bottlenecks. Recommended in that case is to set the count at least +5 more than the count of kubernetes nodes.

Type: `number`

Default: `0`

### tags

Description: Map of tags for the resources

Type: `map(any)`

Default: `{}`

### temporary\_name\_for\_rotation

Description: Specifies the name of the temporary node pool used to cycle the default node pool for VM resizing.

Type: `string`

Default: `"rotationtmp"`

## Outputs

The following outputs are exported:

### client\_certificate

Description: The Kubernetes client certificate for a kubectl config

### client\_certificate\_admin

Description: The Kubernetes client certificate for an admin access

### client\_key

Description: The Kubernetes client private key for a kubectl config

### client\_key\_admin

Description: The Kubernetes client private key for an admin access

### client\_token

Description: A client token for accessing the Cluster using kubectl

### client\_token\_admin

Description: A client token for accessing the Cluster using kubectl with an admin access

### cluster\_ca\_certificate

Description: The Kubernetes cluster ca certificate for a kubectl config

### cluster\_id

Description: The AKS cluster id

### cluster\_name

Description: The AKS cluster name

### fqdn

Description: The FQDN to the Kubernetes API server

### host

Description: The Kubernetes API host for a kubectl config

### managed\_identity\_object\_id

Description: The object ID of the service principal of the managed identity of the AKS

### node\_count

Description: n/a

### node\_resource\_group

Description: The resource group the Kubernetes nodes were created in

### public\_outbound\_ips

Description: The outbound public IPs
<!-- END_TF_DOCS -->

## Development

Use [the terraform module tools](https://github.com/dodevops/terraform-module-tools) to check and generate the documentation by running

    docker run -v "$PWD":/terraform ghcr.io/dodevops/terraform-module-tools:latest
