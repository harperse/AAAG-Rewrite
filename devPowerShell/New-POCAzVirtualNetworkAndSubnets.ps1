[Parameter(Mandatory = $true)][ParameterSet("Hub", "Spoke")][string]$HubOrSpoke
$subnets = @()

switch ($HubOrSpoke) {
    "Hub" {

        $jmpSubnet = New-AzVirtualNetworkSubnetConfig `
            -Name $global:hubProperties.SubnetNameJMP `
            -AddressPrefix $global:hubProperties.SubnetAddressPrefixJMP `
            -Tag @{ $global:globalProperties.TagName = $global:globalProperties.TagValue }

        $subnets += $jmpSubnet

        $pipJumpServerProperties = $global:hubProperties.PIPJumpServer
        $global:hubResources.Add("JMPPIP", $(New-AzPublicIpAddress @pipJumpServerProperties `
                    -ResourceGroupName $global:hubResources.ResourceGroup.ResourceGroupName `
                    -Location $global:hubResources.ResourceGroup.Location `
                    -Tag @{ $global:globalProperties.TagName = $global:globalProperties.TagValue } `
                    -AsJob
            )
        )

        $nsgRuleProperties = $global:hubProperties.NSGRulesJMP
        $nsgRule = New-AzNetworkSecurityRuleConfig @nsgRuleProperties 

        New-AzNetworkSecurityGroup `
            -Name $global:hubProperties.NSGNameJMP `
            -ResourceGroupName $global:hubResources.ResourceGroup.ResourceGroupName `
            -Location $global:hubResources.ResourceGroup.Location `
            -SecurityRules $nsgRule `
            -Subnet $jmpSubnet `
            -Tag @{ $global:globalProperties.TagName = $global:globalProperties.TagValue }

        if ($global:DeploymentOption -eq "DeployHubWithFW") {
            New-AzVirtualNetworkSubnetConfig `
                -Name $global:hubProperties.SubnetNameAFW `
                -AddressPrefix $global:hubProperties.SubnetAddressPrefixAFW `
                -Tag @{ $global:globalProperties.TagName = $global:globalProperties.TagValue } `

            $subnets += $afwSubnet
        }

        $global:hubResources.Add("Vnet", $(New-AzVirtualNetwork `
                    -Name $global:hubProperties.VnetName `
                    -ResourceGroupName $global:hubResources.ResourceGroup.ResourceGroupName `
                    -Location $global:hubResources.ResourceGroup.Location `
                    -AddressPrefix $global:hubProperties.VnetAddressPrefix `
                    -Subnet $subnets `
                    -Tag @{ $global:globalProperties.TagName = $global:globalProperties.TagValue }
            )
        )
    }
    "Spoke" {
        $adcSubnet = New-AzVirtualNetworkSubnetConfig `
            -Name $global:spokeProperties.SubnetNameADC `
            -AddressPrefix $global:spokeProperties.SubnetAddressPrefixADC `
            -Tag @{ $global:globalProperties.TagName = $global:globalProperties.TagValue }

        $subnets += $adcSubnet
        
        $srvSubnet = New-AzVirtualNetworkSubnetConfig `
            -Name $global:spokeProperties.SubnetNameSRV `
            -AddressPrefix $global:spokeProperties.SubnetAddressPrefixSRV `
            -Tag @{ $global:globalProperties.TagName = $global:globalProperties.TagValue }

        $subnets += $srvSubnet

        New-AzNetworkSecurityGroup `
            -Name $global:spokeProperties.NSGNameADC `
            -ResourceGroupName $global:spokeResources.ResourceGroup.ResourceGroupName `
            -Location $global:spokeResources.ResourceGroup.Location `
            -SecurityRules $global:spokeResources.NSGRulesADC `
            -Subnet $adcSubnet `
            -Tag @{ $global:globalProperties.TagName = $global:globalProperties.TagValue }

        New-AzNetworkSecurityGroup `
            -Name $global:spokeProperties.NSGNameSRV `
            -ResourceGroupName $global:spokeResources.ResourceGroup.ResourceGroupName `
            -Location $global:spokeResources.ResourceGroup.Location `
            -SecurityRules $global:spokeResources.NSGRulesSRV `
            -Subnet $srvSubnet `
            -Tag @{ $global:globalProperties.TagName = $global:globalProperties.TagValue }

        $global:spokeResources.Add("Vnet", $(New-AzVirtualNetwork `
                    -Name $global:spokeProperties.VnetName `
                    -ResourceGroupName $global:spokeResources.ResourceGroup.ResourceGroupName `
                    -Location $global:spokeResources.ResourceGroup.Location `
                    -AddressPrefix $global:spokeProperties.VnetAddressPrefix `
                    -Subnet $subnets `
                    -Tag @{ $global:globalProperties.TagName = $global:globalProperties.TagValue }
            )
        )
    }
}