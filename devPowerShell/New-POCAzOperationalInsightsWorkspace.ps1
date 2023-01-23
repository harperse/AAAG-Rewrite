if (!(Import-Module Az.MonitoringSolutions)) {
    Install-Module Az.MonitoringSolutions -Force -Scope CurrentUser -Repository PSGallery
}

# Create log analytics workspace
Import-Module Az.OperationalInsights
Write-Output "Creating log analytics workspace $($global:hubProperties.operationalInsightsWorkspaceName) in $($alaToaaaMap[$selectedHubRegionCode].ala)..."
$global:hubResources.Add("OperationalInsightsWorkspace", $(New-AzOperationalInsightsWorkspace `
            -ResourceGroupName $global:hubResources.ResourceGroup.ResourceGroupName `
            -Location $alaToaaaMap[$selectedHubRegionCode].ala `
            -Name $global:hubProperties.lawName `
            -Sku $global:hubProperties.lawSku `
            -RetentionInDays $global:hubProperties.lawRetentionInDays `
            -Tag @{ $global:globalProperties.tagKey = $global:globalProperties.tagValue }
    )
)

# Add solutions to log analytics workspace
Write-Output "Adding solutions to log analytics workspace $($global:hubProperties.lawName)..."
foreach ($solution in $lawMonitoringSolutions) {
    New-AzMonitorLogAnalyticsSolution `
        -ResourceGroupName $global:hubResources.ResourceGroup.ResourceGroupName `
        -WorkspaceId $global:hubResources.OperationalInsightsWorkspace.WorkspaceId `
        -Type $solution -Verbose
}
