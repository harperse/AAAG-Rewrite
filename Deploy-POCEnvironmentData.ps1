#region Strings

[string[]]$requiredModules = @("Az.Accounts", "AzureAutomation", "xActiveDirectory", "xComputerManagement", "xStorage", "xNetworking", "xSmbShare")
[string]$uniqueGUIDIdentifier = $(New-Guid).Guid.ToString().Split("-")[0]

#endregion Strings

#region hashtables

$alaToaaaMap = @{
    CZEAS = @{
        reg = "eastasia"
        aaa = "southeastasia"
        ala = "southeastasia"
    } # end ht
    CZSEA = @{
        reg = "southeastasia"
        aaa = "southeastasia"
        ala = "southeastasia"
    } # end ht
    CZCUS = @{
        reg = "centralus"
        aaa = "eastus2"
        ala = "eastus"
    } # end ht
    CZEU1 = @{
        reg = "eastus"
        aaa = "eastus2"
        ala = "eastus"
    } # end ht
    CZEU2 = @{
        reg = "eastus2"
        aaa = "eastus2"
        ala = "eastus"
    } # end ht
    CZWU1 = @{
        reg = "westus"
        aaa = "westus2"
        ala = "westus2"
    } # end ht
    CZCUN = @{
        reg = "northcentralus"
        aaa = "eastus2"
        ala = "eastus"
    } # end ht
    CZSCU = @{
        reg = "southcentralus"
        aaa = "eastus2"
        ala = "eastus"
    } # end ht
    CZNEU = @{
        reg = "northeurope"
        aaa = "westeurope"
        ala = "westeurope"
    } # end ht
    CZWEU = @{
        reg = "westeurope"
        aaa = "westeurope"
        ala = "westeurope"
    } # end ht
    CZWJP = @{
        reg = "japanwest"
        aaa = "japaneast"
        ala = "japaneast"
    } # end ht
    CZEJP = @{
        reg = "japaneast"
        aaa = "japaneast"
        ala = "japaneast"
    } # end ht
    CZSBR = @{
        reg = "brazilsouth"
        aaa = "eastus2"
        ala = "eastus"
    } # end ht
    CZEAU = @{
        reg = "australiaeast"
        aaa = "australiasoutheast"
        ala = "australiasoutheast"
    } # end ht
    CZSAU = @{
        reg = "australiasoutheast"
        aaa = "australiasoutheast"
        ala = "australiasoutheast"
    } # end ht
    CZSIN = @{
        reg = "southindia"
        aaa = "centralindia"
        ala = "centralindia"
    } # end ht
    CZCIN = @{
        reg = "centralindia"
        aaa = "centralindia"
        ala = "centralindia"
    } # end ht
    CZWIN = @{
        reg = "westindia"
        aaa = "centralindia"
        ala = "centralindia"
    } # end ht
    CZCCA = @{
        reg = "canadacentral"
        aaa = "canadacentral"
        ala = "canadacentral"
    } # end ht
    CZECA = @{
        reg = "canadaeast"
        aaa = "canadacentral"
        ala = "canadacentral"
    } # end ht
    CZSUK = @{
        reg = "uksouth"
        aaa = "uksouth"
        ala = "uksouth"
    } # end ht
    CZWUK = @{
        reg = "ukwest"
        aaa = "uksouth"
        ala = "uksouth"
    } # end ht
    CZWCU = @{
        reg = "westcentralus"
        aaa = "westcentralus"
        ala = "westcentralus"
    } # end ht
    CZWU2 = @{
        reg = "westus2"
        aaa = "westus2"
        ala = "westus2"
    } # end ht
    CZCKR = @{
        reg = "koreacentral"
        aaa = "southeastasia"
        ala = "southeastasia"
    } # end ht
    CZSKR = @{
        reg = "koreasouth"
        aaa = "southeastasia"
        ala = "southeastasia"
    } # end ht
    CZCFR = @{
        reg = "francecentral"
        aaa = "westeurope"
        ala = "westeurope"
    } # end ht
    CZSFR = @{
        reg = "francesouth"
        aaa = "westeurope"
        ala = "westeurope"
    } # end ht
    CZCAU = @{
        reg = "australiacentral"
        aaa = "australiasoutheast"
        ala = "australiasoutheast"
    } # end ht
    CZCA2 = @{
        reg = "australiacentral2"
        aaa = "australiasoutheast"
        ala = "australiasoutheast"
    } # end ht
    CZNSA = @{
        reg = "southafricanorth"
        aaa = "westeurope"
        ala = "westeurope"
    } # end ht
    CZWSA = @{
        reg = "southafricawest"
        aaa = "westeurope"
        ala = "westeurope"
    } # end ht
    USGVA = @{
        reg = "usgovvirginia"
        aaa = "usgovvirginia"
        ala = "usgovvirginia"
    } # end ht
    USGTX = @{
        reg = "usgovtexas"
        aaa = "usgovvirginia"
        ala = "usgovvirginia"
    } # end ht
} # end hashtable

$namingConstructs = @{
    staNC    = 'sta'
    rgNC     = 'RGP-01'
    vNetNC   = 'VNT-01'
    rsvNC    = 'RSV-01'
    alaNC    = 'ALA-01'
    aaaNC    = 'AAA-01'
    afwNC    = 'AFW-01'
    subnetNC = 'SUB-01'
    nsgNC    = 'NSG-01'
    pipNC    = 'PIP-01'
    udrNC    = 'UDR-01'
    fwNC     = 'AFW-01'
}

[hashtable]$globalProperties = @{
    tagKey                               = "Creator"
    tagValue                             = "Microsoft Governance POC Script"
    storageAccountKind                   = "StorageV2"
    storageAccountSkuName                = "Standard_LRS"
    storageAccountAccessTier             = "Hot"
    storageAccountEnableHttpsTrafficOnly = $true

    vmAdminUserName                      = 'adm.infra.user'
    vmSize                               = 'Standard_D1_v2'
}

[hashtable]$hubProperties = @{
    hubNC                                      = 'INF'
    hubStaPrefix                               = 1
    #ResourceGroup
    resourceGroupName                          = $selectedHubRegionCode, $hubProperties.hubNC, "NP", $namingConstructs.rgNC -join "-"
    #StorageAccount
    storageAccountName                         = $hubProperties.hubStaPrefix, $namingConstructs.staNC, $uniqueGUIDIdentifier -join $null
    storageAccountContainerName                = 'stageartifacts'
    #AutomationAccount
    automationAccountName                      = $selectedHubRegionCode, $namingConstructs.aaaNC, "NP", $uniqueGUIDIdentifier, $namingConstructs.aaaNC -join "-"
    automationAccountPlan                      = "Basic"
    automationAccountAssignSystemIdentity      = $true # For reference only
    automationAccountScheduleDescriptionStart  = "Start 0800 Weekdays LOCAL"
    automationAccountScheduleNameStart         = "Start 0800 Weekdays LOCAL"
    automationAccountScheduleStartTimeStart    = [datetime]::utcnow.AddDays(1).ToString("yyyy-MM-ddT08:00:00")
    automationAccountScheduleExpiryTimeStart   = "9999-12-31T00:00:00-00:00"
    automationAccountScheduleWeekIntervalStart = 1
    automationAccountScheduleDaysOfWeekStart   = "Monday,Tuesday,Wednesday,Thursday,Friday"
    automationAccountScheduleTimezoneStart     = "UTC"
    automationAccountScheduleDescriptionStop   = "Stop 1800 Weekdays LOCAL" 
    automationAccountScheduleNameStop          = "Stop 1800 Weekdays LOCAL"
    automationAccountScheduleStartTimeStop     = [datetime]::utcnow.AddDays(1).ToString("yyyy-MM-ddT18:00:00")
    automationAccountScheduleExpiryTimeStop    = "9999-12-31T00:00:00-00:00"
    automationAccountScheduleWeekIntervalStop  = 1
    automationAccountScheduleDaysOfWeekStop    = "Monday,Tuesday,Wednesday,Thursday,Friday"
    automationAccountScheduleTimezoneStop      = "UTC"
    #LogAnalyticsWorkspace
    logAnalyticsWorkspaceName                  = $selectedHubRegionCode, $hubResources.hubNC, "NP", $uniqueGUIDIdentifier, $namingConstructs.alaNC -join "-"
    logAnalyticsWorkspaceSku                   = "PerGB2018"
    logAnalyticsWorkspaceRetentionInDays       = 30
    #VirtualNetworkSubnets
    #JumpSubnetResources
    SubnetNameJMP                              = $selectedHubRegionCode, $hubResources.hubNC, "NP", $namingConstructs.subnetNC -join "-"
    SubnetAddressPrefixJMP                     = "10.10.1.0/24"
    NSGNameJMP                                 = $selectedHubRegionCode, $hubResources.hubNC, "NP", $namingConstructs.nsgNC -join "-"
    NSGRulesJMP                                = @{}
    #AFWSubnetResources
    SubnetNameAFW                              = "AzureFirewallSubnet"
    SubnetAddressPrefixAFW                     = "10.10.0.0/24"
    #JumpServerPIP
    PIPNameJMP                                 = $selectedHubRegionCode, $hubResources.hubNC, $namingConstructs.pipNC -join "-"
    PubIPAllocationMethod                      = "Dynamic"
    PubIPSku                                   = "Standard"
    PuBIPTier                                  = "Regional"
    PubIPIdleTimeoutInMinutes                  = 4
    #JumpServer
    VMNameJMP                                  = $selectedHubRegionCode, $hubResources.hubNC, "NP-JMP-01" -join "-"
    #VirtualNetwork
    #AzureFirewall
    FWName                                     = $selectedHubRegionCode, $hubResources.hubNC, "NP", $namingConstructs.fwNC -join "-"
    NatRule1                                   = @{
        Name       = "RDPToJumpServer"
        Protocol   = "TCP"
        SourceAddr = $localMachinePublicIP
        DestPort   = "50000"
        TransAddr  = $hubResources.VMJMP.PrivateIP
        TransPort  = "3389"
    }
    NatRuleCollection                          = @{
        Name     = "NATforRDP"
        Priority = 1100
        Action   = "Allow"
    }
    NetworkRule1                               = @{
        Name       = "JumpAllowInternet"
        Protocol   = "TCP"
        SourceAddr = $hubJmpServerPrvIp
        DestAddr   = "*"
        DestPort   = @("80", "443")
    }
    NetworkRule2                               = @{
        Name       = "HubToSpoke"
        Protocol   = "Any"
        SourceAddr = $hubResources.Vnet.AddressSpace
        DestAddr   = $spokeResources.Vnet.AddressSpace
        DestPort   = "*"
    }
    NetworkRule3                               = @{
        Name       = "SpokeToHub"
        Protocol   = "Any"
        SourceAddr = $spokeResources.Vnet.AddressSpace
        DestAddr   = $hubResources.Vnet.AddressSpace
        DestPort   = "*"
    }
    NetworkRuleCollection1                     = @{
        Name     = "AllowInternet"
        Priority = 1200
        Action   = "Allow"
    }
    NetworkRuleCollection2                     = @{
        Name     = "AllowHubandSpoke"
        Priority = 1250
        Action   = "Allow"
    }
    ApplicationRule1                           = @{
        Name       = "AllowAzurePaaSServices"
        SourceAddr = @($hubResources.Vnet.AddressSpace, $spokeResources.Vnet.AddressSpace)
        fqdnTags   = @("MicrosoftActiveProtectionService", "WindowsDiagnostics", "WindowsUpdate", "AzureBackup")
    }
    ApplicationRule2                           = @{
        Name       = "AllowLogAnalytics"
        SourceAddr = @($hubResources.Vnet.AddressSpace, $spokeResources.Vnet.AddressSpace)
        Protocol   = "Https"
        Port       = 443
        TargetFqdn = @("*.ods.opsinsights.azure.com", "*.oms.opsinsights.azure.com", "*.blob.core.windows.net", "*.azure-automation.net")
    }
    ApplicationRuleCollection                  = @{
        Name       = "AllowAzurePaaS"
        Priority   = 1300
        RuleAction = "Allow"
    }
    #VirtualMachines
    #VirtualNetworkPeering

}

[hashtable]$spokeProperties = @{
    spokeNC            = 'APP'
    spokeStaPrefix     = 2
    #ResourceGroup
    resourceGroupName  = $selectedSpokeRegionCode, $spokeProperties.spokeNC, $globalProperties.resourceGroupSuffix -join "-"
    #StorageAccount
    storageAccountName = $hubProperties.hubStaPrefix, $namingConstructs.staNC, $uniqueGUIDIdentifier -join $null
    #RecoveryServicesVault
    #VirtualNetworkSubnets
    #VirtualNetwork
    #ADDSSubnetResources
    #AvailabilitySet
    #ADDSServer
    #ADDSSubnetNSG
    #AppSubnetResources
    #AvailabilitySet1
    #WebServers
    #AvailabilitySet2
    #DBServers
    #AvailabilitySet3
    #LinuxServer
    #AvailabilitySet4
    #DevServerPIP
    #DevServer
    #AppSubnetNSG
}

#endregion hashtables

