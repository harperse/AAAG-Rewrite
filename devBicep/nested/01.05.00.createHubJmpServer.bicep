@description('Jump server object.')
param jmpServerObj object

@description('Storage account object for diagnostics logging.')
param storageObj object

@description('NIC resource id for jump server.')
param hubJumpServerNicId string

resource jmpServerObj_hubJumpServer 'Microsoft.Compute/virtualMachines@2017-03-30' = {
  name: jmpServerObj.hubJumpServerName
  location: jmpServerObj.location
  properties: {
    hardwareProfile: {
      vmSize: jmpServerObj.hubJumpServerSize
    }
    osProfile: {
      computerName: jmpServerObj.hubJumpServerName
      adminUsername: jmpServerObj.credObj.adminUserName
      adminPassword: jmpServerObj.credObj.adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: jmpServerObj.imagePublisher
        offer: jmpServerObj.imageOffer
        sku: jmpServerObj.imageSku
        version: jmpServerObj.imageVersion
      }
      osDisk: {
        name: jmpServerObj.diskNameOs
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: storageObj.saSku
        }
      }
      dataDisks: [
        {
          lun: 0
          name: jmpServerObj.diskNameData
          caching: 'None'
          createOption: 'Empty'
          diskSizeGB: 32
          managedDisk: {
            storageAccountType: storageObj.saSku
          }
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: hubJumpServerNicId
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: storageObj.diagHubStorageUri
      }
    }
  }
}
