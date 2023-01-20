[Parameter(Mandatory = $true)][Microsoft.Azure.Commands.ActiveDirectory.ParameterSet("Hub", "Spoke", "Both")][string]$HubOrSpoke

switch ($HubOrSpoke) {
    { $_ -eq ("Hub") } {
        New-POCAzDeployment -HubOrSpoke "Spoke"
        New-POCAzResourceGroup -HubOrSpoke "Hub"
        #New-POCAzStorageAccount -HubOrSpoke "Hub"
    }
    { $_ -eq ("Spoke") } {
        New-POCAzResourceGroup -HubOrSpoke "Spoke"
        #New-POCAzStorageAccount -HubOrSpoke "Spoke"
    }
}

# Everything else


    <#
    "Hub" {
        
        # Enable VNet Peering
        $SpokeVnetName = $parameters.regionCode + "-APP-NP-VNT-01"
        $HubVnet = Get-AzVirtualNetwork -Name $hubParameters.hubVnetName -ResourceGroupName $hubResourceGroupName -Verbose
        $SpokeVNet = Get-AzVirtualNetwork -Name $SpokeVnetName -ResourceGroupName $resourceGroupName -Verbose
        $HubtoSpokePeeringName = 'LinkTo' + $SpokeVnetName
        $SpoketoHubPeeringName = 'LinkTo' + $HubVnetName
        # Peer Hub VNet to Spoke VNet
        Add-AzVirtualNetworkPeering -Name $HubtoSpokePeeringName -VirtualNetwork $HubVnet -RemoteVirtualNetworkId $SpokeVnet.Id
        # Peer Spoke Vnet  to Hub VNet.
        Add-AzVirtualNetworkPeering -Name $SpoketoHubPeeringName -VirtualNetwork $SpokeVNet -RemoteVirtualNetworkId $HubVnet.Id

        # Add ADDS IP for DNS
        # Link AAA to ALA
        Set-AzOperationalInsightsLinkedService -ResourceGroupName $hubResources.ResourceGroup.Name -WorkspaceName $hubResources.LogAnalytics.Name -Name "Automation" -ResourceId $hubResources.AutomationAccount.Id 
        # AAA MI rights to Contributor
        $aaaManagedIdentityID = (Get-AzAutomationAccount -ResourceGroupName $aaaResourceGroupName -Name $AutomationAccountName).Identity.PrincipalId
        New-AzRoleAssignment -ObjectId $aaaManagedIdentityID -Scope "/subscriptions/$subscriptionId" -RoleDefinitionName "Contributor"

        # Output the FQDN endpoint for RDP connection
        if ($DeploymentOption -eq "DeployHubWithFW") {
            $hubFwPublicIp = Get-AzPublicIpAddress -Name $hubProperties.FwName -ResourceGroupName $$hubResources.ResourceGroup.Name -Verbose
            $hubFwPublicIpFqdn = $hubFwPublicIp.DnsSettings.Fqdn
            Write-Host "Azure Firewall Public IP FQDN: $hubFwPublicIpFqdn`:50000"
        }
        else {
            $hubVmPublicIp = Get-AzPublicIpAddress -Name $hubProperties.JMPVmName -ResourceGroupName $hubResources.ResourceGroup.Name -Verbose
            $hubVmPublicIpFqdn = $hubVmPublicIp.DnsSettings.Fqdn
            Write-Host "Hub VM Public IP FQDN: $hubVmPublicIpFqdn"
        }

        # ###
        $connectionMessage = @"
        To log into your new jump server: $serverName, you must change your login name to: $userName and specify the corresponding password you entered at the beginning of this script.
        Specify this DNS hostname for your RDP session: $fqdnEndPoint.
        "@
        Write-Output $connectionMessage
        # ###

        #Some other stuff
        if ($DeploymentOption -eq "DeployHubWithFW") {
            $hubRouteTable = $hubRegionCode + "-INF-NP-UDR-01"
            $hubFwSubnetName = "AzureFirewallSubnet"
            $hubFwSubnetRange = "10.10.0.0/24"
            $hubPublicIp = $hubFwName + "-PIP"
            $hubRouteTable = $hubRegionCode + "-INF-NP-UDR-01"
            $hubRouteDisablePropagation = $false
            # ZeroTraffic
            $hubRouteToAfwName = "ZeroTraffic"
            $hubRouteToAfwAddrPrefix = "0.0.0.0/0"
            $hubRouteNextHopType = "VirtualAppliance"
            $hubFwPrvIp = "10.10.0.4"
            $hubRouteToAfwNextHopAddress = $hubFwPrvIp
            # RouteToSpoke
            $hubRTS = "RouteToSpoke"
            $hubRTSAddrPrefix = "10.20.10.0/26"


            $appRouteTableObj = [PSCustomObject]@{
                tableName       = $regionCode + "-APP-NP-UDR-01"
                zeroRoute       = "ZeroTraffic"
                zeroAddrPrefix  = "0.0.0.0/0"
                zeroNextHopType = $hubRouteNextHopType
                zeroNextHopAddr = $hubFwPrvIp
                hubRoute        = "RouteToHub"
                hubAddrPrefix   = "10.10.0.0/22"
                hubNextHopType  = $hubRouteNextHopType
                hubNextHopAddr  = $hubFwPrvIp
            } # end PSCustomObject

            # Create route confiugration
            $zeroTrafficConfig = New-AzRouteConfig -Name $appRouteTableObj.zeroRoute -AddressPrefix $appRouteTableObj.zeroAddrPrefix -NextHopType $appRouteTableObj.zeroNextHopType -NextHopIpAddress $appRouteTableObj.zeroNextHopAddr -Verbose
            $hubTrafficConfig = New-AzRouteConfig -Name $appRouteTableObj.hubRoute -AddressPrefix $appRouteTableObj.hubAddrPrefix -NextHopType $appRouteTableObj.hubNextHopType -NextHopIpAddress $appRouteTableObj.hubNextHopAddr -Verbose
            $appRoutes = @($zeroTrafficConfig, $hubTrafficConfig)
            # Create route table
            $appRouteTableResource = New-AzRouteTable -ResourceGroupName $resourceGroupName -Location $regionFullName -Name $appRouteTableObj.tableName -Route $appRoutes -Force -Verbose
            # Get all subnet configurations in app vnet
            $appVnetResource = Get-AzVirtualNetwork -Name $appVnetName -ResourceGroupName $resourceGroupName
            # Assign route table to each subnet in app vnet
            Set-AzVirtualNetworkSubnetConfig -Name $appVnetResource.Subnets[0].Name -VirtualNetwork $appVnetResource -AddressPrefix $appVnetResource.Subnets[0].AddressPrefix -RouteTableId $appRouteTableResource.id -Verbose
            Set-AzVirtualNetworkSubnetConfig -Name $appVnetResource.Subnets[1].Name -VirtualNetwork $appVnetResource -AddressPrefix $appVnetResource.Subnets[1].AddressPrefix -RouteTableId $appRouteTableResource.id -Verbose
            # Apply changes and update configuration for virtual network
            $appVnetResource | Set-AzVirtualNetwork
        }
    }
    "Spoke" {}
}
#>