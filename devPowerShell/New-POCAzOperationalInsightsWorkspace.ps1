if (Import-Module Az.MonitoringSolutions) {
    Install-Module Az.MonitoringSolutions -Force -Scope CurrentUser -Repository PSGallery
}

# Create log analytics workspace
Import-Module Az.OperationalInsights
Write-Output "Creating log analytics workspace $($global:hubProperties.operationalInsightsWorkspaceName) in $($alaToaaaMap[$selectedHubRegionCode].ala)..."
$global:hubResources.Add("OperationalInsightsWorkspace", $(New-AzOperationalInsightsWorkspace `
            -ResourceGroupName $global:hubResources.ResourceGroup.Name `
            -Location $alaToaaaMap[$selectedHubRegionCode].ala `
            -Name $global:hubProperties.operationalInsightsWorkspaceName `
            -Sku $global:hubProperties.operationalInsightsWorkspaceSku `
            -RetentionInDays $global:hubProperties.operationalInsightsWorkspaceRetentionInDays `
            -Tag @{ $global:globalProperties.tagKey = $global:globalProperties.tagValue }
    )
)

# Add solutions to log analytics workspace
Write-Output "Adding solutions to log analytics workspace $($global:hubProperties.operationalInsightsWorkspaceName)..."
foreach ($solution in $lawMonitoringSolutions) {
    New-AzMonitorLogAnalyticsSolution `
        -ResourceGroupName $global:hubProperties.resourceGroupName `
        -WorkspaceId $global:hubResources.OperationalInsightsWorkspace.Id `
        -Type $solution -Verbose
}
