@description('Jump server NIC.')
param nicObj object

@description('IP properties')
param ipObj object

@description('Resource id for Jump server subnet')
param subnetJmpId string

resource nicObj_hubJumpServerNic 'Microsoft.Network/networkInterfaces@2018-11-01' = {
  name: nicObj.hubJumpServerNic
  location: nicObj.location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: ipObj.prvIpJumpServer
          privateIPAllocationMethod: ipObj.prvIpAllocationMethod
          privateIPAddressVersion: ipObj.prvIPAddressVersion
          subnet: {
            id: subnetJmpId
          }
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableIPForwarding: false
  }
}

output hubJumpServerNicId string = nicObj_hubJumpServerNic.id
