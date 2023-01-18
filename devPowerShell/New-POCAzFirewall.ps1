[Parameter(Mandatory = $true)][ParameterSet("Hub", "Spoke")][string]$HubOrSpoke

if ($HubOrSpoke -eq "Hub") {
    $natRule1Properties = $hubProperties.NatRule1
    $natRule1 = New-AzFirewallNatRule @natRule1Properties
    
    $natRuleCollectionProperties = $hubProperties.NatRuleCollection
    $natRulesCollection = New-AzFirewallNatRuleCollection @natRuleCollectionProperties -Rule $natRule1

    $networkRule1Properties = $hubProperties.NetworkRule1
    $networkRule1 = New-AzFirewallNetworkRule @networkRule1Properties

    $networkRule2Properties = $hubProperties.NetworkRule2
    $networkRule2 = New-AzFirewallNetworkRule @networkRule2Properties

    $networkRule3Properties = $hubProperties.NetworkRule3
    $networkRule3 = New-AzFirewallNetworkRule @networkRule3Properties

    $networkRulesCollection1Properties = $hubProperties.NetworkRuleCollection1
    $networkRulesCollection1 = New-AzFirewallNetworkRuleCollection @networkRulesCollection1Properties -Rule $networkRule1

    $networkRulesCollection2Properties = $hubProperties.NetworkRuleCollection2
    $networkRulesCollection2 = New-AzFirewallNetworkRuleCollection @networkRulesCollection2Properties -Rule $networkRule2, $networkRule3
        
    $applicationRule1Properties = $hubProperties.ApplicationRule1
    $applicationRule1 = New-AzFirewallApplicationRule @applicationRule1Properties

    $applicationRule2Properties = $hubProperties.ApplicationRule2
    $applicationRule2 = New-AzFirewallApplicationRule @applicationRule2Properties

    $appRulesCollectionProperties = $hubProperties.ApplicationRuleCollection
    $appRulesCollection = New-AzFirewallApplicationRuleCollection @appRulesCollectionProperties -Rule $applicationRule1, $applicationRule2
        
    $hubResources.Add("Firewall", $(New-AzFirewall `
                -Name $hubProperties.FWName `
                -ResourceGroupName $hubResources.ResourceGroup.Name `
                -Location $hubResources.ResourceGroup.Location `
                -Sku $hubProperties.FWSku `
                -SkuTier $hubResources.FWSkuTier `
                -VirtualHub $hubResources.VHub `
                -PublicIpAddress $hubResources.JMPPIP `
                -ThreatIntelMode $hubProperties.FWThreatIntelMode `
                -NatRuleCollection $natRulesCollection `
                -ApplicationRuleCollection $appRulesCollection `
                -NetworkRuleCollection $networkRulesCollection1, $networkRulesCollection2 `
                -Tag @{ $globalResources.TagName = $globalResources.TagValue } `
                -Verbose -AsJob 
        )
    )
}