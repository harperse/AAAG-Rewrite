[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)][ValidateSet("Hub", "Spoke")][string]$HubOrSpoke
)

switch ($HubOrSpoke) {
    "Hub" {
        $hubResources.Add("ResourceGroup", $(New-AzResourceGroup `
                    -Name $hubProperties.resourceGroupName `
                    -Location $azHubLocation `
                    -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue } `
                    -Force
            )
        )
    } # end "Hub"
    "Spoke" {
        $spokeResources.Add("ResourceGroup", $(New-AzResourceGroup `
                    -Name $spokeProperties.resourceGroupName `
                    -Location $azSpokeLocation `
                    -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue }
            )
        )
    } # end "Spoke"
} # end switch ($HubOrSpoke)
