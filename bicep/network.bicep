//
// Parameters
//
@description('The Azure region to use for this deployment')
param location string

@description('The virtual network name')
param virtualNetworkName string

@description('The CIDR for the virtual network')
param addressPrefix string

@description('The name of the subnet for AKS nodes')
param aksNodeSubnetName string

@description('The CIDR for the AKS nodes subnet')
param aksNodeSubnetPrefix string

@description('The name of the subnet for AKS pods')
param aksPodSubnetName string

@description('The CIDR for the AKS pods subnet')
param aksPodSubnetPrefix string

@description('The name of the subnet for AGIC')
param agicSubnetName string

@description('The CIDR for the AGIC subnet')
param agicSubnetPrefix string

//
// Create an Azure virtual network and subnets
// for the nodes, pods and Application Gateway
//

resource aksVirtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
  }

  resource aksNodeSubnet 'subnets@2021-02-01' = {
    name: aksNodeSubnetName
    properties: {
      addressPrefix: aksNodeSubnetPrefix
    }
  }

  resource aksPodSubnet 'subnets@2021-02-01' = {
    name: aksPodSubnetName
    properties: {
      addressPrefix: aksPodSubnetPrefix
    }
  }

  resource agicSubnet 'subnets@2021-02-01' = {
    name: agicSubnetName
    properties: {
      addressPrefix: agicSubnetPrefix
    }
  }
}

output aksNodeSubnetId string = aksVirtualNetwork::aksNodeSubnet.id
output aksPodSubnetId string = aksVirtualNetwork::aksPodSubnet.id
output agicSubnetId string = aksVirtualNetwork::agicSubnet.id
