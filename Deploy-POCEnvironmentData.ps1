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
    rgNC     = 'RGP'
    staNC    = 'sta'
    vNetNC   = 'VNT'
    rsvNC    = 'RSV'
    alaNC    = 'ALA'
    aaaNC    = 'AAA'
    afwNC    = 'AFW'
    subnetNC = 'SUB'
    nsgNC    = 'NSG'
    pipNC    = 'PIP'
    udrNC    = 'UDR'
}

[hashtable]$globalProperties = @{
    resourceGroupSuffix = "NP-RGP-01"
    tagKey              = "Creator"
    tagValue            = "Microsoft Governance POC Script"
    storageAccountKind  = "StorageV2"
    storageAccountSkuName = "Standard_LRS"
    storageAccountAccessTier = "Hot"
    storageAccountEnableHttpsTrafficOnly = $true

    vmAdminUserName = 'adm.infra.user'
    vmSize = 'Standard_D1_v2'
}

[hashtable]$hubProperties = @{
    hubNC              = 'INF'
    hubStaPrefix       = 1
    #ResourceGroup
    resourceGroupName  = $selectedHubRegionCode, $hubProperties.hubNC, $globalProperties.resourceGroupSuffix -join "-"
    #StorageAccount
    storageAccountName = $hubProperties.hubStaPrefix, $namingConstructs.staNC, $uniqueGUIDIdentifier -join $null
    storageAccountContainerName = 'stageartifacts'
    #AutomationAccount
    automationAccountName = $selectedHubRegionCode, $namingConstructs.aaaNC, "NP", $uniqueGUIDIdentifier, "AAA-01" -join "-"
    automationAccountPlan = "Basic"
    automationAccountAssignSystemIdentity = $true # For reference only
    automationAccountScheduleDescriptionStart = "Start 0800 Weekdays LOCAL"
    automationAccountScheduleNameStart = "Start 0800 Weekdays LOCAL"
    automationAccountScheduleStartTimeStart = [datetime]::now.AddDays(1).ToString("yyyy-MM-ddT08:00:00")
    automationAccountScheduleExpiryTimeStart = "9999-12-31T00:00:00-00:00"
    automationAccountScheduleIntervalStart = $null
    automationAccountScheduleFrequencyStart = $null
    automationAccountScheduleTimezoneStart = $null
    automationAccountScheduleDescriptionStop = "Stop 1800 Weekdays LOCAL" 
    automationAccountScheduleNameStop = "Stop 1800 Weekdays LOCAL"
    automationAccountScheduleStartTimeStop = [datetime]::now.AddDays(1).ToString("yyyy-MM-ddT18:00:00")
    automationAccountScheduleExpiryTimeStop = "9999-12-31T00:00:00-00:00"
    automationAccountScheduleIntervalStop = $null
    automationAccountScheduleFrequencyStop = $null
    automationAccountScheduleTimezoneStop = $null
    #LogAnalyticsWorkspace
    logAnalyticsWorkspaceName = $selectedHubRegionCode, $namingConstructs.alaNC, "NP", $uniqueGUIDIdentifier, "ALA-01" -join "-"
    logAnalyticsWorkspaceSku = "PerGB2018"
    logAnalyticsWorkspaceRetentionInDays = 30
    #VirtualNetworkSubnets
    #JumpSubnetResources
    SubnetNameJMP = $selectedHubRegionCode, $hubResources.hubNC, $namingConstructs.subnetNC, "JMP-01" -join "-"
    SubnetAddressPrefixJMP = "10.10.1.0/24"
    NSGNameJMP = $selectedHubRegionCode, $hubResources.hubNC, "NP", $namingConstructs.nsgNC, "01" -join "-"
    NSGRulesJMP = @{}
    #AFWSubnetResources
    SubnetNameAFW = "AzureFirewallSubnet"
    SubnetAddressPrefixAFW = "10.10.0.0/24"
    #JumpServerPIP
    PIPNameJMP = $selectedHubRegionCode, $hubResources.hubNC, $namingConstructs.pipNC, "JMP-01" -join "-"
    PubIPAllocationMethod = "Dynamic"
    PubIPIdleTimeoutInMinutes = 4
    #JumpServer
    VMNameJMP = $selectedHubRegionCode, $hubResources.hubNC, "NP-JMP-01" -join "-"
    #VirtualNetwork
    #AzureFirewall
    #VirtualMachines
    #VirtualNetworkPeering

}

[hashtable]$spokeProperties = @{
    spokeNC            = 'APP'
    spokeStaPrefix     = 2
    #ResourceGroup
    resourceGroupName  = $selectedSpokeRegionCode, $spokeProperties.spokeNC, $globalProperties.resourceGroupSuffix  -join "-"
    #StorageAccount
    storageAccountName = $hubProperties.hubStaPrefix, $namingConstructs.staNC, $uniqueGUIDIdentifier  -join $null
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

