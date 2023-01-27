param vnet object
param subnetNames array
param subnetPrefixes array
param adsPrivateIps object

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
      }
    }]
    dhcpOptions: {
      dnsServers: [
        adsPrivateIps.ads01PrivIp
      ]
    }
  }
}
