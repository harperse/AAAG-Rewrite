$hubResources.Add("OperationalInsightsWorkspace", $(New-AzOperationalInsightsWorkspace `
            -ResourceGroupName $hubProperties.resourceGroupName `
            -Name $hubProperties.operationalInsightsWorkspaceName `
            -Location $alaToaaaMap[$selectedHubRegionCode].ala `
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
