[Parameter(Mandatory = $true)][Microsoft.Azure.Commands.ActiveDirectory.ParameterSet("Hub", "Spoke")][string]$HubOrSpoke

if ($HubOrSpoke -eq "Hub") {
    New-AzStorageAccount `
        -ResourceGroupName $hubResources.ResourceGroup.ResourceGroupName `
        -Name $hubProperties.storageAccountName `
        -Location $hubResources.ResourceGroup.Location `
        -SkuName $globalProperties.storageAccountSkuName `
        -Kind $globalProperties.storageAccountKind `
        -AccessTier $globalProperties.storageAccountAccessTier `
        -EnableHttpsTrafficOnly $true `
        -AllowBlobPublicAccess $true `
        -AllowSharedKeyAccess $true `
        -AllowCrossTenantReplication $true `
        -NetworkRuleSet @{"Bypass" = "AzureServices"; "DefaultAction" = "Allow" } `
        -MinimumTlsVersion TLS1_2 `
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
        -EnableHttpsTrafficOnly $true `
        -AllowBlobPublicAccess $true `
        -AllowSharedKeyAccess $true `
        -AllowCrossTenantReplication $true `
        -NetworkRuleSet @{"Bypass" = "AzureServices"; "DefaultAction" = "Allow" } `
        -RequireInfrastructureEncryption `
        -MinimumTlsVersion TLS1_2 `
        -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue }

    Update-AzStorageBlobServiceProperty `
        -Context $spokeResources.StorageAccount.Context `
        -EnableChangeFeed $false `
        -EnableVersioning $false `
        -EnableDeleteRetentionPolicy $false `
        -DeleteRetentionPolicyDays 7

    # Add container to spoke storage account
    New-AzStorageContainer `
        -Name $globalProperties.storageAccountContainerName `
        -Context $spokeResources.StorageAccount.Context `
        -Permission Container `
        -DefaultEncryptionScope '$account-encryption-key' `
        -PreventEncryptionScopeOverride $false `
        -PublicAccess "None" `

    $spokeResources.Add("StorageAccount", $(Get-AzStorageAccount -ResourceGroupName $spokeResources.ResourceGroup.ResourceGroupName -Name $spokeProperties.storageAccountName))
}