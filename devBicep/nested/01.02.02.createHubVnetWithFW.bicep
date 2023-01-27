param hubVnetObj object
param routeTableObj object
param hubFwObj object
param hubJmpSubnetNSGId1 string
param location string

var hubVnetName = hubVnetObj.hubVnetName
var hubJmpSubnetName = hubVnetObj.hubJmpSubnetName
var hubAfwSubnetName = hubFwObj.fwSubnetName
var subnetRefJmp = resourceId('Microsoft.Network/virtualNetworks/subnets', hubVnetName, hubJmpSubnetName)
var subnetRefAfw = resourceId('Microsoft.Network/virtualNetworks/subnets', hubVnetName, hubAfwSubnetName)


resource routeTableObj_hubRouteTable 'Microsoft.Network/routeTables@2018-02-01' = [for i in range(0, 1): {
  name: routeTableObj.hubRouteTable[i].name
  location: location
  tags: {
  }
  properties: {
    disableBgpRoutePropagation: routeTableObj.hubRouteDisablePropagation
    routes: [
      {
        name: routeTableObj.hubRouteToAfwName
        properties: {
          addressPrefix: routeTableObj.hubRouteToAfwAddrPrefix
          nextHopType: routeTableObj.hubRouteNextHopType
          nextHopIpAddress: routeTableObj.hubFwPrvIp
        }
      }
      {
        name: routeTableObj.hubRTS
        properties: {
          addressPrefix: routeTableObj.hubRTSAddrPrefix
          nextHopType: routeTableObj.hubRouteNextHopType
          nextHopIpAddress: routeTableObj.hubFwPrvIp
        }
      }
    ]
  }
}]

resource hubVnetObj_hubVnet 'Microsoft.Network/virtualNetworks@2018-12-01' = {
  name: hubVnetObj.hubVnetName
  location: hubVnetObj.location
  dependsOn: [
    routeTableObj_hubRouteTable
  ]
  tags: {
  }
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
          routeTable: {
            id: routeTableObj_hubRouteTable[0].id
          }
        }
      }
      {
        name: hubFwObj.fwSubnetName
        properties: {
          addressPrefix: hubFwObj.fwSubnetRange
        }
      }
    ]
  }
}

output subnetJmpId string = subnetRefJmp
output subnetAfwId string = subnetRefAfw
output vnetGuid string = resourceId('Microsoft.Network/virtualNetworks', hubVnetName)
