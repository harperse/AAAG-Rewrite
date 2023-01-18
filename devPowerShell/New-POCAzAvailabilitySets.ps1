$spokeResources.Add("AVSetADC", $(New-AzAvailabilitySet `
            -Name $spokeProperties.AVSetNameADC `
            -ResourceGroupName $spokeResources.ResourceGroup.Name `
            -Location $spokeResources.ResourceGroup.Location `
            -Sku "Aligned" `
            -PlatformFaultDomainCount 2 `
            -PlatformUpdateDomainCount 5 `
            -Managed $true `
            -Tag @{ $globalResources.TagName = $globalResources.TagValue }
    )
)

$spokeResources.Add("AVSetWES", $(New-AzAvailabilitySet `
            -Name $spokeProperties.AVSetNameWES `
            -ResourceGroupName $spokeResources.ResourceGroup.Name `
            -Location $spokeResources.ResourceGroup.Location `
            -Sku "Aligned" `
            -PlatformFaultDomainCount 2 `
            -PlatformUpdateDomainCount 5 `
            -Managed $true `
            -Tag @{ $globalResources.TagName = $globalResources.TagValue }
    )
)

$spokeResources.Add("AVSetSQL", $(New-AzAvailabilitySet `
            -Name $spokeProperties.AVSetNameSQL `
            -ResourceGroupName $spokeResources.ResourceGroup.Name `
            -Location $spokeResources.ResourceGroup.Location `
            -Sku "Aligned" `
            -PlatformFaultDomainCount 2 `
            -PlatformUpdateDomainCount 5 `
            -Managed $true `
            -Tag @{ $globalResources.TagName = $globalResources.TagValue }
    )
)

$spokeResources.Add("AVSetDEV", $(New-AzAvailabilitySet `
            -Name $spokeProperties.AVSetNameDEV `
            -ResourceGroupName $spokeResources.ResourceGroup.Name `
            -Location $spokeResources.ResourceGroup.Location `
            -Sku "Aligned" `
            -PlatformFaultDomainCount 2 `
            -PlatformUpdateDomainCount 5 `
            -Managed $true `
            -Tag @{ $globalResources.TagName = $globalResources.TagValue }
    )
)