$global:spokeResources.Add("AVSetADC", $(New-AzAvailabilitySet `
            -Name $global:spokeProperties.AVSetNameADC `
            -ResourceGroupName $global:spokeResources.ResourceGroup.ResourceGroupName `
            -Location $global:spokeResources.ResourceGroup.Location `
            -Sku "Aligned" `
            -PlatformFaultDomainCount 2 `
            -PlatformUpdateDomainCount 5 `
            -Managed $true `
            -Tag @{ $global:globalProperties.TagName = $global:globalProperties.TagValue }
    )
)

$global:spokeResources.Add("AVSetWES", $(New-AzAvailabilitySet `
            -Name $global:spokeProperties.AVSetNameWES `
            -ResourceGroupName $global:spokeResources.ResourceGroup.ResourceGroupName `
            -Location $global:spokeResources.ResourceGroup.Location `
            -Sku "Aligned" `
            -PlatformFaultDomainCount 2 `
            -PlatformUpdateDomainCount 5 `
            -Managed $true `
            -Tag @{ $global:globalProperties.TagName = $global:globalProperties.TagValue }
    )
)

$global:spokeResources.Add("AVSetSQL", $(New-AzAvailabilitySet `
            -Name $global:spokeProperties.AVSetNameSQL `
            -ResourceGroupName $global:spokeResources.ResourceGroup.ResourceGroupName `
            -Location $global:spokeResources.ResourceGroup.Location `
            -Sku "Aligned" `
            -PlatformFaultDomainCount 2 `
            -PlatformUpdateDomainCount 5 `
            -Managed $true `
            -Tag @{ $global:globalProperties.TagName = $global:globalProperties.TagValue }
    )
)

$global:spokeResources.Add("AVSetDEV", $(New-AzAvailabilitySet `
            -Name $global:spokeProperties.AVSetNameDEV `
            -ResourceGroupName $global:spokeResources.ResourceGroup.ResourceGroupName `
            -Location $global:spokeResources.ResourceGroup.Location `
            -Sku "Aligned" `
            -PlatformFaultDomainCount 2 `
            -PlatformUpdateDomainCount 5 `
            -Managed $true `
            -Tag @{ $global:globalProperties.TagName = $global:globalProperties.TagValue }
    )
)