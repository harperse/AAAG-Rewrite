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

@description('Should replica domain controllers be deployed? [yes|no]')
param includeAds string

/*
@description('RESERVED FOR POTENTIAL FUTURE USE: Allows automation of hub network deployment with or without Azure Firewall.')
@allowed([
  'DeployAppOnly'
  'DeployHubWithoutFW'
  'DeployHubWithFW'
])
param deploymentOption string = 'DeployAppOnly'

@description('The name for the Azure automation account that will be provisioned.')
param AutomationAccountName string

@description('The region for the Azure automation account that will be provisioned.')
param aaaRegionFullName string

@description('The name for the log analytics workspace that will be used for logging and diagnostics operations.')
param azureLogAnalyticsWorkspaceName string

@description('Log Analytics (OMS) region.')
param alaRegionFullName string

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
*/

var saName = storageAccountName
var stageLocation = '${_artifactsLocation}/${storageContainerName}'
var saSku = 'Standard_LRS'
var saUrlSuffix = storageDnsSuffix
var diagStorageUri = 'https://${saName}${saUrlSuffix}'

var devPublicIPAddressName = toLower('${devServerName}-pip')
var devDomainNameLabelPrefix = '${devPublicIPAddressName}-${randomInfix}'
var devPublicIPAddressType = 'Static'
var fqdnAzureSuffix = dnsNameLabelSuffix
var fqdnLocationSuffix = '${devPublicIPAddressName}.${location}${fqdnAzureSuffix}'
var avSetSuffix = 'NP-AVS-01'
var avSet = [
  '${regionCode}-ADC-${avSetSuffix}'
  '${regionCode}-WES-${avSetSuffix}'
  '${regionCode}-SQL-${avSetSuffix}'
  '${regionCode}-DEV-${avSetSuffix}'
  '${regionCode}-LNX-${avSetSuffix}'
]
var subnet01 = '${regionCode}-ADC-NP-SUB-01'
var subnet02 = '${regionCode}-SRV-NP-SUB-02'
var nsgADDS = '${regionCode}-ADC-NP-NSG-01'
var nsgSRVS = '${regionCode}-SRV-NP-NSG-02'
var nsgCollection = [
  nsgADDS
  nsgSRVS
]
var netPrefix = '10.20.10'
var netSuffixVNET = '.0/26'
var netSuffixADDS = '.0/28'
var netSuffixSRVS = '.16/28'
var vnet1Name = appVnetName
var vnet1Location = location
var vnet1AddressPrefix = '${netPrefix}${netSuffixVNET}'
var subnet1Name = subnet01
var subnet1Prefix = '${netPrefix}${netSuffixADDS}'
var subnet2Name = subnet02
var subnet2Prefix = '${netPrefix}${netSuffixSRVS}'
var vnet = {
  name: vnet1Name
  location: vnet1Location
  addressPrefix: vnet1AddressPrefix
}

var subnetNameCollection = [
  subnet1Name
  subnet2Name
]
var subnetPrefixCollection = [
  subnet1Prefix
  subnet2Prefix
]

var rsvName = recoveryServicesVaultName
var roleCodeAds = 'APPNPADC'
var roleCodeWeb = 'APPNPWES'
var roleCodeSql = 'APPNPSQL'
var roleCodeDev = 'APPNPDEV'
var roleCodeLnx = 'APPNPLNX'
var seriesPrefix = '0'
var adsPrefix = '${regionCode}${roleCodeAds}${seriesPrefix}'
var webPrefix = '${regionCode}${roleCodeWeb}${seriesPrefix}'
var sqlPrefix = '${regionCode}${roleCodeSql}${seriesPrefix}'
var devPrefix = '${regionCode}${roleCodeDev}${seriesPrefix}'
var lnxPrefix = '${regionCode}${roleCodeLnx}${seriesPrefix}'
var fqdnContosoDev = ((azureEnvironment == 'AzureCloud') ? 'dev.contoso.com' : 'dev.contoso.gov')
var domainJoinOptions = '3'
var dcNicIpPrefix = netPrefix
var adsVmSize = 'Standard_B2s'
var adsPrivateIps = {
  ads01PrivIp: '${dcNicIpPrefix}.4'
  ads02PrivIp: '${dcNicIpPrefix}.5'
}
var diskNameSuffix = {
  syst: '-DSK-SYST'
  data: '-DSK-DTA1'
}
var nicSuffix = '-NIC'
var nicCollection = {
  ads01nic: {
    name: toUpper('${adsPrefix}1${nicSuffix}')
  }
  ads02nic: {
    name: toUpper('${adsPrefix}2${nicSuffix}')
  }
  dev01nic: {
    name: toUpper('${devPrefix}1${nicSuffix}')
  }
  web01nic: {
    name: toUpper('${webPrefix}1${nicSuffix}')
  }
  web02nic: {
    name: toUpper('${webPrefix}2${nicSuffix}')
  }
  sql01nic: {
    name: toUpper('${sqlPrefix}1${nicSuffix}')
  }
  sql02nic: {
    name: toUpper('${sqlPrefix}2${nicSuffix}')
  }
  lnx01nic: {
    name: toUpper('${lnxPrefix}1${nicSuffix}')
  }
}
/*
var adminUserName = adminUserName
var adminPassword = adminPassword
var autoAcctName = AutomationAccountName
var omsWorkspaceName = azureLogAnalyticsWorkspaceName
var automationSchedule = {
  startupScheduleName: startupScheduleName
  shutdownScheduleName: shutdownScheduleName
  scheduledStopTime: scheduledStopTime
  scheduledStartTime: scheduledStartTime
  scheduledExpiryTime: scheduledExpiryTime
}
var createPublicIPUri = uri(stageLocation, 'nested/04.36.00.createPublicIP.bicep')
var createAvSetUri = uri(stageLocation, 'nested/05.08.00.createAvSet.bicep')
var createNSGUri = uri(stageLocation, 'nested/06.06.00.createNSG.bicep')
var createVnetUri = uri(stageLocation, 'nested/07.03.00.createVnet.bicep')
var createAutoAcctUri = uri(stageLocation, 'nested/09.12.00.createAutoAcct.bicep')
var createOmsWorkspaceUri = uri(stageLocation, 'nested/10.13.00.createOmsWorkspace.bicep')
var createRsvUri = uri(stageLocation, 'nested/11.14.00.createRecoveryServicesVault.bicep')
var createNetworkInterfacesUri = uri(stageLocation, 'nested/11.14.01.createNetworkInterfaces.bicep')
var createAds01Uri = uri(stageLocation, 'nested/03.15.00.createDomainController.bicep')
var createDev01Uri = uri(stageLocation, 'nested/14.17.00.createDevServer.bicep')
var createWebServersUri = uri(stageLocation, 'nested/15.21.00.createWebServers.bicep')
var createSqlServersUri = uri(stageLocation, 'nested/16.23.00.createSqlServers.bicep')
var createAdsServersUri = uri(stageLocation, 'nested/17.25.00.createAdsServers.bicep')
var createLnx01Uri = uri(stageLocation, 'nested/18.26.01.createLnxServer.bicep')
var updateVnetWithDNSuri = uri(stageLocation, 'nested/03.16.00.updateVnetWithDNS.bicep')
*/

module _04_36_00_linkedDeploymentCreatePublicIP 'nested/04.36.00.createPublicIP.bicep' = {
  name: '04.36.00.linkedDeploymentCreatePublicIP'
  params: {
    location: location
    devPublicIPAddressType: devPublicIPAddressType
    domainNameLabel: devDomainNameLabelPrefix
    fqdnLocation: fqdnLocationSuffix
  }
}

module _05_08_00_linkedDeploymentCreateAvSet 'nested/05.08.00.createAvSet.bicep' = {
  name: '05.08.00.linkedDeploymentCreateAvSet'
  params: {
    location: location
    avSet: avSet
  }
}

module _06_06_00_linkedDeploymentCreateNSG 'nested/06.06.00.createNSG.bicep' /*TODO: replace with correct path to [variables('createNSGUri')]*/ = {
  name: '06.06.00.linkedDeploymentCreateNSG'
  params: {
    location: location
    //vnet1AddressPrefix: vnet1AddressPrefix
    nsgCollection: nsgCollection
  }
}

module _07_03_00_linkedDeploymentCreateVnet 'nested/07.03.00.createVnet.bicep' /*TODO: replace with correct path to [variables('createVnetUri')]*/ = {
  name: '07.03.00.linkedDeploymentCreateVnet'
  params: {
    vnet: vnet
    subnetNames: subnetNameCollection
    subnetPrefixes: subnetPrefixCollection
    nsgId1: _06_06_00_linkedDeploymentCreateNSG.outputs.nsgResourceId1
    nsgId2: _06_06_00_linkedDeploymentCreateNSG.outputs.nsgResourceId2
  }
}

module _11_14_00_linkedDeploymentCreateRecoveryServicesVault 'nested/11.14.00.createRecoveryServicesVault.bicep' /*TODO: replace with correct path to [variables('createRsvUri')]*/ = {
  name: '11.14.00.linkedDeploymentCreateRecoveryServicesVault'
  params: {
    rsvName: rsvName
    location: location
  }
  dependsOn: []
}

module _11_14_01_linkedDeploymentCreateNetworkInterfaces 'nested/11.14.01.createNetworkInterfaces.bicep' /*TODO: replace with correct path to [variables('createNetworkInterfacesUri')]*/ = {
  name: '11.14.01.linkedDeploymentCreateNetworkInterfaces'
  params: {
    nicCollection: nicCollection
    location: location
    subnetAddsRef: _07_03_00_linkedDeploymentCreateVnet.outputs.subnetAddsId
    subnetSrvsRef: _07_03_00_linkedDeploymentCreateVnet.outputs.subnetSrvsId
    dev01pipId: _04_36_00_linkedDeploymentCreatePublicIP.outputs.devPublicIpResourceId
    adsPrivateIps: adsPrivateIps
    includeAds: includeAds
  }
}

module _03_15_00_linkedDeploymentCreateDomainController 'nested/03.15.00.createDomainController.bicep' /*TODO: replace with correct path to [variables('createAds01Uri')]*/ = {
  name: '03.15.00.linkedDeploymentCreateDomainController'
  params: {
    adsPrefix: adsPrefix
    location: location
    adminUserName: adminUserName
    adminPassword: adminPassword
    adsAvSetId: _05_08_00_linkedDeploymentCreateAvSet.outputs.adsAvSetID
    ads01nicId: _11_14_01_linkedDeploymentCreateNetworkInterfaces.outputs.ads01NicId
    saSku: saSku
    diagStorageUri: diagStorageUri
    //domainName: fqdnContosoDev
    dscArtifactsUrl: _artifactsLocation
    dscUrlSasToken: _artifactsLocationSasToken
    vmSize: adsVmSize
    diskNameSuffix: diskNameSuffix
  }
  dependsOn: [
    _07_03_00_linkedDeploymentCreateVnet
  ]
}

module _03_16_00_linkedDeploymentUpdateVnetWithDNS 'nested/03.16.00.updateVnetWithDNS.bicep' /*TODO: replace with correct path to [variables('updateVnetWithDNSuri')]*/ = {
  name: '03.16.00.linkedDeploymentUpdateVnetWithDNS'
  params: {
    vnet: vnet
    subnetNames: subnetNameCollection
    subnetPrefixes: subnetPrefixCollection
    adsPrivateIps: adsPrivateIps
  }
  dependsOn: [
    _03_15_00_linkedDeploymentCreateDomainController
  ]
}

module _14_17_00_linkedDeploymentCreateDevServer 'nested/14.17.00.createDevServer.bicep' /*TODO: replace with correct path to [variables('createDev01Uri')]*/ = {
  name: '14.17.00.linkedDeploymentCreateDevServer'
  params: {
    devPrefix: devPrefix
    location: location
    adminUserName: adminUserName
    adminPassword: adminPassword
    devAvSetId: _05_08_00_linkedDeploymentCreateAvSet.outputs.devAvSetID
    dev01nicId: _11_14_01_linkedDeploymentCreateNetworkInterfaces.outputs.dev01NicId
    saSku: saSku
    diagStorageUri: diagStorageUri
    domainName: fqdnContosoDev
    domainJoinOptions: domainJoinOptions
    vmSize: vmSize
    diskNameSuffix: diskNameSuffix
  }
  dependsOn: [
    _03_16_00_linkedDeploymentUpdateVnetWithDNS
  ]
}

module _15_21_00_linkedDeploymentCreateWebServers 'nested/15.21.00.createWebServers.bicep' /*TODO: replace with correct path to [variables('createWebServersUri')]*/ = {
  name: '15.21.00.linkedDeploymentCreateWebServers'
  params: {
    webPrefix: webPrefix
    location: location
    adminUserName: adminUserName
    adminPassword: adminPassword
    webAvSetId: _05_08_00_linkedDeploymentCreateAvSet.outputs.webAvSetID
    webNicIds: _11_14_01_linkedDeploymentCreateNetworkInterfaces.outputs.webNicIds
    saSku: saSku
    diagStorageUri: diagStorageUri
    domainName: fqdnContosoDev
    domainJoinOptions: domainJoinOptions
    vmSize: vmSize
    diskNameSuffix: diskNameSuffix
  }
  dependsOn: [
    _03_16_00_linkedDeploymentUpdateVnetWithDNS
  ]
}

module _16_23_00_linkedDeploymentCreateSqlServers 'nested/16.23.00.createSqlServers.bicep' = {
  name: '16.23.00.linkedDeploymentCreateSqlServers'
  params: {
    sqlPrefix: sqlPrefix
    location: location
    adminUserName: adminUserName
    adminPassword: adminPassword
    sqlAvSetId: _05_08_00_linkedDeploymentCreateAvSet.outputs.sqlAvSetID
    sqlNicIds: _11_14_01_linkedDeploymentCreateNetworkInterfaces.outputs.sqlNicIds
    saSku: saSku
    diagStorageUri: diagStorageUri
    domainName: fqdnContosoDev
    domainJoinOptions: domainJoinOptions
    vmSize: vmSize
    diskNameSuffix: diskNameSuffix
    cseScriptUri: uri(stageLocation, 'cse/Set-BypassAppLockerScenario.ps1${_artifactsLocationSasToken}')
    appLockerPrepScript: './cse/Set-BypassAppLockerScenario.ps1'
  }
  dependsOn: [
    _03_16_00_linkedDeploymentUpdateVnetWithDNS
  ]
}

module _17_25_00_linkedDeploymentCreateAdsServers 'nested/17.25.00.createAdsServers.bicep' /*TODO: replace with correct path to [variables('createAdsServersUri')]*/ = if (includeAds == 'yes') {
  name: '17.25.00.linkedDeploymentCreateAdsServers'
  params: {
    adsPrefix: adsPrefix
    location: location
    adminUserName: adminUserName
    adminPassword: adminPassword
    adsAvSetId: _05_08_00_linkedDeploymentCreateAvSet.outputs.adsAvSetID
    adsNicIds: _11_14_01_linkedDeploymentCreateNetworkInterfaces.outputs.adsNicIds
    saSku: saSku
    diagStorageUri: diagStorageUri
    domainName: fqdnContosoDev
    //domainJoinOptions: domainJoinOptions
    dscArtifactsUrl: _artifactsLocation
    dscUrlSasToken: _artifactsLocationSasToken
    vmSize: adsVmSize
    diskNameSuffix: diskNameSuffix
  }
  dependsOn: [
    _03_16_00_linkedDeploymentUpdateVnetWithDNS
  ]
}

module _18_26_01_linkedDeploymentCreateLnxServer 'nested/18.26.01.createLnxServer.bicep' /*TODO: replace with correct path to [variables('createLnx01Uri')]*/ = {
  name: '18.26.01.linkedDeploymentCreateLnxServer'
  params: {
    lnxPrefix: lnxPrefix
    location: location
    adminUserName: adminUserName
    adminPassword: adminPassword
    lnxAvSetId: _05_08_00_linkedDeploymentCreateAvSet.outputs.lnxAvSetID
    lnx01nicId: _11_14_01_linkedDeploymentCreateNetworkInterfaces.outputs.lnx01NicId
    saSku: saSku
    diagStorageUri: diagStorageUri
    vmSize: vmSize
    diskNameSuffix: diskNameSuffix
  }
  dependsOn: [
    _03_16_00_linkedDeploymentUpdateVnetWithDNS
  ]
}

output fqdnPublicIpFromLinkedTemplate string = _04_36_00_linkedDeploymentCreatePublicIP.outputs.fqdn
output nsgResourceId1FromLinkedTemplate string = _06_06_00_linkedDeploymentCreateNSG.outputs.nsgResourceId1
output nsgResourceId2FromLinkedTemplate string = _06_06_00_linkedDeploymentCreateNSG.outputs.nsgResourceId2
