[Parameter(Mandatory = $true)][ParameterSet("Hub", "Spoke")][string]$HubOrSpoke

if ($HubOrSpoke -eq "Hub") {
    $natRule1 = New-AzFirewallNatRule `
        -Name $hubProperties.NatRule1.RuleName `
        -SourceAddress $hubProperties.NatRule1.RuleSourceAddr `
        -TranslatedAddress $hubProperties.NatRule1.RuleTransAddr `
        -TranslatedPort $hubProperties.NatRule1.RuleTransPort `
        -DestinationPort $hubProperties.NatRule1.RuleDestPort `
        -Protocol $hubProperties.NatRule1.RuleProtocol
    
    $natRulesCollection = New-AzFirewallNatRuleCollection `
        -Name $hubProperties.NatRuleCollection.Name `
        -Priority $hubProperties.NatRuleCollection.Priority `
        -ActionType $hubProperties.NatRuleCollection.ActionType `
        -Rule $natRule1

    $networkRule1 = New-AzFirewallNetworkRule `
        -Name $hubProperties.NetworkRule1.Name `
        -SourceAddress $hubProperties.NetworkRule1.SourceAddr `
        -DestinationAddress $hubProperties.NetworkRule1.DestAddr `
        -DestinationPort $hubProperties.NetworkRule1.DestPort `
        -Protocol $hubProperties.NetworkRule1.Protocol

    $networkRule2 = New-AzFirewallNetworkRule `
        -Name $hubProperties.NetworkRule2.Name `
        -SourceAddress $hubProperties.NetworkRule2.SourceAddr `
        -DestinationAddress $hubProperties.NetworkRule2.DestAddr `
        -DestinationPort $hubProperties.NetworkRule2.DestPort `
        -Protocol $hubProperties.NetworkRule2.Protocol

    $networkRule3 = New-AzFirewallNetworkRule `
        -Name $hubProperties.NetworkRule3.Name `
        -SourceAddress $hubProperties.NetworkRule3.SourceAddr `
        -DestinationAddress $hubProperties.NetworkRule3.DestAddr `
        -DestinationPort $hubProperties.NetworkRule3.DestPort `
        -Protocol $hubProperties.NetworkRule3.Protocol

    $networkRulesCollection1 = New-AzFirewallNetworkRuleCollection `
        -Name $hubProperties.NetworkRuleCollection1.Name `
        -Priority $hubProperties.NetworkRuleCollection1.Priority `
        -ActionType $hubProperties.NetworkRuleCollection1.Action `
        -Rule $networkRule1

    $networkRulesCollection2 = New-AzFirewallNetworkRuleCollection `
        -Name $hubProperties.NetworkRuleCollection2.Name `
        -Priority $hubProperties.NetworkRuleCollection2.Priority `
        -ActionType $hubProperties.NetworkRuleCollection2.Action `
        -Rule $networkRule2, $networkRule3

    $applicationRule1 = New-AzFirewallApplicationRule `
        -Name $hubProperties.ApplicationRule1.Name `
        -SourceAddress $hubProperties.ApplicationRule1.SourceAddr `
        -FqdnTag $hubProperties.ApplicationRule1.FQDNTag

    $applicationRule2 = New-AzFirewallApplicationRule `
        -Name $hubProperties.ApplicationRule2.Name `
        -SourceAddress $hubProperties.ApplicationRule2.SourceAddr `
        -Protocol $hubProperties.ApplicationRule2.Protocol `
        -TargetFqdn $hubProperties.ApplicationRule2.TargetFQDN

    $appRulesCollection = New-AzFirewallApplicationRuleCollection `
        -Name $hubProperties.ApplicationRuleCollection.Name `
        -Priority $hubProperties.ApplicationRuleCollection.Priority `
        -ActionType $hubProperties.ApplicationRuleCollection.RuleAction `
        -Rule $applicationRule1, $applicationRule2

    New-AzFirewall `
        -Name $hubProperties.FWName `
        -ResourceGroupName $hubResources.ResourceGroup.Name `
        -Location $hubResources.ResourceGroup.Location `
        -Sku "AZFW_Hub" `
        -VirtualHub $hubResources.VHub `
        -PublicIpAddress $hubResources.PIPFW `
        -ThreatIntelMode "Deny" `
        -ThreatIntelWhitelist $hubProperties.FWThreatIntelWhitelist `
        -AdditionalProperties @{ "enableDnsProxy" = $true } `
        -Tag @{ $globalResources.TagName = $globalResources.TagValue} `
        -NatRuleCollection $natRulesCollection `
        -ApplicationRuleCollection $appRulesCollection
        -NetworkRuleCollection $networkRulesCollection1, $networkRulesCollection2 `
        -Verbose

    $hubResources.Add("Firewall", $(Get-AzFirewall -Name $hubProperties.FWName -ResourceGroupName $hubResources.ResourceGroup.Name))
}