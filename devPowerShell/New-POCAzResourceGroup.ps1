[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)][ValidateSet("Hub", "Spoke")][string]$HubOrSpoke
)

switch ($HubOrSpoke) {
    "Hub" {
        Write-Output "Creating resource group $($hubProperties.resourceGroupName) in $($azHubLocation)..."
        $hubResources.Add("ResourceGroup", $(New-AzResourceGroup `
                    -Name $hubProperties.resourceGroupName `
                    -Location $azHubLocation `
                    -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue } `
                    -Force
            )
        )
    } # end "Hub"
    "Spoke" {
        Write-Output "Creating resource group $($spokeProperties.resourceGroupName) in $($azSpokeLocation)..."
        $spokeResources.Add("ResourceGroup", $(New-AzResourceGroup `
                    -Name $spokeProperties.resourceGroupName `
                    -Location $azSpokeLocation `
                    -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue } `
                    -Force
            )
        )
    } # end "Spoke"
} # end switch ($HubOrSpoke)
