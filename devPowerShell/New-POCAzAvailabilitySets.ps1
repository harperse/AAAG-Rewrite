$global:spokeResources.Add("AVSetADC", $(New-AzAvailabilitySet `
            -Name $spokeProperties.AVSetNameADC `
            -ResourceGroupName $global:spokeResources.ResourceGroup.Name `
            -Location $global:spokeResources.ResourceGroup.Location `
            -Sku "Aligned" `
            -PlatformFaultDomainCount 2 `
            -PlatformUpdateDomainCount 5 `
            -Managed $true `
            -Tag @{ $globalResources.TagName = $globalResources.TagValue }
    )
)

$global:spokeResources.Add("AVSetWES", $(New-AzAvailabilitySet `
            -Name $spokeProperties.AVSetNameWES `
            -ResourceGroupName $global:spokeResources.ResourceGroup.Name `
            -Location $global:spokeResources.ResourceGroup.Location `
            -Sku "Aligned" `
            -PlatformFaultDomainCount 2 `
            -PlatformUpdateDomainCount 5 `
            -Managed $true `
            -Tag @{ $globalResources.TagName = $globalResources.TagValue }
    )
)

$global:spokeResources.Add("AVSetSQL", $(New-AzAvailabilitySet `
            -Name $spokeProperties.AVSetNameSQL `
            -ResourceGroupName $global:spokeResources.ResourceGroup.Name `
            -Location $global:spokeResources.ResourceGroup.Location `
            -Sku "Aligned" `
            -PlatformFaultDomainCount 2 `
            -PlatformUpdateDomainCount 5 `
            -Managed $true `
            -Tag @{ $globalResources.TagName = $globalResources.TagValue }
    )
)

$global:spokeResources.Add("AVSetDEV", $(New-AzAvailabilitySet `
            -Name $spokeProperties.AVSetNameDEV `
            -ResourceGroupName $global:spokeResources.ResourceGroup.Name `
            -Location $global:spokeResources.ResourceGroup.Location `
            -Sku "Aligned" `
            -PlatformFaultDomainCount 2 `
            -PlatformUpdateDomainCount 5 `
            -Managed $true `
            -Tag @{ $globalResources.TagName = $globalResources.TagValue }
    )
)