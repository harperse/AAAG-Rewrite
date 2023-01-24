[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)][ValidateSet("Hub", "Spoke")][string]$HubOrSpoke
)

switch ($HubOrSpoke) {
    "Hub" {
        Write-Output "Creating resource group $($global:hubProperties.resourceGroupName) in $($azHubLocation)..."
        $global:hubResources.Add("ResourceGroup", $(New-AzResourceGroup `
                    -Name $global:hubProperties.resourceGroupName `
                    -Location $azHubLocation `
                    -Tag $global:globalProperties.globalTags `
                    -Force
            )
        )
    } # end "Hub"
    "Spoke" {
        Write-Output "Creating resource group $($global:spokeProperties.resourceGroupName) in $($azSpokeLocation)..."
        $global:spokeResources.Add("ResourceGroup", $(New-AzResourceGroup `
                    -Name $global:spokeProperties.resourceGroupName `
                    -Location $azSpokeLocation `
                    -Tag $global:globalProperties.globalTags `
                    -Force
            )
        )
    } # end "Spoke"
} # end switch ($HubOrSpoke)
