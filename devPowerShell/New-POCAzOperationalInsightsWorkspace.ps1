Import-Module Az.OperationalInsights -Force
if (!(Import-Module Az.MonitoringSolutions)) {
    Install-Module Az.MonitoringSolutions -Force -Scope CurrentUser -Repository PSGallery
}

# Create log analytics workspace
Write-Output "Creating log analytics workspace $($global:hubProperties.lawName) in $($global:hubResources.ResourceGroup.ResourceGroupName)..."
New-AzOperationalInsightsWorkspace `
    -ResourceGroupName $global:hubResources.ResourceGroup.ResourceGroupName `
    -Location $alaToaaaMap[$selectedHubRegionCode].ala `
    -Name $global:hubProperties.lawName `
    -Sku $global:hubProperties.lawSku `
    -RetentionInDays $global:hubProperties.lawRetentionInDays `
    -Tag $global:globalProperties.globalTags
$global:hubResources.Add("OperationalInsightsWorkspace", $(Get-AzOperationalInsightsWorkspace `
            -Name $global:hubProperties.lawName `
            -ResourceGroupName $global:hubResources.ResourceGroup.ResourceGroupName `
    )
)

# Add solutions to log analytics workspace
Write-Output "Adding solutions to log analytics workspace $($global:hubProperties.lawName)..."
foreach ($solution in $lawMonitoringSolutions) {
    New-AzMonitorLogAnalyticsSolution `
        -ResourceGroupName $global:hubResources.ResourceGroup.ResourceGroupName `
        -Location $global:HubResources.OperationalInsightsWorkspace.Location `
        -WorkspaceResourceId $global:hubResources.OperationalInsightsWorkspace.ResourceId `
        -Type $solution
}