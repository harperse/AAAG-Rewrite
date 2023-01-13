[Parameter(Mandatory=$true)][Microsoft.Azure.Commands.ActiveDirectory.ParameterSet("Hub","Spoke")][string]$HubOrSpoke

switch ($HubOrSpoke) {
    "Hub" {
        New-AzVirtualNetworkSubnetConfig `
            -Name $hubProperties.subnetName `
            -AddressPrefix $hubProperties.subnetAddressPrefix
    }
    "Spoke" {

    }
}