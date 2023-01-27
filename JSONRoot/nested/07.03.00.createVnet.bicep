param vnet object
param subnetNames array
param subnetPrefixes array
param nsgId1 string
param nsgId2 string

var nsgIds = [
  nsgId1
  nsgId2
]
var subnetRefAdds = resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, subnetNames[0])
var subnetRefSrvs = resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, subnetNames[1])

resource vnet_name 'Microsoft.Network/virtualNetworks@2017-10-01' = {
  name: vnet.name
  location: vnet.location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnet.addressPrefix
      ]
    }
    subnets: [for j in range(0, 2): {
      name: subnetNames[j]
      properties: {
        addressPrefix: subnetPrefixes[j]
        networkSecurityGroup: {
          id: nsgIds[j]
        }
      }
    }]
  }
}

output subnetAddsId string = subnetRefAdds
output subnetSrvsId string = subnetRefSrvs
output vnetGuid string = vnet_name.id
