#!/bin/bash

#
# Setup pre-requisites
#

randomSuffix=$(cat /dev/urandom | tr -dc '[:lower:]' | fold -w ${1:-5} | head -n 1)
name=aks-${randomSuffix}
subscriptionId=$(az account list --query '[?isDefault==`true`].id' --output tsv)
#
# Create a resource group for the deployment
#
az group create --name ${name}-rg --location westeurope

#
# Create a service principal for GitHub Actions to use
# to access an Azure subscription
#
azureCredentials=$(az ad sp create-for-rbac --name ${name}-spn --role contributor --scopes $resourceGroupId --sdk-auth)

gh secret set AZURE_CREDENTIALS -r aks-lifecycle -b $azureCredentials 
gh secret set AZURE_RG -r aks-lifecycle -b ${name}-rg
gh secret set AZURE_SUBSCRIPTION -r aks-lifecycle -b $subscriptionId