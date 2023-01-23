if (Import-Module Az.MonitoringSolutions) {
    Install-Module Az.MonitoringSolutions -Force -Scope CurrentUser -Repository PSGallery
}

# Create log analytics workspace
Import-Module Az.OperationalInsights
Write-Output "Creating log analytics workspace $($hubProperties.operationalInsightsWorkspaceName) in $($alaToaaaMap[$selectedHubRegionCode].ala)..."
$global:hubResources.Add("OperationalInsightsWorkspace", $(New-AzOperationalInsightsWorkspace `
            -ResourceGroupName $global:hubResources.ResourceGroup.Name `
            -Location $alaToaaaMap[$selectedHubRegionCode].ala `
            -Name $hubProperties.operationalInsightsWorkspaceName `
            -Sku $hubProperties.operationalInsightsWorkspaceSku `
            -RetentionInDays $hubProperties.operationalInsightsWorkspaceRetentionInDays `
            -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue }
    )
)

# Add solutions to log analytics workspace
Write-Output "Adding solutions to log analytics workspace $($hubProperties.operationalInsightsWorkspaceName)..."
foreach ($solution in $lawMonitoringSolutions) {
    New-AzMonitorLogAnalyticsSolution `
        -ResourceGroupName $hubProperties.resourceGroupName `
        -WorkspaceId $global:hubResources.OperationalInsightsWorkspace.Id `
        -Type $solution -Verbose
}
