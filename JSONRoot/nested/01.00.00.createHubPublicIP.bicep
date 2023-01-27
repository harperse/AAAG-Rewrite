param ipObj object
param hubDeploymentOption string

var publicIpLabel_var = ((toLower(hubDeploymentOption) == 'deployhubwithfw') ? ipObj.afwDomainNameLabelPrefix : ipObj.jmpDomainNameLabelPrefix)

resource publicIplabel 'Microsoft.Network/publicIPAddresses@2017-10-01' = {
  name: publicIpLabel_var
  location: ipObj.location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: ipObj.jmpPublicIPAddressType
    dnsSettings: {
      domainNameLabel: publicIpLabel_var
      fqdn: concat(publicIpLabel_var, ipObj.fqdnLocationSuffix)
    }
  }
}

output jmpPublicIpResourceId string = publicIplabel.id
output jmpServerPublicIpFqdn string = reference(publicIplabel.id, '2017-10-01').dnsSettings.fqdn
output jmpServerPublicIpAddr string = reference(publicIplabel.id, '2017-10-01').ipAddress
