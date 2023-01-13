[Parameter(Mandatory=$true)][Microsoft.Azure.Commands.ActiveDirectory.ParameterSet("Hub","Spoke")][string]$HubOrSpoke

if ($HubOrSpoke -eq "Hub") {
    New-AzResourceGroup `
        -Name $hubProperties.resourceGroupName `
        -Location $selectedHubRegionCode `
        -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue }
    
    $hubResources.Add("ResourceGroup", $(Get-AzResourceGroup -Name $hubProperties.resourceGroupName -Location $selectedHubRegionCode))
}
else {
    New-AzResourceGroup `
        -Name $spokeProperties.resourceGroupName `
        -Location $selectedSpokeRegionCode `
        -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue }
    
    $spokeResources.Add("ResourceGroup", $(Get-AzResourceGroup -Name $spokeProperties.resourceGroupName -Location $selectedSpokeRegionCode))
}