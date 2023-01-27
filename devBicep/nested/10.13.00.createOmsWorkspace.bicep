param omsWorkspaceName string
param alaRegionFullName string

@description('Azure Automation Account resource ID')
param autoAcctId string

var Updates = {
  name: 'Updates(${omsWorkspaceName})'
  galleryName: 'Updates'
}
var ChangeTracking = {
  name: 'ChangeTracking(${omsWorkspaceName})'
  galleryName: 'ChangeTracking'
}
var AgentHealthAssessment = {
  name: 'AgentHealthAssessment(${omsWorkspaceName})'
  galleryName: 'AgentHealthAssessment'
}

resource omsWorkspace 'Microsoft.OperationalInsights/workspaces@2015-11-01-preview' = {
  name: omsWorkspaceName
  location: alaRegionFullName
  tags: {
  }
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource omsWorkspaceName_automation 'Microsoft.OperationalInsights/workspaces/linkedServices@2020-08-01' = {
  parent: omsWorkspace
  name: 'automation'
  properties: {
    resourceId: autoAcctId
  }
}

resource Updates_name 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = if (true) {
  name: Updates.name
  location: alaRegionFullName
  properties: {
    workspaceResourceId: omsWorkspace.id
  }
  plan: {
    name: Updates.name
    publisher: 'Microsoft'
    promotionCode: ''
    product: 'OMSGallery/${Updates.galleryName}'
  }
}

resource ChangeTracking_name 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = if (true) {
  name: ChangeTracking.name
  location: alaRegionFullName
  properties: {
    workspaceResourceId: omsWorkspace.id
  }
  plan: {
    name: ChangeTracking.name
    publisher: 'Microsoft'
    promotionCode: ''
    product: 'OMSGallery/${ChangeTracking.galleryName}'
  }
}

resource AgentHealthAssessment_name 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = if (true) {
  name: AgentHealthAssessment.name
  location: alaRegionFullName
  properties: {
    workspaceResourceId: omsWorkspace.id
  }
  plan: {
    name: AgentHealthAssessment.name
    publisher: 'Microsoft'
    promotionCode: ''
    product: 'OMSGallery/${AgentHealthAssessment.galleryName}'
  }
}
