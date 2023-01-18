[Parameter(Mandatory = $true)][Microsoft.Azure.Commands.ActiveDirectory.ParameterSet("Hub", "Spoke")][string]$HubOrSpoke

if ($HubOrSpoke -eq "Hub") {
    $hubResources.Add("ResourceGroup", $(New-AzResourceGroup `
                -Name $hubProperties.resourceGroupName `
                -Location $selectedHubRegionCode `
                -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue }
        )
    )
}
else {
    $spokeResources.Add("ResourceGroup", $(New-AzResourceGroup `
                -Name $spokeProperties.resourceGroupName `
                -Location $selectedSpokeRegionCode `
                -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue })
    )
}