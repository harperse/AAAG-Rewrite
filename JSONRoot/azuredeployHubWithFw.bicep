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

@description('Public IP for Firewall service')
param hubPublicIp string

@description('VM Size for jump server')
param hubJumpServerSize string

@description('Basic NSG that will be associated directly to the NIC of the Jump Server')
param hubJumpSubnetNSG string

@description('Subnet name for Azure Firewall')
param hubFwSubnetName string = 'AzureFirewallSubnet'

@description('Subnet range for Azure Firewall')
param hubFwSubnetRange string

@description('Route table for Jump server subnet to use user defined route for Azure Firewall NVA')
param hubRouteTable string

@description('Virtual network gateway route propagation for hub route table.')
param hubRouteDisablePropagation bool

@description('Route name.')
param hubRouteToAfwName string

@description('Destination address space in CIDR notation to route to:')
param hubRouteToAfwAddrPrefix string

@description('VirtualAppliance')
param hubRouteNextHopType string

@description('Private IP address of the Azure Firewall')
param hubFwPrvIp string

@description('Next hop interface IP address to route to, i.e. private IP for Network Virtual Appliance (NVA)')
param hubRouteToAfwNextHopAddress string

@description('Route name for route to spoke')
param hubRTS string

@description('Route to spoke address prefix ')
param hubRTSAddrPrefix string

@description('NAT rule collection name.')
param hubFwNatRuleCollName string

@description('NAT rule collection priority.')
param hubFwNatRuleCollPriority int
param hubFwNatRuleCollAction string

@description('NAT rule 1 name.')
param hubFwNatRule01Name string

@description('NAT rule 1 protocol.')
param hubFwNatRule01Protocol string

@description('NAT rule 1 source address.')
param hubFwNatRule01SourceAddr string

@description('NAT rule 1 desination port.')
param hubFwNatRule01DestPort string

@description('NAT rule 1 desination translated address (Jump server private IP).')
param hubFwNatRule01TransAddr string

@description('NAT rule 1 desination translated port (Jump server port).')
param hubFwNatRule01TransPort string
param hubFwNetworkRuleCollName string
param hubFwNetworkRulePriority int
param hubFwNetworkRuleCollAction string
param hubFwNetworkRule01Name string
param hubFwNetworkRule01Protocol string
param hubFwNetworkRule01SourceAddr string
param hubFwNetworkRule01DestAddr string
param hubFwNetworkRule01DestPort array
param hubFwNetworkRuleCollName02 string
param hubFwNetworkRulePriority02 int
param hubFwNetworkRuleCollAction02 string
param hubFwNetworkRule02Name string
param hubFwNetworkRule02Protocol string
param hubFwNetworkRule02SourceAddr string
param hubFwNetworkRule02DestAddr string
param hubFwNetworkRule02DestPort string
param hubFwNetworkRule03Name string
param hubFwNetworkRule03Protocol string
param hubFwNetworkRule03SourceAddr string
param hubFwNetworkRule03DestAddr string
param hubFwNetworkRule03DestPort string
param hubFwAppRuleCollName string
param hubFwAppRulePriority int
param hubFwAppRuleAction string
param hubFwAppRule01Name string
param hubFwAppRule01SourceAddr array
param hubFwAppRule01fqdnTags array
param hubFwAppRule02Name string
param hubFwAppRule02SourceAddr array
param hubFwAppRule02Protocol string
param hubFwAppRule02Port int
param hubFwAppRule02TargetFqdn array

//@description('<PLACE-HOLDER ONLY> RESERVED FOR POTENTIAL FUTURE USE: The Cloud environment, either AzureCloud or AzureUSGovernment will be used.')
//@allowed([
//  'AzureCloud'
//  'AzureUSGovernment'
//])
//param azureEnvironment string = 'AzureCloud'

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

//var location = hubLocation
//var adminUserName = adminUserName
//var adminPassword = adminPassword
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
  createhubPublicIPUri: uri(storageObj.stageLocation, 'nested/01.00.00.createHubPublicIP.json${_artifactsLocationSasToken}')
}
var hubVnetObj = {
  hubVnetName: hubVnetName
  hubVnetAddressSpace: hubVnetAddressSpace
  hubJmpSubnetName: hubJmpSubnetName
  hubJmpSubnetRange: hubJmpSubnetRange
  hubJumpSubnetNSG: hubJumpSubnetNSG
  location: hubLocation
  createHubVnetWithFWUri: uri(storageObj.stageLocation, 'nested/01.02.02.createHubVnetWithFW.json${_artifactsLocationSasToken}')
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
  createHubNSGUri: uri(storageObj.stageLocation, 'nested/01.01.00.createHubNSG.json${_artifactsLocationSasToken}')
}
var nicObj = {
  hubJumpServerNic: hubJumpServerNic
  location: hubLocation
  createHubJmpServerFwNicUri: uri(storageObj.stageLocation, 'nested/01.04.01.createHubJmpServerFwNic.json${_artifactsLocationSasToken}')
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
  createHubJumpServerUri: uri(storageObj.stageLocation, 'nested/01.05.00.createHubJmpServer.json${_artifactsLocationSasToken}')
}
var routeTableObj = {
  hubRouteTable: hubRouteTable
  hubRouteDisablePropagation: hubRouteDisablePropagation
  hubRouteToAfwName: hubRouteToAfwName
  hubRTS: hubRTS
  hubRTSAddrPrefix: hubRTSAddrPrefix
  hubRouteToAfwAddrPrefix: hubRouteToAfwAddrPrefix
  hubRouteNextHopType: hubRouteNextHopType
  hubFwPrvIp: hubFwPrvIp
  hubRouteToAfwNextHopAddress: hubRouteToAfwNextHopAddress
}
var hubFwObj = {
  fwSubnetName: hubFwSubnetName
  fwSubnetRange: hubFwSubnetRange
  fwName: hubFwName
  hubFwPrvIp: hubFwPrvIp
  fwNetworkRuleCollection: [
    {
      collection01: {
        Name: hubFwNetworkRuleCollName
        Priority: hubFwNetworkRulePriority
        Action: hubFwNetworkRuleCollAction
        rule01: {
          Name: hubFwNetworkRule01Name
          Protocol: hubFwNetworkRule01Protocol
          SourceAddr: hubFwNetworkRule01SourceAddr
          DestAddr: hubFwNetworkRule01DestAddr
          DestPort: hubFwNetworkRule01DestPort
        }
      }
    }
    {
      collection02: {
        Name: hubFwNetworkRuleCollName02
        Priority: hubFwNetworkRulePriority02
        Action: hubFwNetworkRuleCollAction02
        rule01: {
          Name: hubFwNetworkRule02Name
          Protocol: hubFwNetworkRule02Protocol
          SourceAddr: hubFwNetworkRule02SourceAddr
          DestAddr: hubFwNetworkRule02DestAddr
          DestPort: hubFwNetworkRule02DestPort
        }
        rule02: {
          Name: hubFwNetworkRule03Name
          Protocol: hubFwNetworkRule03Protocol
          SourceAddr: hubFwNetworkRule03SourceAddr
          DestAddr: hubFwNetworkRule03DestAddr
          DestPort: hubFwNetworkRule03DestPort
        }
      }
    }
  ]
  fwAppRuleCollection: [
    {
      collection01: {
        Name: hubFwAppRuleCollName
        Priority: hubFwAppRulePriority
        Action: hubFwAppRuleAction
        rule01: {
          Name: hubFwAppRule01Name
          SourceAddr: hubFwAppRule01SourceAddr
          fqdnTags: hubFwAppRule01fqdnTags
        }
        rule02: {
          Name: hubFwAppRule02Name
          SourceAddr: hubFwAppRule02SourceAddr
          Protocol: hubFwAppRule02Protocol
          Port: hubFwAppRule02Port
          TargetFqdn: hubFwAppRule02TargetFqdn
        }
      }
    }
  ]
  fwNatRuleCollection: [
    {
      collection01: {
        Name: hubFwNatRuleCollName
        Priority: hubFwNatRuleCollPriority
        Action: hubFwNatRuleCollAction
        rule01: {
          Name: hubFwNatRule01Name
          Protocol: hubFwNatRule01Protocol
          SourceAddr: hubFwNatRule01SourceAddr
          DestPort: hubFwNatRule01DestPort
          TransAddr: hubFwNatRule01TransAddr
          TransPort: hubFwNatRule01TransPort
        }
      }
    }
  ]
  createHubAzureFwUri: uri(storageObj.stageLocation, 'nested/01.02.03.createHubAzureFw.json${_artifactsLocationSasToken}')
}
var autoAcctName = AutomationAccountName
//var createAutoAcctUri = uri(storageObj.stageLocation, 'nested/09.12.00.createAutoAcct.json${_artifactsLocationSasToken}')
var omsWorkspaceName = azureLogAnalyticsWorkspaceName
//var createOmsWorkspaceUri = uri(storageObj.stageLocation, 'nested/10.13.00.createOmsWorkspace.json${_artifactsLocationSasToken}')
var automationSchedule = {
  startupScheduleName: startupScheduleName
  shutdownScheduleName: shutdownScheduleName
  scheduledStopTime: scheduledStopTime
  scheduledStartTime: scheduledStartTime
  scheduledExpiryTime: scheduledExpiryTime
}

module _01_00_00_linkedDeploymentCreateHubPublicIP 'nested/01.00.00.createHubPublicIP.json' /*TODO: replace with correct path to [variables('ipObj').createhubPublicIPUri]*/ = {
  name: '01.00.00.linkedDeploymentCreateHubPublicIP'
  params: {
    ipObj: ipObj
    hubDeploymentOption: hubDeploymentOption
  }
}

module _01_01_00_linkedDeploymentCreateHubNSG 'nested/01.01.00.createHubNSG.json' /*TODO: replace with correct path to [variables('nsgObj').createHubNSGUri]*/ = {
  name: '01.01.00.linkedDeploymentCreateHubNSG'
  params: {
    nsgObj: nsgObj
  }
}

module _01_02_02_linkedDeploymentCreateHubVnetWithFW 'nested/01.02.02.createHubVnetWithFW.json' /*TODO: replace with correct path to [variables('hubVnetObj').createHubVnetWithFWUri]*/ = {
  name: '01.02.02.linkedDeploymentCreateHubVnetWithFW'
  params: {
    hubVnetObj: hubVnetObj
    routeTableObj: routeTableObj
    hubFwObj: hubFwObj
    hubJmpSubnetNSGId1: _01_01_00_linkedDeploymentCreateHubNSG.outputs.nsgResourceId1
  }
  dependsOn: [
    _01_00_00_linkedDeploymentCreateHubPublicIP

  ]
}

module _01_02_03_linkedDeploymentCreateHubAzureFw 'nested/01.02.03.createHubAzureFw.json' /*TODO: replace with correct path to [variables('hubFwObj').createHubAzureFwUri]*/ = {
  name: '01.02.03.linkedDeploymentCreateHubAzureFw'
  params: {
    hubFwObj: hubFwObj
    hubVnetObj: hubVnetObj
    jmpPublicIpResourceId: _01_00_00_linkedDeploymentCreateHubPublicIP.outputs.jmpPublicIpResourceId
    jmpPublicIpAddr: _01_00_00_linkedDeploymentCreateHubPublicIP.outputs.jmpServerPublicIpAddr
    localPIP: localMachinePublicIP
  }
  dependsOn: [
    _01_02_02_linkedDeploymentCreateHubVnetWithFW
  ]
}

module _01_04_01_linkedDeploymentCreateHubJmpServerFwNic 'nested/01.04.01.createHubJmpServerFwNic.json' /*TODO: replace with correct path to [variables('nicObj').createHubJmpServerFwNicUri]*/ = {
  name: '01.04.01.linkedDeploymentCreateHubJmpServerFwNic'
  params: {
    nicObj: nicObj
    ipObj: ipObj
    subnetJmpId: _01_02_02_linkedDeploymentCreateHubVnetWithFW.outputs.subnetJmpId
  }
}

module _01_05_00_linkedDeploymentCreateHubJmpServer 'nested/01.05.00.createHubJmpServer.json' /*TODO: replace with correct path to [variables('jmpServerObj').createHubJumpServerUri]*/ = {
  name: '01.05.00.linkedDeploymentCreateHubJmpServer'
  params: {
    jmpServerObj: jmpServerObj
    storageObj: storageObj
    hubJumpServerNicId: _01_04_01_linkedDeploymentCreateHubJmpServerFwNic.outputs.hubJumpServerNicId
  }
  dependsOn: [
    _01_01_00_linkedDeploymentCreateHubNSG

  ]
}

module _09_12_00_linkedDeploymentCreateAutoAcct 'nested/09.12.00.createAutoAcct.json' /*TODO: replace with correct path to [variables('createAutoAcctUri')]*/ = if (hubDeploymentOption == 'DeployHubWithFW') {
  name: '09.12.00.linkedDeploymentCreateAutoAcct'
  params: {
    autoAcctName: autoAcctName
    location: aaaRegionFullName
    automationSchedule: automationSchedule
  }
  dependsOn: []
}

module _10_13_00_linkedDeploymentCreateOmsWorkspace 'nested/10.13.00.createOmsWorkspace.json' /*TODO: replace with correct path to [variables('createOmsWorkspaceUri')]*/ = if (hubDeploymentOption == 'DeployHubWithFW') {
  name: '10.13.00.linkedDeploymentCreateOmsWorkspace'
  params: {
    omsWorkspaceName: omsWorkspaceName
    alaRegionFullName: alaRegionFullName
    autoAcctId: _09_12_00_linkedDeploymentCreateAutoAcct.outputs.autoAcctId
  }
}

output jmpServerPublicIpFqdn string = _01_00_00_linkedDeploymentCreateHubPublicIP.outputs.jmpServerPublicIpFqdn
output nsgResourceId1 string = _01_01_00_linkedDeploymentCreateHubNSG.outputs.nsgResourceId1
