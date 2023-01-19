#region Strings

[string]$uniqueGUIDIdentifier = $(New-Guid).Guid.ToString().Split("-")[0]
[string]$localMachinePublicIP = Invoke-RestMethod http://ipinfo.io/json | Select-Object -ExpandProperty ip
[string]$lawMonitoringSolutions = @("Updates","ChangeTracking","Security","ServiceMap","AzureActivity","VMInsights","AzureAutomation","NetworkMonitoring")
[string[]]$requiredModules = @("Az", "Az.MonitoringSolutions", "AzureAutomation", "xActiveDirectory", "xComputerManagement", "xStorage", "xNetworking", "xSmbShare")
[string[]]$runbookModules = @("Az.Accounts", "Az.Resources", "Az.Compute", "Az.Automation", "Az.Network")


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
    vmImage                              = $(Get-AzVMImage -Location $selectedHubRegionCode -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2022-datacenter-azure-edition-smalldisk" -Version "$selectedVersion")
}

[hashtable]$hubProperties = @{
    hubNC                       = 'INF'
    hubStaPrefix                = 1
    #ResourceGroup
    resourceGroupName           = $selectedHubRegionCode, $hubProperties.hubNC, "NP", $namingConstructs.rgNC -join "-"
    #StorageAccount
    storageAccountName          = $hubProperties.hubStaPrefix, $namingConstructs.staNC, $uniqueGUIDIdentifier -join $null
    storageAccountContainerName = 'stageartifacts'
    #AutomationAccount
    aaName                      = $selectedHubRegionCode, $namingConstructs.aaaNC, "NP", $uniqueGUIDIdentifier, $namingConstructs.aaaNC -join "-"
    aaPlan                      = "Basic"
    aaAssignSystemIdentity      = $true # For reference only
    aaStartSchedule             = @{
        Description  = "Start 0800 Weekdays LOCAL"
        Name         = "Start 0800 Weekdays LOCAL"
        StartTime    = [datetime]::utcnow.AddDays(1).ToString("yyyy-MM-ddT08:00:00")
        ExpiryTime   = "9999-12-31T00:00:00-00:00"
        WeekInterval = 1
        DaysOfWeek   = "Monday,Tuesday,Wednesday,Thursday,Friday"
        Timezone     = "UTC"
    }
    aaStopSchedule              = @{
        Description  = "Stop 1800 Weekdays LOCAL"
        Name         = "Stop 1800 Weekdays LOCAL"
        StartTime    = [datetime]::utcnow.AddDays(1).ToString("yyyy-MM-ddT18:00:00")
        ExpiryTime   = "9999-12-31T00:00:00-00:00"
        WeekInterval = 1
        DaysOfWeek   = "Monday,Tuesday,Wednesday,Thursday,Friday"
        Timezone     = "UTC"
    }
    aaStartRunbook              = @{
        Name         = "Start-VMs"
        Description  = "Starts all VMs in the resource group"
        Path         = "$PSScriptRoot\Runbooks\Start-VMs.ps1"
        LogVerbose   = $true
        ScheduleName = $hubProperties.aaStartSchedule.Name
    }
    aaStopRunbook               = @{
        Name         = "Stop-VMs"
        Description  = "Stops all VMs in the resource group"
        Path         = "$PSScriptRoot\Runbooks\Stop-VMs.ps1"
        LogVerbose   = $true
        ScheduleName = $hubProperties.aaStopSchedule.Name
    }
    #LogAnalyticsWorkspace
    lawName                     = $selectedHubRegionCode, $hubResources.hubNC, "NP", $uniqueGUIDIdentifier, $namingConstructs.alaNC -join "-"
    lawSku                      = "PerGB2018"
    lawRetentionInDays          = 30
    #VirtualNetworkSubnets
    #JumpSubnetResources
    SubnetNameJMP               = $selectedHubRegionCode, $hubResources.hubNC, "NP", $namingConstructs.subnetNC -join "-"
    SubnetAddressPrefixJMP      = "10.10.1.0/24"
    NSGNameJMP                  = $selectedHubRegionCode, $hubResources.hubNC, "NP", $namingConstructs.nsgNC -join "-"
    NSGRulesJMP                 = @{
        name                     = AllowRdpInbound
        access                   = Allow
        description              = "Allow inbound RDP from internet"
        destinationAddressPrefix = VirtualNetwork
        destinationPortRange     = 3389
        direction                = Inbound
        priority                 = 100
        protocol                 = Tcp
        sourceAddressPrefix      = *
        sourcePortRange          = *
    }
    #AFWSubnetResources
    SubnetNameAFW               = "AzureFirewallSubnet"
    SubnetAddressPrefixAFW      = "10.10.0.0/24"
    #JumpServerPIP
    PIPJumpServer               = @{
        name                 = $selectedHubRegionCode, $hubResources.hubNC, $namingConstructs.pipNC -join "-"
        allocationMethod     = "Dynamic"
        sku                  = "Standard"
        tier                 = "Regional"
        idleTimeoutInMinutes = 4
    }
    PubIPNameJMP                = $selectedHubRegionCode, $hubResources.hubNC, $namingConstructs.pipNC -join "-"
    PubIPAllocationMethod       = "Dynamic"
    PubIPSku                    = "Standard"
    PubIPTier                   = "Regional"
    PubIPIdleTimeoutInMinutes   = 4
    #JumpServer
    JMPVMName                   = $selectedHubRegionCode, $hubResources.hubNC, "NP-JMP-01" -join "-"
    JMPNicName                  = $selectedHubRegionCode, $hubResources.hubNC, "NP-JMP-NIC-01" -join "-"
    JMPOSDiskName               = $selectedHubRegionCode, $hubResources.hubNC, "NP-JMP-OSDisk-01" -join "-"
    JMPOSDiskCreateOption       = "FromImage"
    JMPDataDiskName             = $selectedHubRegionCode, $hubResources.hubNC, "NP-JMP-DataDisk-01" -join "-"
    JMPDataDiskCreateOption     = "Empty"
    JMPOSDiskSizeGB             = 32
    JMPDataDiskSizeGB           = 32
    JMPPrivateIPAddress         = "10.10.1.4"
    #VirtualNetwork
    VNetName                    = $selectedHubRegionCode, $hubResources.hubNC, "NP", $namingConstructs.vnetNC -join "-"
    VNetAddressPrefix           = "10.10.0.0/22"
    #AzureFirewall
    FWName                      = $selectedHubRegionCode, $hubResources.hubNC, "NP", $namingConstructs.fwNC -join "-"
    FWSku                       = "AZFW_Hub"
    FWSkuTier                   = "Standard"
    FWVHub                      = $null
    FWThreatIntelMode           = "Deny"
    NatRule1                    = @{
        Name              = "RDPToJumpServer"
        SourceAddress     = $localMachinePublicIP
        TranslatedAddress = $hubResources.VMJMP.PrivateIP
        TranslatedPort    = "3389"
        DestinationPort   = "50000"
        Protocol          = "TCP"
    }
    NatRuleCollection           = @{
        Name       = "NATforRDP"
        Priority   = 1100
        ActionType = "Allow"
    }
    NetworkRule1                = @{
        Name               = "JumpAllowInternet"
        Protocol           = "TCP"
        SourceAddress      = $hubJmpServerPrvIp
        DestinationAddress = "*"
        DestinationPort    = @("80", "443")
    }
    NetworkRule2                = @{
        Name               = "HubToSpoke"
        Protocol           = "Any"
        SourceAddress      = $hubResources.Vnet.AddressSpace
        DestinationAddress = $spokeResources.Vnet.AddressSpace
        DestinationPort    = "*"
    }
    NetworkRule3                = @{
        Name               = "SpokeToHub"
        Protocol           = "Any"
        SourceAddress      = $spokeResources.Vnet.AddressSpace
        DestinationAddress = $hubResources.Vnet.AddressSpace
        DestinationPort    = "*"
    }
    NetworkRuleCollection1      = @{
        Name       = "AllowInternet"
        Priority   = 1200
        ActionType = "Allow"
    }
    NetworkRuleCollection2      = @{
        Name       = "AllowHubandSpoke"
        Priority   = 1250
        ActionType = "Allow"
    }
    ApplicationRule1            = @{
        Name          = "AllowAzurePaaSServices"
        SourceAddress = @($hubResources.Vnet.AddressSpace, $spokeResources.Vnet.AddressSpace)
        FQDNTag       = @("MicrosoftActiveProtectionService", "WindowsDiagnostics", "WindowsUpdate", "AzureBackup")
    }
    ApplicationRule2            = @{
        Name          = "AllowLogAnalytics"
        SourceAddress = @($hubResources.Vnet.AddressSpace, $spokeResources.Vnet.AddressSpace)
        Protocol      = "Https"
        Port          = 443
        TargetFqdn    = @("*.ods.opsinsights.azure.com", "*.oms.opsinsights.azure.com", "*.blob.core.windows.net", "*.azure-automation.net")
    }
    ApplicationRuleCollection   = @{
        Name       = "AllowAzurePaaS"
        Priority   = 1300
        ActionType = "Allow"
    }
    #VirtualMachines
    #VirtualNetworkPeering

}

[hashtable]$spokeProperties = @{
    spokeNC                = "APP"
    spokeLNXNC             = "POC"
    spokeStaPrefix         = 2
    #ResourceGroup
    resourceGroupName      = $selectedSpokeRegionCode, $spokeProperties.spokeNC, "NP", $namingConstructs.rgNC -join "-"
    #StorageAccount
    storageAccountName     = $spokeProperties.spokeStaPrefix, $namingConstructs.staNC, $uniqueGUIDIdentifier -join $null
    #RecoveryServicesVault
    rsvName                = "rsv", $uniqueGUIDIdentifier -join $null
    #NetworkSecurityGroups
    #ADDSSubnetNSG
    nsgNameADC             = $selectedSpokeRegionCode, "ADC", "NP", $namingConstructs.nsgNC -join "-"
    #AppSubnetNSG
    nsgNameSRV             = $selectedSpokeRegionCode, "SRV", "NP", $namingConstructs.nsgNC -join "-"
    #VirtualNetworkSubnets
    SubnetNameADC          = $selectedSpokeRegionCode, "ADC-NP-SUB-01"
    SubnetAddressPrefixADC = "10.20.10.0/28"
    SubnetNameSRV          = $selectedSpokeRegionCode, "SRV-NP-SUB-01"
    SubnetAddressPrefixSRV = "10.20.10.16/28"
    #VirtualNetwork
    VnetName               = $selectedSpokeRegionCode, $spokeProperties.spokeNC, "NP", $namingConstructs.vnetNC -join "-"
    VnetAddressPrefix      = "10.20.10.0/26"
    #UserDefinedRoutes
    UserDefinedRoutes      = @{
        tableName       = $selectedSpokeRegionCode + "-APP-NP-UDR-01"
        zeroRoute       = "ZeroTraffic"
        zeroAddrPrefix  = "0.0.0.0/0"
        zeroNextHopType = $hubRouteNextHopType
        zeroNextHopAddr = $hubFwPrvIp
        hubRoute        = "RouteToHub"
        hubAddrPrefix   = "10.10.0.0/22"
        hubNextHopType  = $hubRouteNextHopType
        hubNextHopAddr  = $hubFwPrvIp
    }
    #AppServersAndAvailabilitySets
    #AvailabilitySetADC
    AVSetNameADC           = $selectedSpokeRegionCode, "ADC", "NP", $namingConstructs.avsetNC -join "-"
    #ADDSServer
    vmNameADC              = $selectedSpokeRegionCode, $spokeProperties.spokeNC, "NPADC01" -join $null
    #AppSubnetResources
    #AvailabilitySet1
    AVSetNameWES           = $selectedSpokeRegionCode, "WES", "NP", $namingConstructs.avsetNC -join "-"
    #WebServers
    vmNameWeb1             = $selectedSpokeRegionCode, $spokeProperties.spokeNC, "NPWES01" -join $null
    vmNameWeb2             = $selectedSpokeRegionCode, $spokeProperties.spokeNC, "NPWES02" -join $null
    #AvailabilitySet2
    AVSetNameSQL           = $selectedSpokeRegionCode, "SQL", "NP", $namingConstructs.avsetNC -join "-"
    #DBServers
    vmNameSQL1             = $selectedSpokeRegionCode, $spokeProperties.spokeNC, "NPSQL01" -join $null
    vmNameSQL2             = $selectedSpokeRegionCode, $spokeProperties.spokeNC, "NPSQL02" -join $null
    #AvailabilitySet3
    AVSetNameLNX           = $selectedSpokeRegionCode, "LNX", "NP", $namingConstructs.avsetNC -join "-"
    #LinuxServer
    vmNameLinux1           = $selectedSpokeRegionCode, $spokeProperties.spokeLNXNC, "NPLNX01" -join $null
    #AvailabilitySet4
    AVSetNameDEV           = $selectedSpokeRegionCode, "DEV", "NP", $namingConstructs.avsetNC -join "-"
    #DevServerPIP
    pipNameDev1            = $selectedSpokeRegionCode, $spokeProperties.spokeNC, "NPDEV01-PIP" -join $null
    #DevServer
    vmNameDev1             = $selectedSpokeRegionCode, $spokeProperties.spokeNC, "NPDEV01" -join $null
    
}

#endregion hashtables