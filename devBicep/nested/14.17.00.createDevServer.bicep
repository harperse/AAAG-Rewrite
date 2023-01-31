param devPrefix string
param location string
param adminUserName string

@secure()
param adminPassword string
param devAvSetId string
param dev01nicId string
param saSku string
param diagStorageUri string
param domainName string
param domainJoinOptions string
param vmSize string
param diskNameSuffix object

var dev01name = '${devPrefix}${1}'
var devVmSize = vmSize
var imagePublisher = 'MicrosoftWindowsServer'
var imageOffer = 'WindowsServer'
var imageSku = '2019-Datacenter-smalldisk'
var diskNameOs = toUpper('${dev01name}${diskNameSuffix.syst}')
var diskNameData = toUpper('${dev01name}${diskNameSuffix.data}')

resource dev01vm 'Microsoft.Compute/virtualMachines@2017-03-30' = {
  name: dev01name
  location: location
  properties: {
    hardwareProfile: {
      vmSize: devVmSize
    }
    osProfile: {
      computerName: dev01name
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
        name: diskNameOs
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: saSku
        }
      }
      dataDisks: [
        {
          lun: 0
          name: diskNameData
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
          id: dev01nicId
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
      id: devAvSetId
    }
  }
}

resource dev01name_joindomain 'Microsoft.Compute/virtualMachines/extensions@2017-12-01' = {
  parent: dev01vm
  name: 'joindomain'
  location: location
  tags: {
    displayName: 'JsonADDomainExtension'
  }
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'JsonADDomainExtension'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
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
}
