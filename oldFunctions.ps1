#region Functions

function Select-AzSubscriptionFromList {
    Write-Output "Listing all subscriptions"
    $allSubscriptions = (Get-AzSubscription).Name | Sort-Object
    Write-Output $allSubscriptions
    Do {
        [string] $selectedSubscription = Read-Host "Please type or copy/paste the name of the subscription here"
    }
    Until ($selectedSubscription -in $allSubscriptions)
    return $selectedSubscription
} #COMPLETE

function New-AzStorageAccountHubAndSpoke {

    if ($DeploymentOption -ne "DeployAppOnly") {
        #Create hub storage account
        Write-Output "Creating hub storage account"
        $hubStorageAccountProperties = @{
            ResourceGroupName  = $hubObjectDefinitions.resourceGroup.Name
            Name               = $("staHubDeploy", $StartTimeStamp.Split("_")[0] -join "-")
            TemplateFile       = ".\nested\00.00.01.createHubStorageAccount.json"
            TemplateParameters = @{
                staHubName = $hubResources.storAcctPrefix, $storageAccountPrefix, $uniqueGUIDIdentifier -join $null 
            }
            Mode               = Incremental
            Verbose            = $true
            ErrorAction        = SilentlyContinue
        }
        New-AzResourceGroupDeployment @hubStorageAccountProperties
    }

    #Create spoke storage account
    Write-Output 'Creating spoke storage account'
    $spokeStorageAccountProperties = @{
        ResourceGroupName  = $spokeObjectDefinitions.resourceGroup.Name
        Name               = $("staDeploy", $StartTimeStamp.Split("_")[0] -join "-")
        TemplateFile       = ".\nested\00.00.00.createStorageAccount.json"
        TemplateParameters = @{
            staHubName           = $hubResources.storAcctPrefix, $storageAccountPrefix, $uniqueGUIDIdentifier -join $null 
            storageContainerName = $storageContainerName
        }
        Mode               = Incremental
        Verbose            = $true
        ErrorAction        = SilentlyContinue
    }
    New-AzResourceGroupDeployment @spokeStorageAccountProperties
    
}

function New-AzPOCResourceGroupDeployment {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][ValidateSet("Hub", "Spoke", "AppOnly")][string]$HubOrSpoke
    )

    switch ($HubOrSpoke) {
        "Hub" {
            $resourceGroupName = $selectedHubRegionCode, $hubResources.hubNC, "NP", $namingConstructs.rgNC, "01" -join "-"
            New-AzResourceGroup -Name $resourceGroupName -Location $selectedHubRegionCode -Verbose
            $global:hubObjectDefinitions.Add("resourceGroup", $(Get-AzResourceGroup -Name $resourceGroupName -Location $selectedHubRegionCode))
            New-AzStorageAccountHubAndSpoke -HubOrSpoke Hub
        }
        "Spoke" {
            $resourceGroupName = $selectedSpokeRegionCode, $hubResources.spkNC, "NP", $namingConstructs.rgNC, "01" -join "-"
            New-AzResourceGroup -Name $resourceGroupName -Location $selectedSpokeRegionCode -Verbose
            $global:spokeObjectDefinitions.Add("resourceGroup", $(Get-AzResourceGroup -Name $resourceGroupName -Location $selectedSpokeRegionCode))
            New-AzStorageAccountHubAndSpoke -HubOrSpoke Spoke
        }
    }
}

function New-AzVirtualNetworkHubAndSpoke {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][ValidateSet("Hub", "Spoke", "AppOnly")][string]$HubOrSpoke
    )

    switch ($HubOrSpoke) {
        "Hub" {
            New-AzVirtualNetworkSubnetConfig -Name $hubProperties.SubnetNameJMP -AddressPrefix $hubProperties.SubnetAddressPrefixJMP
            New-AzVirtualNetworkSubnetConfig -Name $hubProperties.SubnetNameAFW -AddressPrefix $hubProperties.SubnetAddressPrefixAFW
        }
        "Spoke" {

        }
    }
}


#endregion Functions