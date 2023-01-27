param hubVnetObj object
param hubJmpSubnetNSGId1 string

var hubVnetName = hubVnetObj.hubVnetName
var hubJmpSubnetName = hubVnetObj.hubJmpSubnetName
var subnetRefJmp = resourceId('Microsoft.Network/virtualNetworks/subnets', hubVnetName, hubJmpSubnetName)

resource hubVnetObj_hubVnet 'Microsoft.Network/virtualNetworks@2018-12-01' = {
  name: hubVnetObj.hubVnetName
  location: hubVnetObj.location
  properties: {
    addressSpace: {
      addressPrefixes: [
        hubVnetObj.hubVnetAddressSpace
      ]
    }
    subnets: [
      {
        name: hubVnetObj.hubJmpSubnetName
        properties: {
          addressPrefix: hubVnetObj.hubJmpSubnetRange
          networkSecurityGroup: {
            id: hubJmpSubnetNSGId1
          }
        }
      }
    ]
  }
}

output subnetJmpId string = subnetRefJmp
output vnetGuid string = resourceId('Microsoft.Network/virtualNetworks', hubVnetName)
