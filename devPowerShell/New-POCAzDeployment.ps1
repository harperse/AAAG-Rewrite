[Parameter(Mandatory=$true)][Microsoft.Azure.Commands.ActiveDirectory.ParameterSet("Hub","Spoke","Both")][string]$HubOrSpoke

switch ($HubOrSpoke) {
    {$_ -eq ("Hub" -or "Both")} {
        New-POCAzResourceGroup -HubOrSpoke "Hub"
        New-POCAzStorageAccount -HubOrSpoke "Hub"
    }
    {$_ -eq ("Spoke" -or "Both")} {
        New-POCAzResourceGroup -HubOrSpoke "Spoke"
        New-POCAzStorageAccount -HubOrSpoke "Spoke"
    }
    "Hub" {
        
        # Enable VNet Peering
        # Add ADDS IP for DNS
        # Link AAA to ALA
    }
    "Spoke" {}
}