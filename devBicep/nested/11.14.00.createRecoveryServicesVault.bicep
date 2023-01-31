@description('Name of recovery services vault.')
param rsvName string

@description('Azure region of recovery services vault.')
param location string

var rsvSkuName = 'RS0'

resource rsv 'Microsoft.RecoveryServices/vaults@2016-06-01' = {
  name: rsvName
  location: location
  tags: {
  }
  properties: {
  }
  sku: {
    name: rsvSkuName
  }
}
