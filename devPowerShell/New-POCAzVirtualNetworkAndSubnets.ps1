[Parameter(Mandatory = $true)][ParameterSet("Hub", "Spoke")][string]$HubOrSpoke
$subnets = @()

switch ($HubOrSpoke) {
    "Hub" {

        $jmpSubnet = New-AzVirtualNetworkSubnetConfig `
            -Name $global:hubProperties.SubnetNameJMP `
            -AddressPrefix $global:hubProperties.SubnetAddressPrefixJMP `
            -Tag @{ $globalResources.TagName = $globalResources.TagValue }

        $subnets += $jmpSubnet

        $pipJumpServerProperties = $global:hubProperties.PIPJumpServer
        $global:hubResources.Add("JMPPIP", $(New-AzPublicIpAddress @pipJumpServerProperties `
                    -ResourceGroupName $global:hubResources.ResourceGroup.Name `
                    -Location $global:hubResources.ResourceGroup.Location `
                    -Tag @{ $globalResources.TagName = $globalResources.TagValue } `
                    -AsJob
            )
        )

        $nsgRuleProperties = $global:hubProperties.NSGRuleNameJMP
        $nsgRule = New-AzNetworkSecurityRuleConfig @nsgRuleProperties 

        New-AzNetworkSecurityGroup `
            -Name $global:hubProperties.NSGNameJMP `
            -ResourceGroupName $global:hubResources.ResourceGroup.Name `
            -Location $global:hubResources.ResourceGroup.Location `
            -SecurityRules $nsgRule `
            -Subnet $jmpSubnet `
            -Tag @{ $globalResources.TagName = $globalResources.TagValue }

        if ($global:DeploymentOption -eq "DeployHubWithFW") {
            New-AzVirtualNetworkSubnetConfig `
                -Name $global:hubProperties.SubnetNameAFW `
                -AddressPrefix $global:hubProperties.SubnetAddressPrefixAFW `
                -Tag @{ $globalResources.TagName = $globalResources.TagValue } `

            $subnets += $afwSubnet
        }

        $global:hubResources.Add("Vnet", $(New-AzVirtualNetwork `
                    -Name $global:hubProperties.VnetName `
                    -ResourceGroupName $global:hubResources.ResourceGroup.Name `
                    -Location $global:hubResources.ResourceGroup.Location `
                    -AddressPrefix $global:hubProperties.VnetAddressPrefix `
                    -Subnet $subnets `
                    -Tag @{ $globalResources.TagName = $globalResources.TagValue }
            )
        )
    }
    "Spoke" {
        $adcSubnet = New-AzVirtualNetworkSubnetConfig `
            -Name $global:spokeProperties.SubnetNameADC `
            -AddressPrefix $global:spokeProperties.SubnetAddressPrefixADC `
            -Tag @{ $globalResources.TagName = $globalResources.TagValue }

        $subnets += $adcSubnet
        
        $srvSubnet = New-AzVirtualNetworkSubnetConfig `
            -Name $global:spokeProperties.SubnetNameSRV `
            -AddressPrefix $global:spokeProperties.SubnetAddressPrefixSRV `
            -Tag @{ $globalResources.TagName = $globalResources.TagValue }

        $subnets += $srvSubnet

        New-AzNetworkSecurityGroup `
            -Name $global:spokeProperties.NSGNameADC `
            -ResourceGroupName $global:spokeResources.ResourceGroup.Name `
            -Location $global:spokeResources.ResourceGroup.Location `
            -SecurityRules $global:spokeResources.NSGRulesADC `
            -Subnet $adcSubnet `
            -Tag @{ $globalResources.TagName = $globalResources.TagValue }

        New-AzNetworkSecurityGroup `
            -Name $global:spokeProperties.NSGNameSRV `
            -ResourceGroupName $global:spokeResources.ResourceGroup.Name `
            -Location $global:spokeResources.ResourceGroup.Location `
            -SecurityRules $global:spokeResources.NSGRulesSRV `
            -Subnet $srvSubnet `
            -Tag @{ $globalResources.TagName = $globalResources.TagValue }

        $global:spokeResources.Add("Vnet", $(New-AzVirtualNetwork `
                    -Name $global:spokeProperties.VnetName `
                    -ResourceGroupName $global:spokeResources.ResourceGroup.Name `
                    -Location $global:spokeResources.ResourceGroup.Location `
                    -AddressPrefix $global:spokeProperties.VnetAddressPrefix `
                    -Subnet $subnets `
                    -Tag @{ $globalResources.TagName = $globalResources.TagValue }
            )
        )
    }
}