@description('NSG object to provision')
param nsgObj object

var nsgName = nsgObj.hubJumpSubnetNSG

resource nsgObj_hubJumpSubnetNSG 'Microsoft.Network/networkSecurityGroups@2017-10-01' = {
  name: nsgObj.hubJumpSubnetNSG
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
        name: nsgObj.nsgRule.name
        properties: {
          access: nsgObj.nsgRule.properties.access
          description: nsgObj.nsgRule.properties.description
          destinationAddressPrefix: nsgObj.nsgRule.properties.destinationAddressPrefix
          destinationPortRange: nsgObj.nsgRule.properties.destinationPortRange
          direction: nsgObj.nsgRule.properties.direction
          priority: nsgObj.nsgRule.properties.priority
          protocol: nsgObj.nsgRule.properties.protocol
          sourceAddressPrefix: nsgObj.nsgRule.properties.sourceAddressPrefix
          sourcePortRange: nsgObj.nsgRule.properties.sourcePortRange
        }
      }
    ]
  }
}

output nsgResourceId1 string = resourceId('Microsoft.Network/networkSecurityGroups', nsgName)
