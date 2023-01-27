[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)][ValidateSet("Hub", "Spoke")][string]$HubOrSpoke
)

switch ($HubOrSpoke) {
    "Hub" {
        Write-Output "Creating resource group $($global:hubProperties.resourceGroupName) in $($azHubLocation)..."
        New-AzResourceGroup `
            -Name $global:hubProperties.resourceGroupName `
            -Location $azHubLocation `
            -Tag $global:globalProperties.globalTags `
            -Force
        $global:hubResources.Add("ResourceGroup", $(Get-AzResourceGroup `
                    -Name $global:hubProperties.resourceGroupName `
                    -Location $azHubLocation `
            )
        )
    } # end "Hub"
    "Spoke" {
        Write-Output "Creating resource group $($global:spokeProperties.resourceGroupName) in $($azSpokeLocation)..."
        New-AzResourceGroup `
            -Name $global:spokeProperties.resourceGroupName `
            -Location $azSpokeLocation `
            -Tag $global:globalProperties.globalTags `
            -Force
        $global:spokeResources.Add("ResourceGroup", $(Get-AzResourceGroup `
                    -Name $global:spokeProperties.resourceGroupName `
                    -Location $azSpokeLocation `
            )
        )
    } # end "Spoke"
} # end switch ($HubOrSpoke)