param adsPrefix string
param location string
param adminUserName string

@secure()
param adminPassword string
param adsAvSetId string
param ads01nicId string
param saSku string
param diagStorageUri string
param dscArtifactsUrl string
param dscUrlSasToken string
param vmSize string
param diskNameSuffix object

var ads01name = '${adsPrefix}${1}'
var adsVmSize = vmSize
var imagePublisher = 'MicrosoftWindowsServer'
var imageOffer = 'WindowsServer'
var imageSku = '2019-Datacenter-Core-smalldisk'
var diskNameOs = toUpper('${ads01name}${diskNameSuffix.syst}')
var diskNameData = toUpper('${ads01name}${diskNameSuffix.data}')

resource ads01vm 'Microsoft.Compute/virtualMachines@2017-03-30' = {
  name: ads01name
  location: location
  properties: {
    hardwareProfile: {
      vmSize: adsVmSize
    }
    osProfile: {
      computerName: ads01name
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
          id: ads01nicId
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
      id: adsAvSetId
    }
  }
}

resource ads01name_03_15_01_configureDC01 'Microsoft.Compute/virtualMachines/extensions@2017-03-30' = {
  parent: ads01vm
  name: '03.15.01.configureDC01'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.83'
    autoUpgradeMinorVersion: true
    settings: {
      modulesUrl: '${dscArtifactsUrl}/dsc/adsCnfgInstall.ps1.zip${dscUrlSasToken}'
      configurationFunction: 'adsCnfgInstall.ps1\\adsCnfgInstall'
    }
    protectedSettings: {
      Items: {
        domainAdminPassword: adminPassword
      }
    }
  }
}
