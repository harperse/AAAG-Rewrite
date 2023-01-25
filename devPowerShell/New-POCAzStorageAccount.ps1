[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)][ValidateSet("Hub", "Spoke")][string]$HubOrSpoke
)

Import-Module -Name Az.Storage -Force
$storageAccountProperties = $global:globalProperties.storageAccountProperties

# Create storage account
switch ($HubOrSpoke) {
    "Hub" {
        Write-Output "Creating storage account $($global:hubProperties.storageAccountName) in $($global:hubResources.ResourceGroup.ResourceGroupName)..."
        New-AzStorageAccount @storageAccountProperties `
            -ResourceGroupName $global:hubResources.ResourceGroup.ResourceGroupName `
            -Name $global:hubProperties.storageAccountName `
            -Location $global:hubResources.ResourceGroup.Location `
            -Tag $global:globalProperties.globalTags
        $global:hubResources.Add("StorageAccount", $(Get-AzStorageAccount `
                    -Name $global:hubProperties.storageAccountName `
                    -ResourceGroupName $global:hubResources.ResourceGroup.ResourceGroupName
            )
        )
    } # end "Hub"
    "Spoke" {
        Write-Output "Creating storage account $($global:spokeProperties.storageAccountName) in $($global:spokeResources.ResourceGroup.ResourceGroupName)..."
        New-AzStorageAccount @storageAccountProperties `
            -ResourceGroupName $global:spokeResources.ResourceGroup.ResourceGroupName `
            -Name $global:spokeProperties.storageAccountName `
            -Location $global:spokeResources.ResourceGroup.Location `
            -Tag $global:globalProperties.globalTags
        $global:spokeResources.Add("StorageAccount", $(Get-AzStorageAccount `
                    -Name $global:spokeProperties.storageAccountName `
                    -ResourceGroupName $global:spokeResources.ResourceGroup.ResourceGroupName
            )    
        )

        # Update storage account properties
        write-Output "Updating storage account properties for $($global:spokeResources.StorageAccount.StorageAccountName)..."
        Update-AzStorageBlobServiceProperty `
            -ResourceGroupName $global:spokeResources.ResourceGroup.ResourceGroupName `
            -StorageAccountName $global:spokeResources.StorageAccount.StorageAccountName `
            -EnableChangeFeed $global:spokeProperties.blobEnableChangeFeed
            
        # Add container to spoke storage account
        Write-Output "Adding container $($global:globalProperties.storageAccountContainerName) to $($global:spokeResources.StorageAccount.StorageAccountName)..."
        New-AzStorageContainer `
            -Name $global:globalProperties.storageAccountContainerName `
            -Context $global:spokeResources.StorageAccount.Context `
            -Permission Container `
            -DefaultEncryptionScope '$account-encryption-key' `
            -PreventEncryptionScopeOverride $false
        $global:spokeResources.Add("storageContainer", $(Get-AzStorageContainer `
                    -Name $global:globalProperties.storageAccountContainerName `
                    -Context $global:spokeResources.StorageAccount.Context
            )
        )
    } # end "Spoke"
} # end switch ($HubOrSpoke)