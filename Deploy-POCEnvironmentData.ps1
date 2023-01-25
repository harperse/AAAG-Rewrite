#region Strings

[string]$global:uniqueGUIDIdentifier = $(New-Guid).Guid.ToString().Split("-")[0]
[string]$global:localMachinePublicIP = Invoke-RestMethod http://ipinfo.io/json | Select-Object -ExpandProperty ip
[string]$global:lawMonitoringSolutions = @("Updates", "ChangeTracking", "Security", "ServiceMap", "AzureActivity", "VMInsights", "AzureAutomation", "NetworkMonitoring")
[string[]]$global:requiredDSCResources = @("xActiveDirectory", "xComputerManagement", "xStorage", "xNetworking", "xSmbShare", "PSDesiredStateConfiguration")  

if ($AzureEnvironment -eq "AzureCloud") {
    [string]$storageDnsSuffix = ".blob.core.windows.net"
    [string]$dnsNameLabelSuffix = ".cloudapp.azure.com"
} # end if ($AzureEnvironment -eq "AzureCloud")
else {
    [string]$storageDnsSuffix = ".blob.core.usgovcloudapi.net"
    [string]$dnsNameLabelSuffix = ".cloudapp.usgovcloudapi.net"
} # end else
#endregion Strings

#region hashtables

[hashtable]$global:runbookModules = @{
    "Az.Accounts"   = $(Get-Module -Name Az.Accounts).Version.ToString()
    "Az.Resources"  = $(Get-Module -Name Az.Resources).Version.ToString()
    "Az.Compute"    = $(Get-Module -Name Az.Compute).Version.ToString()
    "Az.Automation" = $(Get-Module -Name Az.Automation).Version.ToString()
    "Az.Network"    = $(Get-Module -Name Az.Network).Version.ToString()
}

[hashtable]$global:alaToaaaMap = @{
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
} # end alaToaaaMap

[hashtable]$global:namingConstructs = @{
    staNC    = 'sta'
    rgNC     = 'RGP-01'
    vNetNC   = 'VNT-01'
    rsvNC    = 'RSV-01'
    alaNC    = 'ALA-01'
    aaaNC    = 'AAA-01'
    afwNC    = 'AFW-01'
    avsetNC  = 'AVS-01'
    subnetNC = 'SUB-01'
    nsgNC    = 'NSG-01'
    pipNC    = 'PIP-01'
    udrNC    = 'UDR-01'
    fwNC     = 'AFW-01'
} # end namingConstructs

[hashtable]$global:globalProperties = @{
    globalTags                  = @{ "Creator" = "Microsoft Governance POC Script" }
    storageAccountProperties    = @{
        Kind                            = "StorageV2"
        SkuName                         = "Standard_LRS"
        AccessTier                      = "Hot"
        EnableHttpsTrafficOnly          = $true
        AllowBlobPublicAccess           = $true
        AllowSharedKeyAccess            = $true
        AllowCrossTenantReplication     = $true
        MinimumTlsVersion               = "TLS1_2"
        NetworkRuleSet                  = @{"Bypass" = "AzureServices"; "DefaultAction" = "Allow" }
        RequireInfrastructureEncryption = $true
    } # end storageAccountProperties
    storageAccountContainerName = 'stageartifacts'
    vmSize                      = 'Standard_D2_v3'
    vmImageJMP                  = $(Get-AzVMImage -Location $azSpokeLocation -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2022-datacenter-azure-edition-smalldisk" -Version "$selectedVersion")
    vmImage                     = "Win2019Datacenter"
    hubNC                       = 'INF'
    hubStaPrefix                = 1
    spokeNC                     = "APP"
    spokeLNXNC                  = "POC"
    spokeStaPrefix              = 2
} # end globalProperties

[hashtable]$global:hubProperties = @{
    #ResourceNames
    resourceGroupName         = $selectedHubRegionCode, $globalProperties.hubNC, "NP", $namingConstructs.rgNC -join "-"
    storageAccountName        = $globalProperties.hubStaPrefix, $namingConstructs.staNC, $uniqueGUIDIdentifier -join $null
    aaName                    = $selectedHubRegionCode, $globalProperties.hubNC, "NP", $uniqueGUIDIdentifier, $namingConstructs.aaaNC -join "-"
    lawName                   = $selectedHubRegionCode, $globalProperties.hubNC, "NP", $uniqueGUIDIdentifier, $namingConstructs.alaNC -join "-"
    NICIPConfigNameJMP1       = $selectedHubRegionCode, $globalProperties.hubNC, "NP", $namingConstructs.subnetNC, "config1" -join "-"
    NICIPConfigNameJMP2       = $selectedHubRegionCode, $globalProperties.hubNC, "NP", $namingConstructs.subnetNC, "config2" -join "-"
    SubnetNameJMP             = $selectedHubRegionCode, $globalProperties.hubNC, "NP", $namingConstructs.subnetNC -join "-"
    NSGNameJMP                = $selectedHubRegionCode, $globalProperties.hubNC, "NP", $namingConstructs.nsgNC -join "-"
    #PubIPNameJMP              = $selectedHubRegionCode, $globalProperties.hubNC, "NP", $namingConstructs.pipNC -join "-"
    JMPVMName                 = $selectedHubRegionCode, $globalProperties.hubNC, "NP-JMP-01" -join "-"
    JMPNicName                = $selectedHubRegionCode, $globalProperties.hubNC, "NP-JMP-NIC-01" -join "-"
    JMPOSDiskName             = $selectedHubRegionCode, $globalProperties.hubNC, "NP-JMP-OSDisk-01" -join "-"
    JMPDataDiskName           = $selectedHubRegionCode, $globalProperties.hubNC, "NP-JMP-DataDisk-01" -join "-"
    SubnetNameAFW             = "AzureFirewallSubnet"
    VNetName                  = $selectedHubRegionCode, $globalProperties.hubNC, "NP", $namingConstructs.vnetNC -join "-"
    FWName                    = $selectedHubRegionCode, $globalProperties.hubNC, "NP", $namingConstructs.fwNC -join "-"
    #AutomationAccount
    aaPlan                    = "Basic"
    aaAssignSystemIdentity    = $true # For reference only
    aaStartSchedule           = @{
        Description  = "Start 0800 Weekdays LOCAL"
        Name         = "Start 0800 Weekdays LOCAL"
        StartTime    = [datetime]::utcnow.AddDays(1).ToString("yyyy-MM-ddT08:00:00")
        ExpiryTime   = "9999-12-31T00:00:00-00:00"
        WeekInterval = 1
        DaysOfWeek   = @([System.DayOfWeek]::Monday, [System.DayOfWeek]::Tuesday, [System.DayOfWeek]::Wednesday, [System.DayOfWeek]::Thursday, [System.DayOfWeek]::Friday)
        Timezone     = "UTC"
    }
    aaStartImportRunbook      = @{
        Name        = "Start-VMs"
        Description = "Starts all VMs in the resource group"
        Path        = "$PSScriptRoot\Runbooks\Manage-CostForPoCVirtualMachinesStart.ps1"
        LogVerbose  = $true
        Published   = $true
        Type        = "PowerShell"
    }
    aaStartRegisterRunbook    = @{
        RunbookName  = "Start-VMs"
        ScheduleName = $hubProperties.aaStartSchedule.Name
        Parameters   = @{
            "operation" = "start"
            "env"       = $AzureEnvironment
        }
    }
    aaStopSchedule            = @{
        Description  = "Stop 1800 Weekdays LOCAL"
        Name         = "Stop 1800 Weekdays LOCAL"
        StartTime    = [datetime]::utcnow.AddDays(1).ToString("yyyy-MM-ddT18:00:00")
        ExpiryTime   = "9999-12-31T00:00:00-00:00"
        WeekInterval = 1
        DaysOfWeek   = @([System.DayOfWeek]::Monday, [System.DayOfWeek]::Tuesday, [System.DayOfWeek]::Wednesday, [System.DayOfWeek]::Thursday, [System.DayOfWeek]::Friday)
        Timezone     = "UTC"
    }
    aaStopImportRunbook       = @{
        Name        = "Stop-VMs"
        Description = "Stops all VMs in the resource group"
        Path        = "$PSScriptRoot\Runbooks\Manage-CostForPoCVirtualMachinesStop.ps1"
        LogVerbose  = $true
        Published   = $true
        Type        = "PowerShell"
    }
    aaStopRegisterRunbook     = @{
        RunbookName  = "Stop-VMs"
        ScheduleName = $hubProperties.aaStopSchedule.Name
        Parameters   = @{
            "operation" = "stop"
            "env"       = $AzureEnvironment
        }
    }
    #LogAnalyticsWorkspace
    lawSku                    = "PerGB2018"
    lawRetentionInDays        = 30
    #VirtualNetworkSubnets
    #JumpSubnetResources
    SubnetAddressPrefixJMP    = "10.10.1.0/24"
    NSGRulesJMP               = @{
        name                     = "AllowRdpInbound"
        access                   = "Allow"
        description              = "Allow inbound RDP from internet"
        destinationAddressPrefix = "VirtualNetwork"
        destinationPortRange     = 3389
        direction                = "Inbound"
        priority                 = 100
        protocol                 = "Tcp"
        sourceAddressPrefix      = "*"
        sourcePortRange          = "*"
    }
    #AFWSubnetResources
    SubnetAddressPrefixAFW    = "10.10.0.0/24"
    #JumpServerPIP
    PIPJumpServer             = @{
        name                 = $selectedHubRegionCode, $globalProperties.hubNC, "NP", $namingConstructs.pipNC -join "-"
        allocationMethod     = "Static"
        sku                  = "Standard"
        tier                 = "Regional"
        idleTimeoutInMinutes = 4
    }
    PubIPAllocationMethod     = "Dynamic"
    PubIPSku                  = "Standard"
    PubIPTier                 = "Regional"
    PubIPIdleTimeoutInMinutes = 4
    #JumpServer
    JMPOSDiskCreateOption     = "FromImage"
    JMPDataDiskCreateOption   = "Empty"
    JMPOSDiskSizeGB           = 32
    JMPDataDiskSizeGB         = 32
    JMPPrivateIPAddress       = "10.10.1.4"
    #VirtualNetwork
    VNetAddressPrefix         = "10.10.0.0/22"
    #AzureFirewall
    FWSku                     = "AZFW_Hub"
    FWSkuTier                 = "Standard"
    FWVHub                    = $null
    FWThreatIntelMode         = "Deny"
    NatRule1                  = @{
        Name              = "RDPToJumpServer"
        SourceAddress     = $localMachinePublicIP
        TranslatedAddress = $hubResources.VMJMP.PrivateIP
        TranslatedPort    = "3389"
        DestinationPort   = "50000"
        Protocol          = "TCP"
    }
    NatRuleCollection         = @{
        Name       = "NATforRDP"
        Priority   = 1100
        ActionType = "Allow"
    }
    NetworkRule1              = @{
        Name               = "JumpAllowInternet"
        Protocol           = "TCP"
        SourceAddress      = $hubJmpServerPrvIp
        DestinationAddress = "*"
        DestinationPort    = @("80", "443")
    }
    NetworkRule2              = @{
        Name               = "HubToSpoke"
        Protocol           = "Any"
        SourceAddress      = $hubResources.Vnet.AddressSpace
        DestinationAddress = $spokeResources.Vnet.AddressSpace
        DestinationPort    = "*"
    }
    NetworkRule3              = @{
        Name               = "SpokeToHub"
        Protocol           = "Any"
        SourceAddress      = $spokeResources.Vnet.AddressSpace
        DestinationAddress = $hubResources.Vnet.AddressSpace
        DestinationPort    = "*"
    }
    NetworkRuleCollection1    = @{
        Name       = "AllowInternet"
        Priority   = 1200
        ActionType = "Allow"
    }
    NetworkRuleCollection2    = @{
        Name       = "AllowHubandSpoke"
        Priority   = 1250
        ActionType = "Allow"
    }
    ApplicationRule1          = @{
        Name          = "AllowAzurePaaSServices"
        SourceAddress = @($hubResources.Vnet.AddressSpace, $spokeResources.Vnet.AddressSpace)
        FQDNTag       = @("MicrosoftActiveProtectionService", "WindowsDiagnostics", "WindowsUpdate", "AzureBackup")
    }
    ApplicationRule2          = @{
        Name          = "AllowLogAnalytics"
        SourceAddress = @($hubResources.Vnet.AddressSpace, $spokeResources.Vnet.AddressSpace)
        Protocol      = "Https"
        Port          = 443
        TargetFqdn    = @("*.ods.opsinsights.azure.com", "*.oms.opsinsights.azure.com", "*.blob.core.windows.net", "*.azure-automation.net")
    }
    ApplicationRuleCollection = @{
        Name       = "AllowAzurePaaS"
        Priority   = 1300
        ActionType = "Allow"
    }
    #VirtualMachines
    #VirtualNetworkPeering

} # end hubProperties

[hashtable]$global:spokeProperties = @{
    #ResourceNames
    resourceGroupName      = $selectedSpokeRegionCode, $globalProperties.spokeNC, "NP", $namingConstructs.rgNC -join "-"
    storageAccountName     = $globalProperties.spokeStaPrefix, $namingConstructs.staNC, $uniqueGUIDIdentifier -join $null
    rsvName                = "rsv", $uniqueGUIDIdentifier -join $null
    nsgNameADC             = $selectedSpokeRegionCode, "ADC", "NP", $namingConstructs.nsgNC -join "-"
    nsgNameSRV             = $selectedSpokeRegionCode, "SRV", "NP", $namingConstructs.nsgNC -join "-"
    SubnetNameADC          = $selectedSpokeRegionCode, "ADC-NP-SUB-01" -join "-"
    SubnetNameSRV          = $selectedSpokeRegionCode, "SRV-NP-SUB-01" -join "-"
    VnetName               = $selectedSpokeRegionCode, $globalProperties.spokeNC, "NP", $namingConstructs.vnetNC -join "-"
    AVSetNameADC           = $selectedSpokeRegionCode, "ADC", "NP", $namingConstructs.avsetNC -join "-"
    AVSetNameWES           = $selectedSpokeRegionCode, "WES", "NP", $namingConstructs.avsetNC -join "-"
    AVSetNameSQL           = $selectedSpokeRegionCode, "SQL", "NP", $namingConstructs.avsetNC -join "-"
    AVSetNameLNX           = $selectedSpokeRegionCode, "LNX", "NP", $namingConstructs.avsetNC -join "-"
    AVSetNameDEV           = $selectedSpokeRegionCode, "DEV", "NP", $namingConstructs.avsetNC -join "-"
    vmNameADC              = $selectedSpokeRegionCode, $globalProperties.spokeNC, "NPADC01" -join $null
    vmNameWeb1             = $selectedSpokeRegionCode, $globalProperties.spokeNC, "NPWES01" -join $null
    vmNameWeb2             = $selectedSpokeRegionCode, $globalProperties.spokeNC, "NPWES02" -join $null
    vmNameSQL1             = $selectedSpokeRegionCode, $globalProperties.spokeNC, "NPSQL01" -join $null
    vmNameSQL2             = $selectedSpokeRegionCode, $globalProperties.spokeNC, "NPSQL02" -join $null
    vmNameLNX              = $selectedSpokeRegionCode, $globalProperties.spokeLNXNC, "NPLNX01" -join $null
    vmNameDev              = $selectedSpokeRegionCode, $globalProperties.spokeNC, "NPDEV01" -join $null
    pipNameDev             = $selectedSpokeRegionCode, $globalProperties.spokeNC, "NPDEV01-PIP" -join $null
    #StorageAccount
    blobEnableChangeFeed   = $false
    #VirtualNetworkSubnets
    SubnetAddressPrefixADC = "10.20.10.0/28"
    SubnetAddressPrefixSRV = "10.20.10.16/28"
    #VirtualNetwork
    VnetAddressPrefix      = "10.20.10.0/26"
    #UserDefinedRoutes
    UserDefinedRoutes      = @{
        tableName       = $selectedSpokeRegionCode, "APP-NP-UDR-01" -join "-"
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
    
    #ADDSServer
    
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
    
    
} # end spokeProperties

#endregion hashtables