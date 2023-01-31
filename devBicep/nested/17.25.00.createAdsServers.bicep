param adsPrefix string
param location string
param adminUserName string

@secure()
param adminPassword string
param adsAvSetId string
param adsNicIds array
param saSku string
param diagStorageUri string
param domainName string
//param domainJoinOptions string
param dscArtifactsUrl string
param dscUrlSasToken string
param vmSize string
param diskNameSuffix object

var adsName02 = '${adsPrefix}${'2'}'
var adsVmSize = vmSize
var imagePublisher = 'MicrosoftWindowsServer'
var imageOffer = 'WindowsServer'
var imageSku = '2019-Datacenter-Core-smalldisk'

resource ads02 'Microsoft.Compute/virtualMachines@2017-03-30' = {
  name: adsName02
  location: location
  properties: {
    hardwareProfile: {
      vmSize: adsVmSize
    }
    osProfile: {
      computerName: adsName02
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
        name: '${adsName02}${diskNameSuffix.syst}'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: saSku
        }
      }
      dataDisks: [
        {
          lun: 0
          name: '${adsName02}${diskNameSuffix.data}'
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
          id: adsNicIds[1]
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

resource adsName02_03_15_01_configureDC02 'Microsoft.Compute/virtualMachines/extensions@2017-03-30' = {
  parent: ads02
  name: '03.15.01.configureDC02'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.83'
    autoUpgradeMinorVersion: true
    settings: {
      modulesUrl: '${dscArtifactsUrl}/dsc/adsCnfgInstalldc02.ps1.zip${dscUrlSasToken}'
      configurationFunction: 'adsCnfgInstalldc02.ps1\\adsCnfgInstalldc02'
      Properties: {
        domainName: domainName
        dataDiskNumber: '2'
        dataDiskDriveLetter: 'F'
        domainAdminCredentials: {
          userName: adminUserName
          password: 'PrivateSettingsRef:domainAdminPassword'
        }
      }
    }
    protectedSettings: {
      Items: {
        domainAdminPassword: adminPassword
      }
    }
  }
}
