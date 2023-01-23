$spokeResources.Add("RSV", $(New-AzRecoveryServicesVault `
            -Name $spokeProperties.rsvName `
            -ResourceGroupName $spokeResources.ResourceGroup.Name `
            -Location $spokeResources.ResourceGroup.Location `
            -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue }
    )
)