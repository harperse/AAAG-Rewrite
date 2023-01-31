param ipObj object
param hubDeploymentOption string

var publicIpLabel = ((toLower(hubDeploymentOption) == 'deployhubwithfw') ? ipObj.afwDomainNameLabelPrefix : ipObj.jmpDomainNameLabelPrefix)

resource publicIplabel 'Microsoft.Network/publicIPAddresses@2017-10-01' = {
  name: publicIpLabel
  location: ipObj.location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: ipObj.jmpPublicIPAddressType
    dnsSettings: {
      domainNameLabel: publicIpLabel
      fqdn: '${publicIpLabel}${ipObj.fqdnLocationSuffix}'
    }
  }
}

output jmpPublicIpResourceId string = publicIplabel.id
output jmpServerPublicIpFqdn string = reference(publicIplabel.id, '2017-10-01').dnsSettings.fqdn
output jmpServerPublicIpAddr string = reference(publicIplabel.id, '2017-10-01').ipAddress
