#requires -version 7.0

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)][ValidateSet("Hub", "Spoke")][string]$HubOrSpoke
)

switch ($HubOrSpoke) {
    "Hub" {
        .\New-POCAzResourceGroup.ps1 -HubOrSpoke "Spoke"
        Add-Content -Path .\newpocazresourcegroup.azcli -Value "az group create --name $global:hubResources.ResourceGroupName --location $azHubLocation" -Force
    } # end "Hub"
    "Spoke" {
        Add-Content -Path .\newpocazresourcegroup.azcli -Value "az group create --name $global:spokeResources.ResourceGroupName --location $azSpokeLocation" -Force
    } # end "Spoke"
} # end switch ($HubOrSpoke)