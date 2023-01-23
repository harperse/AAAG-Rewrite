[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)][ValidateSet("Hub", "Spoke")][string]$HubOrSpoke
)

$storageAccountProperties = $globalProperties.storageAccountProperties

# Create storage account

switch ($HubOrSpoke) {
    "Hub" {
        Write-Output "Creating storage account $($hubProperties.storageAccountName) in $($global:hubResources.ResourceGroup.ResourceGroupName)..."
        $global:hubResources.Add("StorageAccount", $(New-AzStorageAccount @storageAccountProperties `
                    -ResourceGroupName $global:hubResources.ResourceGroup.ResourceGroupName `
                    -Name $hubProperties.storageAccountName `
                    -Location $global:hubResources.ResourceGroup.Location `
                    -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue }
            )
        )
    } # end "Hub"
    "Spoke" {
        Write-Output "Creating storage account $($spokeProperties.storageAccountName) in $($global:spokeResources.ResourceGroup.ResourceGroupName)..."
        $global:spokeResources.Add("StorageAccount", $(New-AzStorageAccount @storageAccountProperties `
                    -ResourceGroupName $global:spokeResources.ResourceGroup.ResourceGroupName `
                    -Name $spokeProperties.storageAccountName `
                    -Location $global:spokeResources.ResourceGroup.Location `
                    -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue }
            )
        )

        # Update storage account properties
        write-Output "Updating storage account properties for $($global:spokeResources.StorageAccount.StorageAccountName)..."
        $blobProperties = $spokeProperties.blobProperties
        Update-AzStorageBlobServiceProperty @blobProperties `
            -ResourceGroupName $global:spokeResources.ResourceGroup.ResourceGroupName `
            -StorageAccountName $global:spokeResources.StorageAccount.StorageAccountName `
            
        # Add container to spoke storage account
        Write-Output "Adding container $($globalProperties.storageAccountContainerName) to $($global:spokeResources.StorageAccount.StorageAccountName)..."
        New-AzStorageContainer `
            -Name $globalProperties.storageAccountContainerName `
            -Context $global:spokeResources.StorageAccount.Context `
            -Permission Container `
            -DefaultEncryptionScope '$account-encryption-key' `
            -PreventEncryptionScopeOverride $false
    } # end "Spoke"
} # end switch ($HubOrSpoke)