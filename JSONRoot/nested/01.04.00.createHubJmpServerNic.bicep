@description('Jump server NIC.')
param nicObj object

@description('IP properties')
param ipObj object
param jmpPublicIpResourceId string

@description('Resource id for Jump server subnet')
param subnetJmpId string

resource nicObj_hubJumpServerNic 'Microsoft.Network/networkInterfaces@2017-10-01' = {
  name: nicObj.hubJumpServerNic
  location: nicObj.location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          publicIPAddress: {
            id: jmpPublicIpResourceId
            location: nicObj.location
            tags: {
            }
            sku: {
              name: 'Standard'
            }
            properties: {
              publicIPAllocationMethod: ipObj.prvIpAllocationMethod
              publicIPAddressVersion: ipObj.prvIPAddressVersion
              dnsSettings: {
              }
              ipTags: []
            }
          }
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
