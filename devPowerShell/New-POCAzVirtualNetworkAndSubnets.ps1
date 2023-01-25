[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)][ValidateSet("Hub", "Spoke")][string]$HubOrSpoke
)

Import-Module -Name Az.Network -Force
switch ($HubOrSpoke) {
    "Hub" {
        $subnets = @()
        # Create the Hub Jump Server Public IP Address
        $pipJumpServerProperties = $global:hubProperties.PIPJumpServer
        $global:hubResources.Add("JMPPIP", $(New-AzPublicIpAddress @pipJumpServerProperties `
                    -ResourceGroupName $global:hubResources.ResourceGroup.ResourceGroupName `
                    -Location $global:hubResources.ResourceGroup.Location `
                    -Tag $global:globalProperties.globalTags `
            )
        )

        $nsgRuleProperties = $global:hubProperties.NSGRulesJMP
        $nsgRule = New-AzNetworkSecurityRuleConfig @nsgRuleProperties

        $global:hubResources.Add("NSGPIP", $(New-AzNetworkSecurityGroup `
                    -Name $global:hubProperties.NSGNameJMP `
                    -ResourceGroupName $global:hubResources.ResourceGroup.ResourceGroupName `
                    -Location $global:hubResources.ResourceGroup.Location `
                    -SecurityRules $nsgRule
            )
        )

        if ($global:DeploymentOption -eq "DeployHubWithFW") {
            New-AzVirtualNetworkSubnetConfig `
                -Name $global:hubProperties.SubnetNameAFW `
                -AddressPrefix $global:hubProperties.SubnetAddressPrefixAFW
            $subnets += $afwSubnet
        }

        $jmpSubnet = New-AzVirtualNetworkSubnetConfig `
            -Name $global:hubProperties.SubnetNameJMP `
            -AddressPrefix $global:hubProperties.SubnetAddressPrefixJMP `
            -NetworkSecurityGroup $global:hubResources.NSGJMP.ResourceId
        $subnets += $jmpSubnet

        $global:hubResources.Add("Vnet", $(New-AzVirtualNetwork `
                    -Name $global:hubProperties.VnetName `
                    -ResourceGroupName $global:hubResources.ResourceGroup.ResourceGroupName `
                    -Location $global:hubResources.ResourceGroup.Location `
                    -AddressPrefix $global:hubProperties.VnetAddressPrefix `
                    -Subnet $subnets `
                    -Tag $global:globalProperties.globalTags
            )
        )

        $global:hubResources.Add("SubnetJMP", $($(Get-AzVirtualNetwork -Name $global:hubResources.Vnet.Name).Subnets | Where-Object { $_.Name -eq $global:hubProperties.SubnetNameJMP }))
        if ($global:DeploymentOption -eq "DeployHubWithFW") {
            $global:hubResources.Add("SubnetAFW", $($(Get-AzVirtualNetwork -Name $global:hubResources.Vnet.Name).Subnets | Where-Object { $_.Name -eq $global:hubProperties.SubnetNameAFW }))
        }
    }
    "Spoke" {
        $subnets = @()
        $global:spokeResources.Add("NSGADC", $(New-AzNetworkSecurityGroup `
                    -Name $global:spokeProperties.NSGNameADC `
                    -ResourceGroupName $global:spokeResources.ResourceGroup.ResourceGroupName `
                    -Location $global:spokeResources.ResourceGroup.Location `
                    -SecurityRules $global:spokeResources.NSGRulesADC `
            )
        )

        $global:spokeResources.Add("NSGSRV", $(New-AzNetworkSecurityGroup `
                    -Name $global:spokeProperties.NSGNameSRV `
                    -ResourceGroupName $global:spokeResources.ResourceGroup.ResourceGroupName `
                    -Location $global:spokeResources.ResourceGroup.Location `
                    -SecurityRules $global:spokeResources.NSGRulesSRV `
            )
        )

        $adcSubnet = New-AzVirtualNetworkSubnetConfig `
            -Name $global:spokeProperties.SubnetNameADC `
            -AddressPrefix $global:spokeProperties.SubnetAddressPrefixADC `
            -NetworkSecurityGroup $global:spokeResources.NSGADC.ResourceId
        $subnets += $adcSubnet
       
        $srvSubnet = New-AzVirtualNetworkSubnetConfig `
            -Name $global:spokeProperties.SubnetNameSRV `
            -AddressPrefix $global:spokeProperties.SubnetAddressPrefixSRV `
            -NetworkSecurityGroup $global:spokeResources.NSGSRV.ResourceId
        $subnets += $srvSubnet

        $global:spokeResources.Add("Vnet", $(New-AzVirtualNetwork `
                    -Name $global:spokeProperties.VnetName `
                    -ResourceGroupName $global:spokeResources.ResourceGroup.ResourceGroupName `
                    -Location $global:spokeResources.ResourceGroup.Location `
                    -AddressPrefix $global:spokeProperties.VnetAddressPrefix `
                    -Subnet $subnets `
                    -Tag $global:globalProperties.globalTags
            )
        )

        $global:spokeResources.Add("SubnetADC", $($(Get-AzVirtualNetwork -Name $global:spokeResources.Vnet.Name).Subnets | Where-Object { $_.Name -eq $global:spokeProperties.SubnetNameADC }))
        $global:spokeResources.Add("SubnetSRV", $($(Get-AzVirtualNetwork -Name $global:spokeResources.Vnet.Name).Subnets | Where-Object { $_.Name -eq $global:spokeProperties.SubnetNameSRV }))
    }
}