$spokeResources.Add("RSV", $(New-AzRecoveryServicesVault `
            -Name $spokeResources.rsvName `
            -ResourceGroupName $spokeResources.ResourceGroup.Name `
            -Location $spokeResources.ResourceGroup.Location `
            -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue }
    )
)