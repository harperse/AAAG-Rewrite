[Parameter(Mandatory = $true)][ParameterSet("Hub", "Spoke")][string]$HubOrSpoke
$subnets = @()

switch ($HubOrSpoke) {
    "Hub" {

        $jmpSubnet = New-AzVirtualNetworkSubnetConfig `
            -Name $hubProperties.SubnetNameJMP `
            -AddressPrefix $hubProperties.SubnetAddressPrefixJMP `
            -Tag @{ $globalResources.TagName = $globalResources.TagValue }

        $subnets += $jmpSubnet

        $pipJumpServerProperties = $hubProperties.PIPJumpServer
        $global:hubResources.Add("JMPPIP", $(New-AzPublicIpAddress @pipJumpServerProperties `
                    -ResourceGroupName $global:hubResources.ResourceGroup.Name `
                    -Location $global:hubResources.ResourceGroup.Location `
                    -Tag @{ $globalResources.TagName = $globalResources.TagValue } `
                    -AsJob
            )
        )

        $nsgRuleProperties = $hubProperties.NSGRuleNameJMP
        $nsgRule = New-AzNetworkSecurityRuleConfig @nsgRuleProperties 

        New-AzNetworkSecurityGroup `
            -Name $hubProperties.NSGNameJMP `
            -ResourceGroupName $global:hubResources.ResourceGroup.Name `
            -Location $global:hubResources.ResourceGroup.Location `
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

        $global:hubResources.Add("Vnet", $(New-AzVirtualNetwork `
                    -Name $hubProperties.VnetName `
                    -ResourceGroupName $global:hubResources.ResourceGroup.Name `
                    -Location $global:hubResources.ResourceGroup.Location `
                    -AddressPrefix $hubProperties.VnetAddressPrefix `
                    -Subnet $subnets `
                    -Tag @{ $globalResources.TagName = $globalResources.TagValue }
            )
        )
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
            -ResourceGroupName $global:spokeResources.ResourceGroup.Name `
            -Location $global:spokeResources.ResourceGroup.Location `
            -SecurityRules $global:spokeResources.NSGRulesADC `
            -Subnet $adcSubnet `
            -Tag @{ $globalResources.TagName = $globalResources.TagValue }

        New-AzNetworkSecurityGroup `
            -Name $spokeProperties.NSGNameSRV `
            -ResourceGroupName $global:spokeResources.ResourceGroup.Name `
            -Location $global:spokeResources.ResourceGroup.Location `
            -SecurityRules $global:spokeResources.NSGRulesSRV `
            -Subnet $srvSubnet `
            -Tag @{ $globalResources.TagName = $globalResources.TagValue }

        $global:spokeResources.Add("Vnet", $(New-AzVirtualNetwork `
                    -Name $spokeProperties.VnetName `
                    -ResourceGroupName $global:spokeResources.ResourceGroup.Name `
                    -Location $global:spokeResources.ResourceGroup.Location `
                    -AddressPrefix $spokeProperties.VnetAddressPrefix `
                    -Subnet $subnets `
                    -Tag @{ $globalResources.TagName = $globalResources.TagValue }
            )
        )
    }
}