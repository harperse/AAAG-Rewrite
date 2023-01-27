param location string

@description('Collection of availability sets names.')
param avSet array

resource avSet_resource 'Microsoft.Compute/availabilitySets@2017-03-30' = [for item in avSet: {
  name: concat(item)
  location: location
  properties: {
    platformUpdateDomainCount: 5
    platformFaultDomainCount: 2
  }
  sku: {
    name: 'aligned'
  }
}]

output adsAvSetID string = resourceId('Microsoft.Compute/availabilitySets', avSet[0])
output webAvSetID string = resourceId('Microsoft.Compute/availabilitySets', avSet[1])
output sqlAvSetID string = resourceId('Microsoft.Compute/availabilitySets', avSet[2])
output devAvSetID string = resourceId('Microsoft.Compute/availabilitySets', avSet[3])
output lnxAvSetID string = resourceId('Microsoft.Compute/availabilitySets', avSet[4])
