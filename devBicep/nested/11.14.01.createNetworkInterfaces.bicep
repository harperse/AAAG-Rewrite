@description('Collection of network interface names.')
param nicCollection object

@description('Azure region.')
param location string

@description('ADDS subnet resource id.')
param subnetAddsRef string

@description('SRVS subnet resource id.')
param subnetSrvsRef string

@description('Public IP for development/jump/DSC server \'...dev01\'')
param dev01pipId string

@description('Private IP prefix for DCs (ads01,2)')
param adsPrivateIps object

@description('Whether resources for a replica domain controller will be provisioned.')
param includeAds string

var ads01PrivateIp = adsPrivateIps.ads01privIp
var ads02PrivateIp = adsPrivateIps.ads02privIp

resource nicCollection_ads01nic_name 'Microsoft.Network/networkInterfaces@2017-10-01' = {
  name: nicCollection.ads01nic.name
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: ads01PrivateIp
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: subnetAddsRef
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

resource nicCollection_dev01nic_name 'Microsoft.Network/networkInterfaces@2017-10-01' = {
  name: nicCollection.dev01nic.name
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          publicIPAddress: {
            id: dev01pipId
          }
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetSrvsRef
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

resource nicCollection_web01nic_name 'Microsoft.Network/networkInterfaces@2017-10-01' = {
  name: nicCollection.web01nic.name
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetSrvsRef
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

resource nicCollection_sql01nic_name 'Microsoft.Network/networkInterfaces@2017-10-01' = {
  name: nicCollection.sql01nic.name
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetSrvsRef
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

resource nicCollection_web02nic_name 'Microsoft.Network/networkInterfaces@2017-10-01' = {
  name: nicCollection.web02nic.name
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetSrvsRef
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

resource nicCollection_ads02nic_name 'Microsoft.Network/networkInterfaces@2017-10-01' = if (includeAds == 'yes') {
  name: nicCollection.ads02nic.name
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: ads02PrivateIp
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: subnetAddsRef
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

resource nicCollection_sql02nic_name 'Microsoft.Network/networkInterfaces@2017-10-01' = {
  name: nicCollection.sql02nic.name
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetSrvsRef
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

resource nicCollection_lnx01nic_name 'Microsoft.Network/networkInterfaces@2017-10-01' = {
  name: nicCollection.lnx01nic.name
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetSrvsRef
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

output ads01NicId string = nicCollection_ads01nic_name.id
output dev01NicId string = nicCollection_dev01nic_name.id
output webNicIds array = [
  nicCollection_web01nic_name.id
  nicCollection_web02nic_name.id
]
output sqlNicIds array = [
  nicCollection_sql01nic_name.id
  nicCollection_sql02nic_name.id
]
output adsNicIds array = [
  nicCollection_ads01nic_name.id
  nicCollection_ads02nic_name.id
]
output lnx01NicId string = nicCollection_lnx01nic_name.id
