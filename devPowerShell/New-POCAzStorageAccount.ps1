[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)][ValidateSet("Hub", "Spoke")][string]$HubOrSpoke
)

$storageAccountProperties = $globalProperties.storageAccountProperties
switch ($HubOrSpoke) {
    "Hub" {
        $hubResources.Add("StorageAccount", $(New-AzStorageAccount @storageAccountProperties `
                    -ResourceGroupName $hubResources.ResourceGroup.ResourceGroupName `
                    -Name $hubProperties.storageAccountName `
                    -Location $hubResources.ResourceGroup.Location `
                    -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue }
            )
        )
    } # end "Hub"
    "Spoke" {
        $spokeResources.Add("StorageAccount", $(New-AzStorageAccount @storageAccountProperties `
                    -ResourceGroupName $spokeResources.ResourceGroup.ResourceGroupName `
                    -Name $spokeProperties.storageAccountName `
                    -Location $spokeResources.ResourceGroup.Location `
                    -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue }
            )
        )

        $blobProperties = $spokeResources.blobProperties
        Update-AzStorageBlobServiceProperty @blobProperties -Context $spokeResources.StorageAccount.Context

        # Add container to spoke storage account
        New-AzStorageContainer `
            -Name $globalProperties.storageAccountContainerName `
            -Context $spokeResources.StorageAccount.Context `
            -Permission Container `
            -DefaultEncryptionScope '$account-encryption-key' `
            -PreventEncryptionScopeOverride $false `
            -PublicAccess "None"
    } # end "Spoke"
} # end switch ($HubOrSpoke)