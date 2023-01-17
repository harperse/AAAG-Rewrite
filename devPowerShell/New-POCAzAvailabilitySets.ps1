[Parameter(Mandatory = $true)][ParameterSet("Hub", "Spoke")][string]$HubOrSpoke

if ($HubOrSpoke -eq "Spoke") {
    
    New-AzAvailabilitySet `
        -Name $spokeProperties.AVSetNameADC `
        -ResourceGroupName $spokeResources.ResourceGroup.Name `
        -Location $spokeResources.ResourceGroup.Location `
        -Sku "Aligned" `
        -PlatformFaultDomainCount 2 `
        -PlatformUpdateDomainCount 5 `
        -Managed $true

    New-AzAvailabilitySet `
        -Name $spokeProperties.AVSetNameWES `
        -ResourceGroupName $spokeResources.ResourceGroup.Name `
        -Location $spokeResources.ResourceGroup.Location `
        -Sku "Aligned" `
        -PlatformFaultDomainCount 2 `
        -PlatformUpdateDomainCount 5 `
        -Managed $true

    New-AzAvailabilitySet `
        -Name $spokeProperties.AVSetNameSQL `
        -ResourceGroupName $spokeResources.ResourceGroup.Name `
        -Location $spokeResources.ResourceGroup.Location `
        -Sku "Aligned" `
        -PlatformFaultDomainCount 2 `
        -PlatformUpdateDomainCount 5 `
        -Managed $true

    New-AzAvailabilitySet `
        -Name $spokeProperties.AVSetNameDEV `
        -ResourceGroupName $spokeResources.ResourceGroup.Name `
        -Location $spokeResources.ResourceGroup.Location `
        -Sku "Aligned" `
        -PlatformFaultDomainCount 2 `
        -PlatformUpdateDomainCount 5 `
        -Managed $true

    $spokeResources.AVSetADC = Get-AzAvailabilitySet `
        -Name $spokeProperties.AVSetNameADC `
        -ResourceGroupName $spokeResources.ResourceGroup.Name

    $spokeResources.AVSetWES = Get-AzAvailabilitySet `
        -Name $spokeProperties.AVSetNameWES `
        -ResourceGroupName $spokeResources.ResourceGroup.Name

    $spokeResources.AVSetSQL = Get-AzAvailabilitySet `
        -Name $spokeProperties.AVSetNameSQL `
        -ResourceGroupName $spokeResources.ResourceGroup.Name

    $spokeResources.AVSetDEV = Get-AzAvailabilitySet `
        -Name $spokeProperties.AVSetNameDEV `
        -ResourceGroupName $spokeResources.ResourceGroup.Name

}