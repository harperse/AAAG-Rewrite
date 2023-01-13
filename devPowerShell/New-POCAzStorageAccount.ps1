[Parameter(Mandatory=$true)][Microsoft.Azure.Commands.ActiveDirectory.ParameterSet("Hub","Spoke")][string]$HubOrSpoke

if ($HubOrSpoke -eq "Hub") {
    New-AzStorageAccount `
        -ResourceGroupName $hubResources.ResourceGroup.ResourceGroupName `
        -Name $hubProperties.storageAccountName `
        -Location $hubResources.ResourceGroup.Location `
        -SkuName $globalProperties.storageAccountSkuName `
        -Kind $globalProperties.storageAccountKind `
        -AccessTier $globalProperties.storageAccountAccessTier `
        -EnableHttpsTrafficOnly $globalProperties.storageAccountEnableHttpsTrafficOnly `
        -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue }
}
else {
    New-AzStorageAccount `
        -ResourceGroupName $spokeResources.ResourceGroup.ResourceGroupName `
        -Name $spokeProperties.storageAccountName `
        -Location $spokeResources.ResourceGroup.Location `
        -SkuName $globalProperties.storageAccountSkuName `
        -Kind $globalProperties.storageAccountKind `
        -AccessTier $globalProperties.storageAccountAccessTier `
        -EnableHttpsTrafficOnly $globalProperties.storageAccountEnableHttpsTrafficOnly `
        -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue }
}