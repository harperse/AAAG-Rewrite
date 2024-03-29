param lnxPrefix string
param location string
param adminUserName string

@secure()
param adminPassword string
param lnxAvSetId string
param lnx01nicId string
param saSku string
param diagStorageUri string
param vmSize string
param diskNameSuffix object

var lnx01name = '${lnxPrefix}${1}'
var lnxVmSize = vmSize
var imagePublisher = 'OpenLogic'
var imageOffer = 'CentOS'
var imageSku = '8_4'
var version = 'latest'
var diskNameOs = toUpper('${lnx01name}${diskNameSuffix.syst}')
var diskNameData = toUpper('${lnx01name}${diskNameSuffix.data}')

resource lnx01vm 'Microsoft.Compute/virtualMachines@2017-03-30' = {
  name: lnx01name
  location: location
  properties: {
    hardwareProfile: {
      vmSize: lnxVmSize
    }
    osProfile: {
      computerName: lnx01name
      adminUsername: adminUserName
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: imageSku
        version: version
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
          id: lnx01nicId
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
      id: lnxAvSetId
    }
  }
}
