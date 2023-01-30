[hashtable]$commonParameters = @{
    deploymentOption               = $DeploymentOption
    azureEnvironment               = $AzureEnvironment
    randomInfix                    = $uniqueGuidIdentifier
    adminUserName                  = $global:credential.UserName
    adminPassword                  = $global:credential.password
    vmSize                         = $global:globalProperties.vmSize
    storageAccountName             = $global:spokeProperties.storageAccountName
    storageContainerName           = $global:globalProperties.storageAccountContainerName
    artifactsLocation              = $null
    _artifactsLocationSasToken     = $null
    storageDnsSuffix               = $null
    dnsNameLabelSuffix             = $null
    AutomationAccountName          = $global:spokeProperties.aaName
    azureLogAnalyticsWorkspaceName = $global:spokeProperties.lawName
    aaaRegionFullName              = $global:globalProperties.aaLocation
    alaRegionFullName              = $global:globalProperties.lawLocation
    startupScheduleName            = $global:globalProperties.startSchedule
    scheduledStartTime             = $global:globalProperties.scheduledStartTime
    shutdownScheduleName           = $global:globalProperties.stopSchedule
    scheduledStopTime              = $global:globalProperties.scheduledStopTime
    scheduledExpiryTime            = $global:globalProperties.scheduledExpiryTime
}

[hashtable]$spokeParametersToFile = @{
    spokeLocation             = $azSpokeLocation
    spokeRegionCode                = $selectedSpokeRegionCode
    recoveryServicesVaultName = $global:spokeProperties.rsvName
    devServerName             = $global:spokeProperties.vmNameDev
    appVnetName               = $global:spokeProperties.VnetName
    includeAds                = "no"
}

[hashtable]$hubParametersToFile = @{
    hubLocation          = $azHubLocation
    hubRegionCode        = $selectedHubRegionCode
    hubStaName           = $global:hubProperties.storageAccountName
    hubJumpServerName    = $global:hubProperties.JMPVMName
    hubFwName            = $global:hubProperties.FWName
    hubJumpServerNic     = $global:hubProperties.JMPNicName
    localMachinePublicIP = $global:localMachinePublicIP
    hubVnetName          = $global:hubProperties.VnetName
    hubVnetAddressSpace  = $global:hubProperties.VnetAddressPrefix
    hubJmpSubnetName     = $global:hubProperties.SubnetNameJMP
    hubJmpSubnetRange    = $global:hubProperties.SubnetAddressPrefixJMP
    hubPublicIp          = $null
    hubJumpServerSize    = $global:globalProperties.vmSize
    hubJumpSubnetNSG     = $global:hubProperties.NSGNameJMP
}

[hashtable]$hubParametersWithFirewallToFile = @{
    hubFwSubnetName                = $global:hubProperties.SubnetNameAFW
    hubFwSubnetRange               = $global:hubProperties.SubnetAddressPrefixAFW
    hubRouteTable                  = $null
    hubRouteDisablePropagation     = $null
    hubRouteToAfwName              = $null
    hubRouteToAfwAddressPrefix     = $null
    hubRouteToAfwNextHopType       = $null
    hubRouteToAfwNextHopAddress    = $null
    hubFwPrvIp                     = $null
    hubRTS                         = $null
    hubRTSAddrPrefix               = $null
    hubFwNatRuleCollName           = $global:hubProperties.NatRuleCollection.Name
    hubFwNatRuleCollPriority       = $global:hubProperties.NatRuleCollection.Priority
    hubFwNatRuleCollAction         = $global:hubProperties.NatRuleCollection.ActionType
    hubFwNatRule01Name             = $global:hubProperties.NatRule1.Name
    hubFwNatRule01Protocol         = $global:hubProperties.NatRule1.Protocol
    hubFwNatRule01SourceAddr       = $global:hubProperties.NatRule1.SourceAddress
    hubFwNatRule01DestPort         = $global:hubProperties.NatRule1.DestinationPort
    hubFwNatRule01TranslatedAddr   = $global:hubProperties.NatRule1.TranslatedAddress
    hubFwNatRule01TranslatedPort   = $global:hubProperties.NatRule1.TranslatedPort
    hubFwNetworkRuleCollName       = $global:hubProperties.NetworkRuleCollection1.Name
    hubFwNetworkRuleCollPriority   = $global:hubProperties.NetworkRuleCollection1.Priority
    hubFwNetworkRuleCollAction     = $global:hubProperties.NetworkRuleCollection1.ActionType
    hubFwNetworkRule01Name         = $global:hubProperties.NetworkRule1.Name
    hubFwNetworkRule01Protocol     = $global:hubProperties.NetworkRule1.Protocol
    hubFwNetworkRule01SourceAddr   = $global:hubProperties.NetworkRule1.SourceAddress
    hubFwNetworkRule01DestPort     = $global:hubProperties.NetworkRule1.DestinationPort
    hubFwNetworkRule01DestAddr     = $global:hubProperties.NetworkRule1.DestinationAddress
    hubFwNetworkRuleCollName02     = $global:hubProperties.NetworkRuleCollection2.Name
    hubFwNetworkRuleCollPriority02 = $global:hubProperties.NetworkRuleCollection2.Priority
    hubFwNetworkRuleCollAction02   = $global:hubProperties.NetworkRuleCollection2.ActionType
    hubFwNetworkRule02Name         = $global:hubProperties.NetworkRule2.Name
    hubFwNetworkRule02Protocol     = $global:hubProperties.NetworkRule2.Protocol
    hubFwNetworkRule02SourceAddr   = $global:hubProperties.NetworkRule2.SourceAddress
    hubFwNetworkRule02DestPort     = $global:hubProperties.NetworkRule2.DestinationPort
    hubFwNetworkRule02DestAddr     = $global:hubProperties.NetworkRule2.DestinationAddress
    hubFwNetworkRule03Name         = $global:hubProperties.NetworkRule3.Name
    hubFwNetworkRule03Protocol     = $global:hubProperties.NetworkRule3.Protocol
    hubFwNetworkRule03SourceAddr   = $global:hubProperties.NetworkRule3.SourceAddress
    hubFwNetworkRule03DestPort     = $global:hubProperties.NetworkRule3.DestinationPort
    hubFwNetworkRule03DestAddr     = $global:hubProperties.NetworkRule3.DestinationAddress
    hubFwAppRuleCollName           = $global:hubProperties.ApplicationRuleCollection.Name
    hubFwAppRuleCollPriority       = $global:hubProperties.ApplicationRuleCollection.Priority
    hubFwAppRuleCollAction         = $global:hubProperties.ApplicationRuleCollection.ActionType
    hubFwAppRule01Name             = $global:hubProperties.ApplicationRule1.Name
    hubFwAppRule01SourceAddr       = $global:hubProperties.ApplicationRule1.SourceAddress
    hubFwAppRule01fqdnTags         = $global:hubProperties.ApplicationRule1.FqdnTags
    hubFwAppRule02Name             = $global:hubProperties.ApplicationRule2.Name
    hubFwAppRule02SourceAddr       = $global:hubProperties.ApplicationRule2.SourceAddress
    hubFwAppRule02Protocol         = $global:hubProperties.ApplicationRule2.Protocol
    hubFwAppRule02Port             = $global:hubProperties.ApplicationRule2.Port
    hubFwAppRule02TargetFqdn       = $global:hubProperties.ApplicationRule2.TargetFqdn
}

switch ($DeploymentOption) {
    "DeployAppOnly" {
        ConvertTo-Json -InputObject $($commonParameters + $spokeParametersToFile) -Depth 10 | Out-File -FilePath ".\DeploymentFiles\azureDeploy.parameters.json"
    } 
    "DeployHubWithoutFW" {
        ConvertTo-Json -InputObject $($commonParameters + $spokeParametersToFile) -Depth 10 | Out-File -FilePath ".\DeploymentFiles\azureDeploy.parameters.json"
        ConvertTo-Json -InputObject $($commonParameters + $hubParametersToFile) -Depth 10 | Out-File -FilePath ".\DeploymentFiles\azureDeployHubWithoutFW.parameters.json"
    } 
    "DeployHubWithFW" {
        ConvertTo-Json -InputObject $($commonParameters + $spokeParametersToFile) -Depth 10 | Out-File -FilePath ".\DeploymentFiles\azureDeploy.parameters.json"
        ConvertTo-Json -InputObject $($commonParameters + $hubParametersToFile + $hubParametersWithFirewallToFile) -Depth 10 | Out-File -FilePath ".\DeploymentFiles\azureDeployHubWithFW.parameters.json"
    }
}