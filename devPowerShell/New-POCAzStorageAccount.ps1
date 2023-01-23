[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)][ValidateSet("Hub", "Spoke")][string]$HubOrSpoke
)

$storageAccountProperties = $globalProperties.storageAccountProperties

# Create storage account

switch ($HubOrSpoke) {
    "Hub" {
        Write-Output "Creating storage account $($hubProperties.storageAccountName) in $($hubResources.ResourceGroup.ResourceGroupName)..."
        $hubResources.Add("StorageAccount", $(New-AzStorageAccount @storageAccountProperties `
                    -ResourceGroupName $hubResources.ResourceGroup.ResourceGroupName `
                    -Name $hubProperties.storageAccountName `
                    -Location $hubResources.ResourceGroup.Location `
                    -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue }
            )
        )
    } # end "Hub"
    "Spoke" {
        Write-Output "Creating storage account $($spokeProperties.storageAccountName) in $($spokeResources.ResourceGroup.ResourceGroupName)..."
        $spokeResources.Add("StorageAccount", $(New-AzStorageAccount @storageAccountProperties `
                    -ResourceGroupName $spokeResources.ResourceGroup.ResourceGroupName `
                    -Name $spokeProperties.storageAccountName `
                    -Location $spokeResources.ResourceGroup.Location `
                    -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue }
            )
        )

        # Update storage account properties
        write-Output "Updating storage account properties for $($spokeResources.StorageAccount.StorageAccountName)..."
        $blobProperties = $spokeProperties.blobProperties
        Update-AzStorageBlobServiceProperty @blobProperties `
            -ResourceGroupName $spokeResources.ResourceGroup.ResourceGroupName `
            -StorageAccountName $spokeResources.StorageAccount.StorageAccountName `
            
        # Add container to spoke storage account
        Write-Output "Adding container $($globalProperties.storageAccountContainerName) to $($spokeResources.StorageAccount.StorageAccountName)..."
        New-AzStorageContainer `
            -Name $globalProperties.storageAccountContainerName `
            -Context $spokeResources.StorageAccount.Context `
            -Permission Container `
            -DefaultEncryptionScope '$account-encryption-key' `
            -PreventEncryptionScopeOverride $false
    } # end "Spoke"
} # end switch ($HubOrSpoke)