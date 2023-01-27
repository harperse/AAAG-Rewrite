param sqlPrefix string
param location string
param adminUserName string

@secure()
param adminPassword string
param sqlAvSetId string
param sqlNicIds array
param saSku string
param diagStorageUri string
param domainName string
param domainJoinOptions string
param vmSize string
param diskNameSuffix object
param cseScriptUri string
param appLockerPrepScript string

var sqlVmSize = vmSize
var sqlServerInstances = 2
var imagePublisher = 'MicrosoftWindowsServer'
var imageOffer = 'WindowsServer'
var imageSku = '2019-Datacenter-smalldisk'

resource sqlPrefix_1 'Microsoft.Compute/virtualMachines@2017-03-30' = [for i in range(0, sqlServerInstances): {
  name: concat(sqlPrefix, (i + 1))
  location: location
  properties: {
    hardwareProfile: {
      vmSize: sqlVmSize
    }
    osProfile: {
      computerName: concat(sqlPrefix, (i + 1))
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
        name: concat(sqlPrefix, (i + 1), diskNameSuffix.syst)
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: saSku
        }
      }
      dataDisks: [
        {
          lun: 0
          name: concat(sqlPrefix, (i + 1), diskNameSuffix.data)
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
          id: sqlNicIds[i]
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
      id: sqlAvSetId
    }
  }
}]

resource sqlPrefix_1_joindomain 'Microsoft.Compute/virtualMachines/extensions@2017-12-01' = [for i in range(0, sqlServerInstances): {
  name: '${sqlPrefix}${(i + 1)}/joindomain'
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
    'Microsoft.Compute/virtualMachines/${sqlPrefix}${(i + 1)}'
  ]
}]

resource sqlPrefix_1_installAppsAndFeatures 'Microsoft.Compute/virtualMachines/extensions@2019-07-01' = [for i in range(0, sqlServerInstances): {
  name: '${sqlPrefix}${(i + 1)}/installAppsAndFeatures'
  location: resourceGroup().location
  tags: {
    displayName: 'sqlServersCSE'
  }
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.9'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        cseScriptUri
      ]
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File ${appLockerPrepScript}'
    }
  }
  dependsOn: [
    'Microsoft.Compute/virtualMachines/${sqlPrefix}${(i + 1)}/extensions/joindomain'
  ]
}]
