[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)][ValidateSet("Hub", "Spoke")][string]$HubOrSpoke
)

Import-Module -Name Az.Network -Force
if ($HubOrSpoke -eq "Hub") {
    $natRule1Properties = $global:hubProperties.NatRule1
    $natRule1 = New-AzFirewallNatRule @natRule1Properties
    
    $natRuleCollectionProperties = $global:hubProperties.NatRuleCollection
    $natRulesCollection = New-AzFirewallNatRuleCollection @natRuleCollectionProperties -Rule $natRule1

    $networkRule1Properties = $global:hubProperties.NetworkRule1
    $networkRule1 = New-AzFirewallNetworkRule @networkRule1Properties

    $networkRule2Properties = $global:hubProperties.NetworkRule2
    $networkRule2 = New-AzFirewallNetworkRule @networkRule2Properties

    $networkRule3Properties = $global:hubProperties.NetworkRule3
    $networkRule3 = New-AzFirewallNetworkRule @networkRule3Properties

    $networkRulesCollection1Properties = $global:hubProperties.NetworkRuleCollection1
    $networkRulesCollection1 = New-AzFirewallNetworkRuleCollection @networkRulesCollection1Properties -Rule $networkRule1

    $networkRulesCollection2Properties = $global:hubProperties.NetworkRuleCollection2
    $networkRulesCollection2 = New-AzFirewallNetworkRuleCollection @networkRulesCollection2Properties -Rule $networkRule2, $networkRule3
        
    $applicationRule1Properties = $global:hubProperties.ApplicationRule1
    $applicationRule1 = New-AzFirewallApplicationRule @applicationRule1Properties

    $applicationRule2Properties = $global:hubProperties.ApplicationRule2
    $applicationRule2 = New-AzFirewallApplicationRule @applicationRule2Properties

    $appRulesCollectionProperties = $global:hubProperties.ApplicationRuleCollection
    $appRulesCollection = New-AzFirewallApplicationRuleCollection @appRulesCollectionProperties -Rule $applicationRule1, $applicationRule2
        
    New-AzFirewall `
        -Name $global:hubProperties.FWName `
        -ResourceGroupName $global:hubResources.ResourceGroup.ResourceGroupName `
        -Location $global:hubResources.ResourceGroup.Location `
        -Sku $global:hubProperties.FWSku `
        -SkuTier $global:hubResources.FWSkuTier `
        -VirtualHub $global:hubResources.VHub `
        -PublicIpAddress $global:hubResources.JMPPIP `
        -ThreatIntelMode $global:hubProperties.FWThreatIntelMode `
        -NatRuleCollection $natRulesCollection `
        -ApplicationRuleCollection $appRulesCollection `
        -NetworkRuleCollection $networkRulesCollection1, $networkRulesCollection2 `
        -Tag $global:globalProperties.globalTags `
        -Verbose
    $global:hubResources.Add("Firewall", $(Get-AzFirewall `
                -Name $global:hubProperties.FWName `
                -ResourceGroupName $global:hubResources.ResourceGroup.ResourceGroupName `
                -Location $global:hubResources.ResourceGroup.Location `
        )
    )
}