@description('Selected region where resources will be deployed.')
param location string

@description('Collection of NSG names to create.')
param nsgCollection array

var nsgRule = {
  name: 'AllowRdpInbound'
  properties: {
    access: 'Allow'
    description: 'Allow inbound RDP from internet'
    destinationAddressPrefix: 'VirtualNetwork'
    destinationPortRange: '3389'
    direction: 'Inbound'
    priority: 100
    protocol: 'Tcp'
    sourceAddressPrefix: 'Internet'
    sourcePortRange: '*'
  }
}

resource nsgCollection_resource 'Microsoft.Network/networkSecurityGroups@2017-10-01' = [for item in nsgCollection: {
  name: concat(item)
  location: location
  properties: {
    securityRules: [
      {
        name: nsgRule.name
        properties: {
          access: nsgRule.properties.access
          description: nsgRule.properties.description
          destinationAddressPrefix: nsgRule.properties.destinationAddressPrefix
          destinationPortRange: nsgRule.properties.destinationPortRange
          direction: nsgRule.properties.direction
          priority: nsgRule.properties.priority
          protocol: nsgRule.properties.protocol
          sourceAddressPrefix: nsgRule.properties.sourceAddressPrefix
          sourcePortRange: nsgRule.properties.sourcePortRange
        }
      }
    ]
  }
}]

output nsgResourceId1 string = resourceId('Microsoft.Network/networkSecurityGroups', nsgCollection[0])
output nsgResourceId2 string = resourceId('Microsoft.Network/networkSecurityGroups', nsgCollection[1])
