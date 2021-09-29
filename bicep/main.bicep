//
// Parameters
//
@description('The Azure region to use for this deployment')
param location string = resourceGroup().location

@description('The slug to be used as part of the resource names')
param name string = 'aks'

@description('The DNS prefix for the API server')
param dnsPrefix string = name

@minValue(1)
@maxValue(10)
@description('Number of cluster nodes')
param nodeCount int = 3

@description('Node virtual machine type')
param nodeSKU string = 'Standard_D2_v3'

@description('Kubernetes version')
param kubernetesVersion string = '1.21.2'

@description('Number to use for the second octet of the virtual network - 10.x.0.0/16 - This value will replace the x')
param virtualNetworkNumber int = 100

//
// Variables
//
var virtualNetworkName = '${name}-vnet'
var addressPrefix = '10.${virtualNetworkNumber}.0.0/16'
var aksNodeSubnetName = '${name}-node-subnet'
var aksNodeSubnetPrefix = '10.${virtualNetworkNumber}.1.0/24'
var aksPodSubnetName = '${name}-pod-subnet'
var aksPodSubnetPrefix = '10.${virtualNetworkNumber}.2.0/24'
var agicSubnetName = '${name}-agic-subnet'
var agicSubnetPrefix = '10.${virtualNetworkNumber}.3.0/24'

module network 'network.bicep' = {
  name: 'network'
  params: {
    location: location
    virtualNetworkName: virtualNetworkName
    addressPrefix: addressPrefix
    aksNodeSubnetName: aksNodeSubnetName
    aksNodeSubnetPrefix: aksNodeSubnetPrefix
    aksPodSubnetName: aksPodSubnetName
    aksPodSubnetPrefix: aksPodSubnetPrefix
    agicSubnetName: agicSubnetName
    agicSubnetPrefix: agicSubnetPrefix
  }
}
