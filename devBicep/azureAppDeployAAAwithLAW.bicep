@description('Auto-generated container in staging storage account to receive DSC scripts.')
param _artifactsLocation string

@description('Auto-generated token to access _artifactsLocation when the template is deployed.')
@secure()
param _artifactsLocationSasToken string

@description('The storage suffix for the storage account name depending on the AzureEnvironment value (AzureCloud or AzureUSGovernment)')
param storageDnsSuffix string

@description('The DNS name label suffix for public IP addresses depending on the Cloud environment; AzureCloud or AzureUSGovernment')
param dnsNameLabelSuffix string

@description('Administrative user name for virtual machine.')
param adminUserName string

@description('Secure password')
@secure()
param adminPassword string

@description('resource group location.')
param location string

@description('Random infix used to construct unique resource values within the same subscription, consisting of 8 numeric and lower-case characters only.')
@minLength(8)
@maxLength(8)
param randomInfix string

@description('The name for the Azure automation account that will be provisioned.')
param AutomationAccountName string

@description('The region for the Azure automation account that will be provisioned.')
param aaaRegionFullName string

@description('The name for the log analytics workspace that will be used for logging and diagnostics operations.')
param azureLogAnalyticsWorkspaceName string

@description('Log Analytics (OMS) region.')
param alaRegionFullName string

@description('The name for the recovery services vault for backup and site recovery operations.')
param recoveryServicesVaultName string

@description('The geo-political region code for this deployment.')
param regionCode string

@description('The name of the dev/jump server for this infrastructure.')
param devServerName string

@description('The globally unique storage account name for the storage account that will be provisioned')
param storageAccountName string

@description('The storage container name where artifacts will be.')
param storageContainerName string

@description('<PLACE-HOLDER ONLY> RESERVED FOR POTENTIAL FUTURE USE: Allows automation of hub network deployment with or without Azure Firewall.')
@allowed([
  'DeployAppOnly'
  'DeployHubWithoutFW'
  'DeployHubWithFW'
])
param deploymentOption string = 'DeployAppOnly'

@description('<PLACE-HOLDER ONLY> RESERVED FOR POTENTIAL FUTURE USE: The Cloud environment, either AzureCloud or AzureUSGovernment will be used.')
@allowed([
  'AzureCloud'
  'AzureUSGovernment'
])
param azureEnvironment string = 'AzureCloud'

@description('Size of VM, i.e. Standard_')
param vmSize string

@description('App/Spoke VNET name')
param appVnetName string

@description('Startup Schedule Name')
param startupScheduleName string

@description('Shutdown Schedule Name')
param shutdownScheduleName string

@description('Scheduled Stop Time')
param scheduledStopTime string

@description('Scheduled Start Time')
param scheduledStartTime string

@description('Scheduled Start Time')
param scheduledExpiryTime string

var stageLocation = '${_artifactsLocation}/${storageContainerName}'
var automationSchedule = {
  startupScheduleName: startupScheduleName
  shutdownScheduleName: shutdownScheduleName
  scheduledStopTime: scheduledStopTime
  scheduledStartTime: scheduledStartTime
  scheduledExpiryTime: scheduledExpiryTime
}
var autoAcctName = AutomationAccountName
var createAutoAcctUri = uri(stageLocation, 'nested/09.12.00.createAutoAcct.json${_artifactsLocationSasToken}')
var omsWorkspaceName = azureLogAnalyticsWorkspaceName
var createOmsWorkspaceUri = uri(stageLocation, 'nested/10.13.00.createOmsWorkspace.json${_artifactsLocationSasToken}')

module _09_12_00_linkedDeploymentCreateAutoAcct '?' /*TODO: replace with correct path to [variables('createAutoAcctUri')]*/ = {
  name: '09.12.00.linkedDeploymentCreateAutoAcct'
  params: {
    autoAcctName: autoAcctName
    location: aaaRegionFullName
    automationSchedule: automationSchedule
  }
  dependsOn: []
}

module _10_13_00_linkedDeploymentCreateOmsWorkspace '?' /*TODO: replace with correct path to [variables('createOmsWorkspaceUri')]*/ = {
  name: '10.13.00.linkedDeploymentCreateOmsWorkspace'
  params: {
    omsWorkspaceName: omsWorkspaceName
    alaRegionFullName: alaRegionFullName
    autoAcctId: _09_12_00_linkedDeploymentCreateAutoAcct.properties.outputs.autoAcctId.value
  }
}
