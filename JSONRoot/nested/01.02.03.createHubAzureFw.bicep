param hubFwObj object
param hubVnetObj object
param jmpPublicIpResourceId string
param jmpPublicIpAddr string
param localPIP string

resource hubFwObj_fw 'Microsoft.Network/azureFirewalls@2019-04-01' = {
  name: hubFwObj.fwName
  location: resourceGroup().location
  tags: {
  }
  properties: {
    ipConfigurations: [
      {
        name: 'IpConfig1'
        properties: {
          privateIPAddress: concat(hubFwObj.hubFwPrvIp)
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', hubVnetObj.hubVnetName, hubFwObj.fwSubnetName)
          }
          publicIPAddress: {
            id: jmpPublicIpResourceId
          }
        }
      }
    ]
    threatIntelMode: 'Deny'
    networkRuleCollections: [
      {
        name: 'AllowInternet'
        properties: {
          priority: 1200
          action: {
            type: 'Allow'
          }
          rules: [
            {
              name: 'JumpAllowInternet'
              protocols: [
                'TCP'
              ]
              sourceAddresses: [
                '10.10.1.4'
              ]
              destinationAddresses: [
                '*'
              ]
              destinationPorts: [
                '80'
                '443'
              ]
            }
          ]
        }
      }
      {
        name: 'AllowHubandSpoke'
        properties: {
          priority: 1250
          action: {
            type: 'Allow'
          }
          rules: [
            {
              name: 'HubToSpoke'
              protocols: [
                'Any'
              ]
              sourceAddresses: [
                '10.10.0.0/22'
              ]
              destinationAddresses: [
                '10.20.10.0/26'
              ]
              destinationPorts: [
                '*'
              ]
            }
            {
              name: 'SpokeToHub'
              protocols: [
                'Any'
              ]
              sourceAddresses: [
                '10.20.10.0/26'
              ]
              destinationAddresses: [
                '10.10.0.0/22'
              ]
              destinationPorts: [
                '*'
              ]
            }
          ]
        }
      }
    ]
    applicationRuleCollections: [
      {
        name: 'AllowAzurePaaS'
        properties: {
          priority: 1300
          action: {
            type: 'Allow'
          }
          rules: [
            {
              name: 'AllowAzurePaaSServices'
              protocols: []
              fqdnTags: [
                'MicrosoftActiveProtectionService'
                'WindowsDiagnostics'
              ]
              targetFqdns: []
              sourceAddresses: [
                '10.10.0.0/22'
                '10.20.10.0/26'
              ]
            }
            {
              name: 'AllowLogAnalytics'
              protocols: [
                {
                  protocolType: 'Https'
                  port: 443
                }
              ]
              fqdnTags: []
              targetFqdns: [
                '*.ods.opinsights.azure.com'
                '*.oms.opinsights.azure.com'
                '*.blob.core.windows.net'
                '*.azure-automation.net'
              ]
              sourceAddresses: [
                '10.10.0.0/22'
                '10.20.10.0/26'
              ]
            }
          ]
        }
      }
    ]
    natRuleCollections: [
      {
        name: 'NATforRDP'
        properties: {
          priority: 1100
          action: {
            type: 'Dnat'
          }
          rules: [
            {
              name: 'RDPToJumpServer'
              protocols: [
                'TCP'
              ]
              translatedAddress: '10.10.1.4'
              translatedPort: '3389'
              sourceAddresses: [
                localPIP
              ]
              destinationAddresses: [
                jmpPublicIpAddr
              ]
              destinationPorts: [
                '50000'
              ]
            }
          ]
        }
      }
    ]
  }
}
