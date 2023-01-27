param location string
param devPublicIPAddressType string
param domainNameLabel string
param fqdnLocation string

resource domainNameLabel_resource 'Microsoft.Network/publicIPAddresses@2017-10-01' = {
  name: domainNameLabel
  location: location
  properties: {
    publicIPAllocationMethod: devPublicIPAddressType
    dnsSettings: {
      domainNameLabel: domainNameLabel
      fqdn: fqdnLocation
    }
  }
}

output devPublicIpResourceId string = domainNameLabel_resource.id
output fqdn string = reference(domainNameLabel_resource.id, '2017-10-01').dnsSettings.fqdn
