Import-Module Az.Compute -Force

$spokeAvSetProperties = @{
    ResourceGroupName = $global:spokeResources.ResourceGroup.ResourceGroupName
    Location = $global:spokeResources.ResourceGroup.Location
    Sku = "Aligned"
    PlatformFaultDomainCount = 2
    PlatformUpdateDomainCount = 5 
    Tag = $global:globalProperties.globalTags
}
New-AzAvailabilitySet @spokeAvSetProperties -Name $global:spokeProperties.AVSetNameADC
$global:spokeResources.Add("AVSetADC", $(Get-AzAvailabilitySet `
            -Name $global:spokeProperties.AVSetNameADC `
            -ResourceGroupName $global:spokeResources.ResourceGroup.ResourceGroupName `
    )
)
New-AzAvailabilitySet @spokeAvSetProperties -Name $global:spokeProperties.AVSetNameWES
$global:spokeResources.Add("AVSetWES", $(Get-AzAvailabilitySet `
            -Name $global:spokeProperties.AVSetNameWES `
            -ResourceGroupName $global:spokeResources.ResourceGroup.ResourceGroupName `
    )
)
New-AzAvailabilitySet @spokeAvSetProperties -Name $global:spokeProperties.AVSetNameSQL
$global:spokeResources.Add("AVSetSQL", $(Get-AzAvailabilitySet `
            -Name $global:spokeProperties.AVSetNameSQL `
            -ResourceGroupName $global:spokeResources.ResourceGroup.ResourceGroupName `
    )
)
New-AzAvailabilitySet @spokeAvSetProperties -Name $global:spokeProperties.AVSetNameDEV
$global:spokeResources.Add("AVSetDEV", $(Get-AzAvailabilitySet `
            -Name $global:spokeProperties.AVSetNameDEV `
            -ResourceGroupName $global:spokeResources.ResourceGroup.ResourceGroupName `
    )
)