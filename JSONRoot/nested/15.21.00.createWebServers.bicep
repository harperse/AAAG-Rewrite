param webPrefix string
param location string
param adminUserName string

@secure()
param adminPassword string
param webAvSetId string
param webNicIds array
param saSku string
param diagStorageUri string
param domainName string
param domainJoinOptions string
param vmSize string
param diskNameSuffix object

var webVmSize = vmSize
var webServerInstances = 2
var imagePublisher = 'MicrosoftWindowsServer'
var imageOffer = 'WindowsServer'
var imageSku = '2019-Datacenter-Core-smalldisk'

resource webPrefix_1 'Microsoft.Compute/virtualMachines@2017-03-30' = [for i in range(0, webServerInstances): {
  name: concat(webPrefix, (i + 1))
  location: location
  properties: {
    hardwareProfile: {
      vmSize: webVmSize
    }
    osProfile: {
      computerName: concat(webPrefix, (i + 1))
      adminUsername: adminUserName
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: imageSku
        version: 'latest'
      }
      osDisk: {
        name: concat(webPrefix, (i + 1), diskNameSuffix.syst)
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: saSku
        }
      }
      dataDisks: [
        {
          lun: 0
          name: concat(webPrefix, (i + 1), diskNameSuffix.data)
          caching: 'None'
          createOption: 'Empty'
          diskSizeGB: 32
          managedDisk: {
            storageAccountType: saSku
          }
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: webNicIds[i]
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: diagStorageUri
      }
    }
    availabilitySet: {
      id: webAvSetId
    }
  }
}]

resource webPrefix_1_joindomain 'Microsoft.Compute/virtualMachines/extensions@2017-12-01' = [for i in range(0, webServerInstances): {
  name: '${webPrefix}${(i + 1)}/joindomain'
  location: location
  tags: {
    displayName: 'JsonADDomainExtension'
  }
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'JsonADDomainExtension'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: 'true'
    settings: {
      Name: domainName
      User: '${adminUserName}@${domainName}'
      Restart: 'true'
      Options: domainJoinOptions
    }
    protectedSettings: {
      Password: adminPassword
    }
  }
  dependsOn: [
    'Microsoft.Compute/virtualMachines/${webPrefix}${(i + 1)}'
  ]
}]
