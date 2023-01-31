@description('<PLACE-HOLDER ONLY> RESERVED FOR POTENTIAL FUTURE USE: Allows automation of hub network deployment with or without Azure Firewall.')
@allowed([
  'DeployAppOnly'
  'DeployHubWithoutFW'
  'DeployHubWithFW'
])
param hubDeploymentOption string = 'DeployAppOnly'

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

@description('Resource group location.')
param hubLocation string

@description('Random infix for public IP DNS label.')
param randomInfix string

@description('The name for the Azure automation account that will be provisioned.')
param AutomationAccountName string

@description('The region for the Azure automation account that will be provisioned.')
param aaaRegionFullName string

@description('The name for the log analytics workspace that will be used for logging and diagnostics operations.')
param azureLogAnalyticsWorkspaceName string

@description('Log Analytics (OMS) region.')
param alaRegionFullName string

@description('The name of the dev/jump server for this infrastructure.')
param hubJumpServerName string
param hubFwName string

@description('Name for network interface card of jump server.')
param hubJumpServerNic string

@description('The globally unique storage account name for the storage account that will be provisioned')
param storageAccountName string

@description('The globally unique storage account name for the hub storage account.')
param staHubName string

@description('The storage container in which the staged artifacts are uploaded to.')
param storageContainerName string

@description('The public IP address of the local machine, which can be use for JIT access.')
param localMachinePublicIP string

@description('Name of Hub virtual network')
param hubVnetName string

@description('Address space for Hub virtual network')
param hubVnetAddressSpace string

@description('Jump server subnet name')
param hubJmpSubnetName string

@description('Jump server subnet address range')
param hubJmpSubnetRange string

@description('Public IP for Jump server')
param hubPublicIp string

@description('VM Size for jump server')
param hubJumpServerSize string

@description('Basic NSG that will be associated directly to the NIC of the Jump Server')
param hubJumpSubnetNSG string

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


//var adminUserName_var = adminUserName
//var adminPassword_var = adminPassword
var storageObj = {
  stageLocation: '${_artifactsLocation}/${storageContainerName}'
  saSku: 'Standard_LRS'
  diagStorageUri: 'https://${storageAccountName}${storageDnsSuffix}'
  diagHubStorageUri: 'https://${staHubName}${storageDnsSuffix}'
}
var ipObj = {
  jmpPublicIPAddressName: toUpper(hubPublicIp)
  jmpDomainNameLabelPrefix: toLower('${hubJumpServerName}-${randomInfix}-pip')
  afwDomainNameLabelPrefix: toLower('${hubFwName}-${randomInfix}-pip')
  jmpPublicIPAddressType: 'Static'
  fqdnLocationSuffix: toLower('.${hubLocation}${dnsNameLabelSuffix}')
  location: hubLocation
  prvIpJumpServer: '${substring(hubVnetObj.hubJmpSubnetRange, 0, 8)}4'
  prvIpAllocationMethod: 'Static'
  prvIPAddressVersion: 'IPv4'
  createhubPublicIPUri: uri(storageObj.stageLocation, 'nested/01.00.00.createHubPublicIP.bicep${_artifactsLocationSasToken}')
}
var hubVnetObj = {
  hubVnetName: hubVnetName
  hubVnetAddressSpace: hubVnetAddressSpace
  hubJmpSubnetName: hubJmpSubnetName
  hubJmpSubnetRange: hubJmpSubnetRange
  hubJumpSubnetNSG: hubJumpSubnetNSG
  location: hubLocation
  createHubVnetWithoutFWUri: uri(storageObj.stageLocation, 'nested/01.02.01.createHubVnetWithoutFW.bicep${_artifactsLocationSasToken}')
}
var sourceAddressPrefix = '${localMachinePublicIP}/32'
var nsgObj = {
  hubJumpSubnetNSG: hubJumpSubnetNSG
  location: hubLocation
  nsgRule: {
    name: 'AllowRdpInbound'
    properties: {
      access: 'Allow'
      description: 'Allow inbound RDP from internet'
      destinationAddressPrefix: 'VirtualNetwork'
      destinationPortRange: '3389'
      direction: 'Inbound'
      priority: 100
      protocol: 'Tcp'
      sourceAddressPrefix: sourceAddressPrefix
      sourcePortRange: '*'
    }
  }
  createHubNSGUri: uri(storageObj.stageLocation, 'nested/01.01.00.createHubNSG.bicep${_artifactsLocationSasToken}')
}
var nicObj = {
  hubJumpServerNic: hubJumpServerNic
  location: hubLocation
  createHubJmpServerNicUri: uri(storageObj.stageLocation, 'nested/01.04.00.createHubJmpServerNic.bicep${_artifactsLocationSasToken}')
}
var jmpServerObj = {
  credObj: {
    adminUserName: adminUserName
    adminPassword: adminPassword
  }
  hubJumpServerName: hubJumpServerName
  hubJumpServerSize: hubJumpServerSize
  location: hubLocation
  imagePublisher: 'MicrosoftWindowsServer'
  imageOffer: 'WindowsServer'
  imageSku: '2019-Datacenter-smalldisk'
  imageVersion: 'latest'
  diskNameOs: toUpper('${hubJumpServerName}-DSK-SYST')
  diskNameData: toUpper('${hubJumpServerName}-DSK-DTA1')
  createHubJumpServerUri: uri(storageObj.stageLocation, 'nested/01.05.00.createHubJmpServer.bicep${_artifactsLocationSasToken}')
}
var autoAcctName = AutomationAccountName
//var createAutoAcctUri = uri(storageObj.stageLocation, 'nested/09.12.00.createAutoAcct.bicep${_artifactsLocationSasToken}')
var omsWorkspaceName = azureLogAnalyticsWorkspaceName
//var createOmsWorkspaceUri = uri(storageObj.stageLocation, 'nested/10.13.00.createOmsWorkspace.bicep${_artifactsLocationSasToken}')
var automationSchedule = {
  startupScheduleName: startupScheduleName
  shutdownScheduleName: shutdownScheduleName
  scheduledStopTime: scheduledStopTime
  scheduledStartTime: scheduledStartTime
  scheduledExpiryTime: scheduledExpiryTime
}

module _01_00_00_linkedDeploymentCreateHubPublicIP 'nested/01.00.00.createHubPublicIP.bicep' /*TODO: replace with correct path to [variables('ipObj').createhubPublicIPUri]*/ = {
  name: '01.00.00.linkedDeploymentCreateHubPublicIP'
  params: {
    ipObj: ipObj
    hubDeploymentOption: hubDeploymentOption
  }
}

module _01_01_00_linkedDeploymentCreateHubNSG 'nested/01.01.00.createHubNSG.bicep' = {
  name: '01.01.00.linkedDeploymentCreateHubNSG'
  params: {
    location: hubLocation
    nsgObj: nsgObj
  }
}

module _01_02_01_linkedDeploymentCreateHubVnetWithoutFW 'nested/01.02.01.createHubVnetWithoutFW.bicep' = {
  name: '01.02.01.linkedDeploymentCreateHubVnetWithoutFW'
  params: {
    hubVnetObj: hubVnetObj
    hubJmpSubnetNSGId1: _01_01_00_linkedDeploymentCreateHubNSG.outputs.nsgResourceId1
  }
  dependsOn: [
    _01_00_00_linkedDeploymentCreateHubPublicIP

  ]
}

module _01_04_00_linkedDeploymentCreateHubJmpServerNic 'nested/01.04.00.createHubJmpServerNic.bicep' = {
  name: '01.04.00.linkedDeploymentCreateHubJmpServerNic'
  params: {
    nicObj: nicObj
    ipObj: ipObj
    jmpPublicIpResourceId: _01_00_00_linkedDeploymentCreateHubPublicIP.outputs.jmpPublicIpResourceId
    subnetJmpId: _01_02_01_linkedDeploymentCreateHubVnetWithoutFW.outputs.subnetJmpId
  }
}

module _01_05_00_linkedDeploymentCreateHubJmpServer 'nested/01.05.00.createHubJmpServer.bicep' = {
  name: '01.05.00.linkedDeploymentCreateHubJmpServer'
  params: {
    jmpServerObj: jmpServerObj
    storageObj: storageObj
    hubJumpServerNicId: _01_04_00_linkedDeploymentCreateHubJmpServerNic.outputs.hubJumpServerNicId
  }
  dependsOn: [
    _01_01_00_linkedDeploymentCreateHubNSG
  ]
}

module _09_12_00_linkedDeploymentCreateAutoAcct 'nested/09.12.00.createAutoAcct.bicep' = if (hubDeploymentOption == 'DeployHubWithoutFW') {
  name: '09.12.00.linkedDeploymentCreateAutoAcct'
  params: {
    autoAcctName: autoAcctName
    location: aaaRegionFullName
    automationSchedule: automationSchedule
  }
  dependsOn: []
}

module _10_13_00_linkedDeploymentCreateOmsWorkspace 'nested/10.13.00.createOmsWorkspace.bicep' = if (hubDeploymentOption == 'DeployHubWithoutFW') {
  name: '10.13.00.linkedDeploymentCreateOmsWorkspace'
  params: {
    omsWorkspaceName: omsWorkspaceName
    alaRegionFullName: alaRegionFullName
    autoAcctId: _09_12_00_linkedDeploymentCreateAutoAcct.outputs.autoAcctId
  }
}

output jmpServerPublicIpFqdn string = _01_00_00_linkedDeploymentCreateHubPublicIP.outputs.jmpServerPublicIpFqdn
output nsgResourceId1 string = _01_01_00_linkedDeploymentCreateHubNSG.outputs.nsgResourceId1
