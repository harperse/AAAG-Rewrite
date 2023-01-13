[Parameter(Mandatory = $true)][Microsoft.Azure.Commands.ActiveDirectory.ParameterSet("Hub", "Spoke")][string]$HubOrSpoke

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
        
    $hubResources.Add("StorageAccount", $(Get-AzStorageAccount -ResourceGroupName $hubResources.ResourceGroup.ResourceGroupName -Name $hubProperties.storageAccountName))
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

    $spokeResources.Add("StorageAccount", $(Get-AzStorageAccount -ResourceGroupName $spokeResources.ResourceGroup.ResourceGroupName -Name $spokeProperties.storageAccountName))
}

# Add container to ???? storage account
New-AzStorageContainer `
    -Name $hubProperties.storageAccountContainerName `
    -Context $hubResources.StorageAccount.Context