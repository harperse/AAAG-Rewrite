### Activate Azure with Administration and Governance PoC
### Requires -Version 3.0
### This PowerShell Script creates PoC Environment based on JSON Templates 


    
$HubVnetName = Read-Host 'Enter Hub VNet Name'
$HubVNetResourceGroupName = Read-Host 'Enter Hub VNet Resource Group Name'
$SpokeVnetName = Read-Host 'Enter Spoke VNet Name'
$SpokeVNetResourceGroupName = Read-Host 'Enter Spoke VNet Resource Group Name'
$HubtoSpokePeeringName = 'LinkTo' + $SpokeVnetName
$SpoketoHubPeeringName = 'LinkTo' + $HubVnetName
$HubVnet = Get-AzVirtualNetwork -Name $HubVnetName -ResourceGroupName $HubVNetResourceGroupName
$SpokeVNet = Get-AzVirtualNetwork -Name $SpokeVnetName -ResourceGroupName $SpokeVNetResourceGroupName

# Peer Hub VNet to Spoke VNet
Add-AzVirtualNetworkPeering -Name $HubtoSpokePeeringName -VirtualNetwork $HubVnet -RemoteVirtualNetworkId $SpokeVnet.Id

# Peer Spoke Vnet  to Hub VNet.
Add-AzVirtualNetworkPeering -Name $SpoketoHubPeeringName -VirtualNetwork $SpokeVNet -RemoteVirtualNetworkId $HubVnet.Id