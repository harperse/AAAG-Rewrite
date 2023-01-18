[Parameter(Mandatory = $true)][ParameterSet("Hub", "Spoke")][string]$HubOrSpoke
$subnets = @()

switch ($HubOrSpoke) {
    "Hub" {

        $jmpSubnet = New-AzVirtualNetworkSubnetConfig `
            -Name $hubProperties.SubnetNameJMP `
            -AddressPrefix $hubProperties.SubnetAddressPrefixJMP `
            -Tag @{ $globalResources.TagName = $globalResources.TagValue }

        $subnets += $jmpSubnet

        New-AzPublicIpAddress `
            -Name $hubProperties.PubIPNameJMP `
            -ResourceGroupName $hubResources.ResourceGroup.Name `
            -Location $hubResources.ResourceGroup.Location `
            -AllocationMethod $hubProperties.PubIPAllocationMethod `
            -IdleTimeoutInMinutes $hubProperties.PubIPIdleTimeoutInMinutes `
            -Sku $hubProperties.PubIPSku `
            -Tier $hubProperties.PubIPTier `
            -Tag @{ $globalResources.TagName = $globalResources.TagValue } `
            -AsJob

        $hubResources.PubIPJMP = Get-AzPublicIpAddress `
            -Name $hubProperties.PubIPNameJMP `
            -ResourceGroupName $hubResources.ResourceGroup.Name `
            -Tag @{ $globalResources.TagName = $globalResources.TagValue }

        $nsgRule = New-AzNetworkSecurityRuleConfig `
            -Name $hubProperties.NSGRuleNameJMP.Name `
            -Description $hubProperties.NSGRuleNameJMP.Description `
            -Access $hubProperties.NSGRuleNameJMP.Access `
            -Direction $hubProperties.NSGRuleNameJMP.Direction `
            -Priority $hubProperties.NSGRuleNameJMP.Priority `
            -Protocol $hubProperties.NSGRuleNameJMP.Protocol `
            -SourceAddressPrefix $hubProperties.NSGRuleNameJMP.SourceAddressPrefix `
            -SourcePortRange $hubProperties.NSGRuleNameJMP.SourcePortRange `
            -DestinationAddressPrefix $hubProperties.NSGRuleNameJMP.DestinationAddressPrefix `
            -DestinationPortRange $hubProperties.NSGRuleNameJMP.DestinationPortRange

        New-AzNetworkSecurityGroup `
            -Name $hubProperties.NSGNameJMP `
            -ResourceGroupName $hubResources.ResourceGroup.Name `
            -Location $hubResources.ResourceGroup.Location `
            -SecurityRules $nsgRule `
            -Subnet $jmpSubnet `
            -Tag @{ $globalResources.TagName = $globalResources.TagValue }

        if ($global:DeploymentOption -eq "DeployHubWithFW") {
            New-AzVirtualNetworkSubnetConfig `
                -Name $hubProperties.SubnetNameAFW `
                -AddressPrefix $hubProperties.SubnetAddressPrefixAFW `
                -Tag @{ $globalResources.TagName = $globalResources.TagValue } `

            $subnets += $afwSubnet
        }

        New-AzVirtualNetwork `
            -Name $hubProperties.VnetName `
            -ResourceGroupName $hubResources.ResourceGroup.Name `
            -Location $hubResources.ResourceGroup.Location `
            -AddressPrefix $hubProperties.VnetAddressPrefix `
            -Subnet $subnets `
            -Tag @{ $globalResources.TagName = $globalResources.TagValue }

        $hubResources.Vnet = Get-AzVirtualNetwork `
            -Name $hubProperties.VnetName `
            -ResourceGroupName $hubResources.ResourceGroup.Name `

        $hubResources.JMPPIP = Get-AzPublicIpAddress `
            -Name $hubProperties.PubIPNameJMP `
            -ResourceGroupName $hubResources.ResourceGroup.Name `
    }
    "Spoke" {
        $adcSubnet = New-AzVirtualNetworkSubnetConfig `
            -Name $spokeProperties.SubnetNameADC `
            -AddressPrefix $spokeProperties.SubnetAddressPrefixADC `
            -Tag @{ $globalResources.TagName = $globalResources.TagValue }

        $subnets += $adcSubnet
        
        $srvSubnet = New-AzVirtualNetworkSubnetConfig `
            -Name $spokeProperties.SubnetNameSRV `
            -AddressPrefix $spokeProperties.SubnetAddressPrefixSRV `
            -Tag @{ $globalResources.TagName = $globalResources.TagValue }

        $subnets += $srvSubnet

        New-AzNetworkSecurityGroup `
            -Name $spokeProperties.NSGNameADC `
            -ResourceGroupName $spokeResources.ResourceGroup.Name `
            -Location $spokeResources.ResourceGroup.Location `
            -SecurityRules $spokeResources.NSGRulesADC `
            -Tag @{ $globalResources.TagName = $globalResources.TagValue } `
            -Subnet $adcSubnet

        New-AzNetworkSecurityGroup `
            -Name $spokeProperties.NSGNameSRV `
            -ResourceGroupName $spokeResources.ResourceGroup.Name `
            -Location $spokeResources.ResourceGroup.Location `
            -SecurityRules $spokeResources.NSGRulesSRV `
            -Tag @{ $globalResources.TagName = $globalResources.TagValue } `
            -Subnet $srvSubnet

        New-AzVirtualNetwork `
            -Name $spokeProperties.VnetName `
            -ResourceGroupName $spokeResources.ResourceGroup.Name `
            -Location $spokeResources.ResourceGroup.Location `
            -AddressPrefix $spokeProperties.VnetAddressPrefix `
            -Tag @{ $globalResources.TagName = $globalResources.TagValue } `
            -Subnet $subnets

        $spokeResources.Add("Vnet", $(Get-AzVirtualNetwork -Name $spokeProperties.VnetName -ResourceGroupName $spokeResources.ResourceGroup.Name))
    }
}