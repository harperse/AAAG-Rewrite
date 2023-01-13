New-AzOperationalInsightsWorkspace `
    -ResourceGroupName $hubProperties.resourceGroupName `
    -Name $hubProperties.operationalInsightsWorkspaceName `
    -Location $hubResources.ResourceGroup.location `
    -Sku $hubProperties.operationalInsightsWorkspaceSku `
    -RetentionInDays $hubProperties.operationalInsightsWorkspaceRetentionInDays `
    -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue }

$hubResources.Add("OperationalInsightsWorkspace", $(Get-AzOperationalInsightsWorkspace -ResourceGroupName $hubProperties.resourceGroupName -Name $hubProperties.operationalInsightsWorkspaceName))