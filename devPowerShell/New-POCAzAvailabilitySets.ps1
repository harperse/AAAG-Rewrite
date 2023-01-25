$spokeAvSetProperties = @{
    ResourceGroupName = $global:spokeResources.ResourceGroup.ResourceGroupName
    Location = $global:spokeResources.ResourceGroup.Location
    Sku = "Aligned"
    PlatformFaultDomainCount = 2
    PlatformUpdateDomainCount = 5 
    Managed = $true
    Tag = $global:globalProperties.globalTags
}
$global:spokeResources.Add("AVSetADC", $(New-AzAvailabilitySet @spokeAvSetProperties -Name $global:spokeProperties.AVSetNameADC))
$global:spokeResources.Add("AVSetWES", $(New-AzAvailabilitySet @spokeAvSetProperties -Name $global:spokeProperties.AVSetNameWES))
$global:spokeResources.Add("AVSetSQL", $(New-AzAvailabilitySet @spokeAvSetProperties -Name $global:spokeProperties.AVSetNameSQL))
$global:spokeResources.Add("AVSetDEV", $(New-AzAvailabilitySet @spokeAvSetProperties -Name $global:spokeProperties.AVSetNameDEV))