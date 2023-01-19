$hubResources.Add("OperationalInsightsWorkspace", $(New-AzOperationalInsightsWorkspace `
            -ResourceGroupName $hubResources.ResourceGroup.Name `
            -Location $alaToaaaMap[$selectedHubRegionCode].ala `
            -Name $hubProperties.operationalInsightsWorkspaceName `
            -Sku $hubProperties.operationalInsightsWorkspaceSku `
            -RetentionInDays $hubProperties.operationalInsightsWorkspaceRetentionInDays `
            -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue }
    )
)

foreach ($solution in $lawMonitoringSolutions) {
    New-AzMonitorLogAnalyticsSolution `
        -ResourceGroupName $hubProperties.resourceGroupName `
        -WorkspaceId $hubResources.OperationalInsightsWorkspace.Id `
        -Type $solution -Verbose
}
