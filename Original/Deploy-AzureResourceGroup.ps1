﻿#requires -version 5.1
#requires -RunAsAdministrator
#requires -Module Az

# For IPAddress class
Using Namespace System.Net
# For Azure AD service principals marshal clas
Using Namespace System.Runtime.InteropServices
# For the PSStorageAccount Class: https://docs.microsoft.com/en-us/dotnet/api/microsoft.azure.commands.management.storage.models.psstorageaccount?view=azurerm-ps
Using Namespace Microsoft.Azure.Commands.Management.Storage.Models
Using Namespace Microsoft.Azure.Commands.Network.Models

<#
.SYNOPSIS
Creates a PoC infrastructure to practice Azure administration, governance, automation, DSC, PowerShell and PowerShell core topics.

.DESCRIPTION
This script will create a PoC infrastructure to practice Azure administration, governance, automation, DSC, PowerShell and PowerShell core topics.

PRE-REQUISITES:

1. If you already have the Az modules installed, you may still encounter the following error:
    The script 'Deploy-AzureResourceGroup.ps1' cannot be run because the following modules that are specified by the "#requires" statements of the script are missing: Az.
    At line:0 char:0
To resolve, please run the following command to import the Az modules into your current session.
Import-Module -Name Az -Verbose

2. Before executing this script, ensure that you change the directory to the directory where the script is located. For example, if the script is in: c:\poc-package-#.#.#\Deploy-AzureResourceGroup.ps1 
(where #.#.# represents the verion) then change to this directory using the following command:
Set-Location -Path C:\poc-package-#.#.#

.PARAMETER StorageAccountContainerName
This is the storage account container name where the artifacts for this deployment will be uploaded to and referenced during the deployment.

.PARAMETER SpokeTemplateFile
This is the main ARM template file used for the deployment. This template file will call a series of nested templates, located in the nested templates folder.

.PARAMETER SpokeAAAwithLAWTemplateFile
This is used for specifying Azure Automation Account and Log Analytics Workspace ARM template file used for the deployment. This template file will call a series of nested templates, located in the nested templates folder.

.PARAMETER ArtifactsStagingDirectory
This parameter represents the current directory from where this script executes.

.PARAMETER DSCSourceFolder
This folder contains the DSC scripts, configuration data and the required zipped DSC resource modules

.PARAMETER vmSize
This is the size for all VMs provisioned in the app (spoke) network. It uses the default value of "Standard_D1_v2" to offer the best performance and availability accross all regions, but can be easily changed if needed in the future.

.PARAMETER ValidateOnly
This is used to validate the integrity of the ARM template

.PARAMETER AzureEnvironment
Select the azure environment for this solution from the following options: AzureCloud, AzureUSGovernment
AzureCloud: [Default] The solution will be deployed to the Azure Commercial cloud environment
AzureUSGovernment: The solution will be deployed to the Azure US Government cloud environment

.PARAMETER DeploymentOption
Use this parameter to select from the following: DeployAppOnly, DeployHubWithoutFW, DeployHubWithFW
DeployAppOnly: [Default] Will deploy the application network only
DeployHubWithoutFW: Automates the deployment of the hub network without the Azure Firewall resource
DeployHubWithFW: Automates the deployment o the hub network with the Azure Firewall resource

.PARAMETER skipModules
This switch parameter is used primarily for development and testing of this script to accelerate the testing and iteration cycles by skipping the time-consuming installation of Az and other modules if the script has previously been executed.

.EXAMPLE
[Validate template only but do not deploy]
From the current directory in which this script is located, execute using the following command
.\Deploy-AzureResourceGroup.ps1 -ValidateOnly -skipModules -Verbose

.EXAMPLE
[Deploy infrastrcture]
From the current directory in which this script is located, execute using the following command or execute from a PowerShell host (VSCode, Visual Studio 2017/2019, PowerShell ISE, etc.)
. .\Deploy-AzureResourceGroup.ps1 -Verbose

.EXAMPLE
[WITH THE -DeploymentOption parameter]
Please run the script using one of these values for the -DeploymentOption parameter, i.e.
NOTE: If this parameter isn't specified, the default value DeployAppOnly will be used to deploy just the App network.
\Deploy-AzureResourceGroup.ps1 -DeploymentOption DeployAppOnly (Default)

.EXAMPLE
. .\Deploy-AzureResourceGroup.ps1 -DeploymentOption DeployHubWithoutFW -Verbose

.EXAMPLE
. .\Deploy-AzureResourceGroup.ps1 -DeploymentOption DeployHubWithFW -Verbose

.INPUTS
None

.OUTPUTS
The outputs generated from this script includes:
1. A transcript log file to provide the full details of script execution. It will use the name format: Set-SecureCredentials-TRANSCRIPT-<Date-Time>.log

.NOTES

CONTRIBUTORS
1. Preston K. Parsard
2. Zeinab Mokhtarian Koorabbasloo
3. Robert Lightner

LEGAL DISCLAIMER:
This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment. 
THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE. 
We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the object code form of the Sample Code, provided that You agree:
(i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded;
(ii) to include a valid copyright notice on Your software product in which the Sample Code is embedded; and
(iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys' fees, that arise or result from the use or distribution of the Sample Code.
This posting is provided "AS IS" with no warranties, and confers no rights.

.LINK
1: https://millerb.co.uk/2019/02/28/My-Vscode-Setup.html#visual-studio-code
2: https://github.com/DeanCefola/AzureFirewall/blob/master/AzureFirewall.json
3. https://github.com/Azure/azure-quickstart-templates/tree/master/201-nsg-dmz-in-vnet/
4. https://docs.microsoft.com/en-us/azure/best-practices-network-security
5. https://www.softwaretestinghelp.com/what-is-software-testing-life-cycle-stlc/
6. https://www.testingexcellence.com/software-testing-glossary/
7. https://www.red-gate.com/simple-talk/cloud/infrastructure-as-a-service/azure-resource-manager-arm-templates/
8. https://azure.microsoft.com/en-us/blog/create-flexible-arm-templates-using-conditions-and-logical-functions/
9. https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-ip-addresses-overview-arm
10.https://docs.microsoft.com/en-us/azure/azure-government/documentation-government-get-started-connect-with-ps
11.https://azure.microsoft.com/en-us/updates/global-vnet-peering-available-in-azure-government/
12. https://docs.microsoft.com/en-us/azure/azure-monitor/insights/service-map-configure
13. https://www.clearpeople.com/insights/blog/2017/april/automation-account-schedules-with-time-zones


.COMPONENT
Azure Infrastructure, PowerShell, ARM, JSON

.ROLE
Automation Engineer
DevOps Engineer
Azure Engineer
Azure Administrator
Azure Architect

.FUNCTIONALITY
Deploys an Azure PoC Infrastructure

#>

<#
TASK-ITEMS:
VERSION STATUS  DESCRIPTION
3.13    test    Add feature flag for bypassing scheduled shutdowns, i.e. -SkipAutoShutdown 04sep2019
3.14    test    Remove '09.12.' from '/09.12.01.ScheduleStartupVMs' and '09.12.02.ScheduleShutdownVMs' 04sep2019
#>

[CmdletBinding()]
Param
(
    [string] $StorageContainerName = 'stageartifacts',
    [string] $SpokeTemplateFile = 'azuredeploy.json',
    [string] $staTemplateFile = ".\nested\00.00.00.createStorageAccount.json",
    [string] $staHubTemplateFile = ".\nested\00.00.01.createHubStorageAccount.json",
    [string] $SpokeAAAwithLAWTemplateFile = 'azureAppDeployAAAwithLAW.json',
    [string] $ArtifactsStagingDirectory = '.',
    [string] $DSCSourceFolder = 'dsc',
    [string] $vmSize = "Standard_D1_v2",
    [switch] $ValidateOnly,
    # index 0.0: Select Azure cloud environment
    [ValidateSet("AzureCloud","AzureUSGovernment")]
    [string] $AzureEnvironment = "AzureCloud",
    # index 1.0: Select deployment option
    [ValidateSet("DeployAppOnly","DeployHubWithoutFW","DeployHubWithFW",IgnoreCase=$true)]
    [string] $DeploymentOption = "DeployAppOnly",
    [string] $PSModuleRepository = "PSGallery",
    # Title for transcipt header
    [string]$label = "DEPLOY POC ENVIRONMENT FOR THE ACTIVATE AZURE WITH ADMINISTRATION AND GOVERNANCE OFFERING",
    # Separator width in number of characters for transcript header/footer
    [int]$headerCharCount = 200,
    [switch]$skipModules,
    [string]$includeAds = "no" # There is an error generated for deploying replica domain controllers: "Domain 'dev.contoso.com' could not be found.", so this will bypass creating the replica DC.
) # end param

$ErrorActionPreference = 'Continue'
# Set-StrictMode -Version Latest

$BeginTimer = Get-Date -Verbose

Write-Output "Paramters used for this script:"
$PSBoundParameters

#region MODULES
# Module repository setup and configuration
Set-PSRepository -Name $PSModuleRepository -InstallationPolicy Trusted -Verbose
Install-PackageProvider -Name Nuget -ForceBootstrap -Force

# Bootstrap dependent modules
$ARMDeployModule = "ARMDeploy"
if (Get-InstalledModule -Name $ARMDeployModule -ErrorAction SilentlyContinue)
{
    # If module exists, update it
    [string]$currentVersionADM = (Find-Module -Name $ARMDeployModule -Repository $PSModuleRepository).Version
    [string]$installedVersionADM = (Get-InstalledModule -Name $ARMDeployModule).Version
    If ($currentVersionADM -ne $installedVersionADM)
    {
            # Update modules if required
            Update-Module -Name $ARMDeployModule -Force -ErrorAction SilentlyContinue -Verbose
    } # end if
} # end if
# If the modules aren't already loaded, install and import it.
else
{
    Install-Module -Name $ARMDeployModule -Repository $PSModuleRepository -Force -Verbose
} #end If
Import-Module -Name $ARMDeployModule -Verbose
#endregion MODULES

#region Environment setup
# Use TLS 1.2 to support Nuget provider
Write-Output "Configuring security protocol to use TLS 1.2 for Nuget support when installing modules." -Verbose
[ServicePointManager]::SecurityProtocol = [SecurityProtocolType]::Tls12
#endregion

#region FUNCTIONS

# Add makecert file for creating certificate based service principal for Automation Account
function Add-MakeCertFile
{
    [CmdletBinding()]
    param()
    $makecertFileInfo = (Get-ChildItem -Path "C:\Program Files (x86)\Windows Kits\10\bin\" -File -Recurse -ErrorAction SilentlyContinue | Where-Object {($_.Name -match 'makecert.exe') -and ($_.Directory -match 'x64')})
    $makecertTargetDir = $env:ComSpec | Split-Path -Parent
    $makecertSourcePath = $null
    if ($makecertFileInfo.FullName.Length -gt 0)
    {
        $makecertSourcePath = $makecertFileInfo.FullName
    } # end if
    else 
    {
        $makecertSourcePath = "./makecert/makecert.exe"
    } # end else
    Copy-Item -Path $makecertSourcePath -Destination $makecertTargetDir -Force -PassThru -Verbose
} # end function
function New-ARMDeployTranscript
{
    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$LogDirectory,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$LogPrefix
    ) # end param

    # Get curent date and time
    $TimeStamp = (get-date -format u).Substring(0, 16)
    $TimeStamp = $TimeStamp.Replace(" ", "-")
    $TimeStamp = $TimeStamp.Replace(":", "")

    # Construct transcript file full path
    $TranscriptFile = "$LogPrefix-TRANSCRIPT" + "-" + $DeploymentOption + "-" + $TimeStamp + ".log"
    $script:Transcript = Join-Path -Path $LogDirectory -ChildPath $TranscriptFile

    # Create log and transcript files
    New-Item -Path $Transcript -ItemType File -ErrorAction SilentlyContinue
} # end function

# Validate template function
function Test-ARMDeployTemplate
{
    param ($ValidationOutput, [int] $Depth = 0)
    Set-StrictMode -Off
    return @($ValidationOutput | Where-Object { $_ -ne $null } | ForEach-Object { @('  ' * $Depth + ': ' + $_.Message) + @(Test-ARMDeployTemplate @($_.Details) ($Depth + 1)) })
} # end function
function Get-HubRegionCode
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory=$true)]
        [hashtable]$hubRegionCodes
    ) # end param
    Do
    {
        # The location refers to a geographic region of an Azure data center
        $enterHubRegionMessage = "Please enter the geographic location (Azure Data Center Region) for the HUB resources, i.e. [CZEU2 for eastus2 or CZCUN for northcentralus]"
        [string]$hubRegion = Read-Host $enterHubRegionMessage
        [string]$hubRegionCode = $hubRegion.ToUpper().Replace(" ","")
        $script:hubRegionFullName = "$($hubRegionCodes[$($hubRegion)])"
    } #end Do
    Until ($hubRegionCode -in $regionCodes.Keys)
    Return $hubRegionCode
} # end function

function Add-HubParameters
{
    [OutputType([hashtable])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [hashtable]$hubParameters
    ) # end param

    $hubParameters.Add("hubDeploymentOption",$DeploymentOption)
    $hubParameters.Add("_artifactsLocation",$artifactsLocation)
    $hubParameters.Add("_artifactsLocationSasToken",$ArtifactsLocationSasToken)
    $hubParameters.Add("storageDnsSuffix",$storageDnsSuffix)
    $hubParameters.Add("dnsNameLabelSuffix",$dnsNameLabelSuffix)
    $hubParameters.Add("adminUserName",$adminUserName)
    $hubParameters.Add("adminPassword",$adminPassword)
    $hubParameters.Add("hubLocation",$hubRegionFullName)
    $hubParameters.Add("randomInfix",$randomInfix)

    # TASK-ITEM: Add parameter below to main ARM template
    $hubParameters.Add("AutomationAccountName",$AutomationAccountName)
    $hubParameters.Add("aaaRegionFullName",$aaaRegionFullName)
    $HubParameters.Add("azureLogAnalyticsWorkspaceName",$azureLogAnalyticsWorkspaceName)
    $HubParameters.Add("alaRegionFullName",$alaRegionFullName)

    $hubParameters.Add("hubJumpServerName",$hubJumpServerName)
    $hubParameters.Add("hubFwName",$hubFwName)
    $hubParameters.Add("hubJumpServerNic",$hubJumpServerNic)
    $hubParameters.Add("storageAccountName",$StorageAccountName)
    $hubParameters.Add("staHubName",$staHubName)
    $hubParameters.Add("storageContainerName",$StorageContainerName)
    $hubParameters.Add("localMachinePublicIP",$localMachinePublicIP)
    $hubParameters.Add("hubVnetName",$hubVnetName)
    $hubParameters.Add("hubVnetAddressSpace",$hubVnetAddressSpace)
    $hubParameters.Add("hubJmpSubnetName",$hubJmpSubnetName)
    $hubParameters.Add("hubJmpSubnetRange",$hubJmpSubnetRange)
    $hubParameters.Add("hubPublicIp",$hubPublicIp)
    $hubParameters.Add("hubJumpServerSize",$hubJumpServerSize)
    $hubParameters.Add("hubJumpSubnetNSG",$hubJumpSubnetNSG)
    $hubParameters.Add("azureEnvironment",$AzureEnvironment)
    # TASK-ITEM: Add following parameters
    $hubParameters.Add("startupScheduleName",$startupScheduleName)
    $hubParameters.Add("shutdownScheduleName",$shutdownScheduleName)
    $hubParameters.Add("scheduledStopTime",$scheduledStopTime)
    $hubParameters.Add("scheduledStartTime",$scheduledStartTime)
    $hubParameters.Add("scheduledExpiryTime",$scheduledExpiryTime)
    return $hubParameters
} # end function
#endregion FUNCTIONS

### This PowerShell Script creates PoC Environment based on JSON Templates

#region INITIALIZE VALUES
$serverName = $null
$userName = $null
$connectionMessage = $null
$pocResourceGroupFilter = "*NP-RGP-01*"
# Create Log file
[string]$Transcript = $null

#region TRANSCRIPT
$scriptName = $MyInvocation.MyCommand.name
# Use script filename without exension as a log prefix
$LogPrefix = $scriptName.Split(".")[0]
$modulePath = (Get-InstalledModule -Name Az).InstalledLocation | Split-Path -Parent | Split-Path -Parent

$LogDirectory = Join-Path $modulePath -ChildPath $LogPrefix -Verbose
# Create log directory if not already present
If (-not(Test-Path -Path $LogDirectory -ErrorAction SilentlyContinue))
{
    New-Item -Path $LogDirectory -ItemType Directory -Verbose
} # end if

# funciton: Create log files for transcript
New-ARMDeployTranscript -LogDirectory $LogDirectory -LogPrefix $LogPrefix -Verbose

Start-Transcript -Path $Transcript -IncludeInvocationHeader -Verbose
#endregion TRANSCRIPT

Add-MakeCertFile -Verbose

# function: Create new header
$header = New-ARMDeployHeader -label $label -charCount $headerCharCount -Verbose

#endregion INITIALIZE VALUES

Write-Output $header.SeparatorDouble  -Verbose
Write-Output $Header.Title  -Verbose
Write-Output $header.SeparatorSingle  -Verbose

# Set script path
Write-Output "Changing path to script directory..." -Verbose
Set-Location -Path $PSScriptRoot -Verbose
Write-Output "Current directory has been changed to script root: $PSScriptRoot" -Verbose

[string]$proceed = $null
Write-Verbose "WARNING!"
$proceed = Read-Host -Prompt @"
The AzureRM modules will be removed and replaced with the Az modules.
For details and instructions why and how to upgrade to the Az modules, see https://docs.microsoft.com/en-us/powershell/azure/new-azureps-module-az?view=azps-3.3.0.
OK to proceed ['Y' or 'YES' to continue | 'N' or 'NO' to exit]?
"@
if ($proceed -eq "N" -OR $proceed -eq "NO")
{
    Write-Output "Deployment terminated by user. Exiting..."
    PAUSE
    EXIT
} #end if ne Y
elseif ($proceed -eq "Y" -OR $proceed -eq "YES")
{

$ModuleToRemove = "AzureRM"
Remove-ARMDeployPSModule -ModuleToRemove $ModuleToRemove -Verbose

if (-not($skipModules))
{
    #region Az modules
    # Get required PowerShellGallery.com modules.
    Install-Module -Name Az -AllowClobber -Verbose
    Get-ARMDeployPSModule -ModulesToInstall "AzureAutomation", "xActiveDirectory", "xComputerManagement", "xStorage", "xNetworking", "xSmbShare" -PSRepository $PSModuleRepository -Verbose
    #endregion Az modules
} # end if

#region RUNBOOK PROPERTIES
# $timeZone = [TimeZoneInfo]::Local.DisplayName
$startupScheduleName = "Start 0800 Weekdays LOCAL"
$shutdownScheduleName = "Stop 1800 Weekdays LOCAL"

# Runbook schedule properties
$nowPlusOneDay = (Get-Date).AddDays(1)
$startupTime = $nowPlusOneDay.ToString("yyyy-MM-ddT08:00:00")
$shutdownTime = $nowPlusOneDay.ToString("yyyy-MM-ddT18:00:00")
[string]$utcOffset = (Get-TimeZone).BaseUtcOffSet.hours
[string]$offset = $null
$offset = Format-AutomationAccountScheduleTimeZoneOffset -offset $utcOffset

$scheduleStopSuffix = ":00"
$fullOffset = $offset + $scheduleStopSuffix
$scheduledStopTime = $shutdownTime + $fullOffset
$scheduledStartTime = $startupTime + $fullOffset
$scheduledExpiryTime ="9999-12-31T00:00:00-00:00"
# https://devblogs.microsoft.com/scripting/powertip-use-powershell-to-display-time-in-24-hour-format/
#endregion RUNBOOK PROPERTIES

Write-Output "Please see the open dialogue box in your browser to authenticate to your Azure subscription..."

# Clear any possible cached credentials for other subscriptions
Clear-AzContext

# index 5.0: Authenticate to Azure subscription
Switch ($AzureEnvironment)
{
    "AzureCloud" { Connect-AzAccount -Environment AzureCloud }
    "AzureUSGovernment" { Connect-AzAccount -Environment AzureUSGovernment }
} # end switch

# https://docs.microsoft.com/en-us/azure/azure-government/documentation-government-get-started-connect-with-ps
# To connect to AzureUSGovernment, use:
# Connect-AzAccount -EnvironmentName AzureUSGovernment
Do
{
    # TASK-ITEM: List subscriptions
    (Get-AzSubscription).Name
	[string]$Subscription = Read-Host "Please enter your subscription name, i.e. [MySubscriptionName] "
	$Subscription = $Subscription.ToUpper()
} #end Do
Until ($Subscription -in (Get-AzSubscription).Name)
Select-AzSubscription -SubscriptionName $Subscription -Verbose
$subscriptionId = (Select-AzSubscription -SubscriptionName $Subscription).Subscription.id

$regionCodes = @{
    CZEAS = "eastasia"
    CZSEA = "southeastasia"
    CZCUS = "centralus"
    CZEU1 = "eastus"
    CZEU2 = "eastus2"
    CZWU1 = "westus"
    CZCUN = "northcentralus"
    CZSCU = "southcentralus"
    CZNEU = "northeurope"
    CZWEU = "westeurope"
    CZWJP = "japanwest"
    CZEJP = "japaneast"
    CZSBR = "brazilsouth"
    CZEAU = "australiaeast"
    CZSAU = "australiasoutheast"
    CZSIN = "southindia"
    CZCIN = "centralindia"
    CZWIN = "westindia"
    CZCCA = "canadacentral"
    CZECA = "canadaeast"
    CZSUK = "uksouth"
    CZWUK = "ukwest"
    CZWCU = "westcentralus"
    CZWU2 = "westus2"
    CZCKR = "koreacentral"
    CZSKR = "koreasouth"
    CZCFR = "francecentral"
    CZSFR = "francesouth"
    CZCAU = "australiacentral"
    CZCA2 = "australiacentral2"
    CZNSA = "southafricanorth"
    CZWSA = "southafricawest"
    USGVA = "usgovvirginia"
    USGTX = "usgovtexas"
} # end hashtable

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
        aaa = "austrailiasoutheast"
        ala = "austrailiasoutheast"
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
} # end ht

# index 7.0: Select Azure region for APP network
Switch ($AzureEnvironment)
{
    "AzureCloud"
    {
        # https://azure.microsoft.com/en-us/global-infrastructure/regions/
        # http://map.buildazure.com/
        # https://azurespeedtest.azurewebsites.net/
        # https://devblogs.microsoft.com/scripting/powertip-identify-regions-in-azure/
        # Get-AzLocation | Where-Object {$_.DisplayName -match 'US'} | Format-Table
        Write-Output "The list of available regions are :"
        $regionCodes | Format-Table -AutoSize 

        Do
        {
            # The location refers to a geographic region of an Azure data center
            $enterRegionMessage = "Please enter the geographic location (Azure Data Center Region) for the SPOKE network resources, i.e. [CZEU2 for eastus2 or CZCUN for northcentralus]"
            [string]$Region = Read-Host $enterRegionMessage
            $regionCode = $region.ToUpper().Replace(" ","")
            $regionFullName = "$($regionCodes[$($region)])"
            Write-Output "Region selected: $regionCode = $regionFullName"
            Write-Output ""
        } #end Do
        Until ($regionCode -in $regionCodes.Keys)

         # https://www.itprotoday.com/iaaspaas/view-available-regions-azure-services-using-powershell
         # automationAccountResources = Get-AzREsourceProvider -ProviderNamespace Microsoft.Automation
         # automationAccountResources.ResourceTypes.Where{($_.ResourceTypeName -eq 'automationAccounts')}.Location
         <#
         $automationAccountId = (Get-AzResource -ResourceGroupName $hubResourceGroupName -ResourceType "Microsoft.Automation/automationAccounts" -ResourceName *$aaaSuffix*).ResourceId
         $workspaceId = (Get-AzOperationalInsightsWorkspace | Where-Object Name -match $alaSuffix).ResourceId
         Set-AzDiagnosticSetting -ResourceId $automationAccountId -WorkspaceId $workspaceId -Enabled $true
         WARNING: 09:43:20 - *** The namespace for all the model classes will change from Microsoft.Azure.Management.Monitor.Management.Models to Microsoft.Azure.Management.Monitor.Models in future releases.
         WARNING: 09:43:20 - *** The namespace for output classes will be uniform for all classes in future releases to make it independent of modifications in the model classes.
         #>

        $storageDnsSuffix = ".blob.core.windows.net"
        $dnsNameLabelSuffix = ".cloudapp.azure.com"
    } # end condition
    "AzureUSGovernment"
    {
        $regionCodesGov = @{
            # Hub Vnet (primary)
            USGVA = "usgovvirginia"
            # Spoke Vnet (secondary)
            USGTX = "usgovtexas"
        } # end hashtable
        # Spoke Vnet (secondary)
        $regionCodeGovSpoke = "USGTX"
        $regionCodeGovHub = "USGVA"
        $storageDnsSuffix = ".blob.core.usgovcloudapi.net"
        $dnsNameLabelSuffix = ".cloudapp.usgovcloudapi.net"
        $regionCode = $regionCodeGovSpoke
        $hubRegionCode = $regionCodeGovHub
        $hubRegionFullName = $regionCodesGov.USGVA
        $regionFullName = $regionCodesGov.USGTX
    } # end condition
} # end switch

$resourceGroupName = $regionCode + "-APP-NP-RGP-01"
New-AzResourceGroup -Name $resourceGroupName -Location $regionFullName -Verbose

$saSku = 'Standard_LRS'
$staPrefix = "1" # storage account name prefix
$staPrefixHub = "2" # storage account name prefix for hub
$staSuffix = "sta" # storage account name suffix
# Ensure that the storage account name is globally unique in DNS
Do
{
    $randomInfix = (New-Guid).Guid.Replace("-","").Substring(0,8)
    $StorageAccountName = $staPrefix + $staSuffix + $randomInfix
} #end while
While (-not((Get-AzStorageAccountNameAvailability -Name $StorageAccountName).NameAvailable))

[hashtable]$staParams = @{}
$staParams.Add("staName",$StorageAccountName)
$staParams.Add("storageContainerName",$StorageContainerName)

[string]$dateSuffix = (Get-Date -Format o).Substring(0,16).replace(":","")

$staDeployName = "staDeploy-" + $dateSuffix
# https://stackoverflow.com/questions/66341090/facing-issues-on-deploying-template-for-azure-file-share-storage-account
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -Name $staDeployName -TemplateFile $staTemplateFile -TemplateParameterObject $staParams -Mode Incremental -Verbose -ErrorAction SilentlyContinue

# Create names for shared resources

# index 13.0: Create recovery services vault name
$rsvSuffix = "-RSV-01"
$recoveryServicesVaultName = $regionCode + "-APP-NP-" + $randomInfix + $rsvSuffix
# Create log analytics workspace name. This region should be the same as the automation account region to ensure support for linking.
$alaSuffix = "-ALA-01"

# index 15.0: Create APP network dev server name
$devServerName = $regionCode + "POCNPDEV01"
# App VNET Name
$appVnetName = $regionCode + "-APP-NP-VNT-01"
New-ARMDeployDscArchive -DSCSourceFolder $DSCSourceFolder -Verbose
# index 16.0: Create DSC configuration archive
$runbookModules = @("Az.Accounts","Az.Resources","Az.Compute","Az.Automation","Az.Network")
# index 17.0: Create the storage account
New-AzResourceGroup -Location $regionFullName -Name $resourceGroupName -Force
# TASK-ITEM: Remove after testing
# $StorageAccount = New-AzStorageAccount -StorageAccountName $StorageAccountName -Type $saSku -ResourceGroupName $resourceGroupName -Location $regionFullName
$StorageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $StorageAccountName

# index 18.0: Create artifacts location
$artifactsLocation = $StorageAccount.Context.BlobEndPoint + $StorageContainerName

# index 19.0: Filter artifacts to upload
# These files will be uploaded to the previously created storage account
$runbooksDir = "$ArtifactsStagingDirectory\runbooks"
$runbookScripts = (Get-ChildItem -Path $runbooksDir\* -File -Include *.ps1 | Select-Object -Property FullName).FullName | Where-Object {$_ -match 'VirtualMachines'}

$dirList = $ArtifactsStagingDirectory,"$ArtifactsStagingDirectory\dsc","$ArtifactsStagingDirectory\nested",$runbooksDir

$splatterArtifactsParams = @{
    dirList = $dirList
    ArtifactsStagingDirectory = $ArtifactsStagingDirectory
    StorageAccount = $StorageAccount
    storageContainerName = $StorageContainerName
} # end hashtable

Push-ARMDeployArtifactsToAzureStorage @splatterArtifactsParams -Verbose

# index 21: Generate 4 hour SAS token for artifacts location
# ...if one was not provided in the parameters file
$ArtifactsLocationSasToken =  New-AzStorageContainerSASToken -Container $StorageContainerName -Context $StorageAccount.Context -Permission r -ExpiryTime (Get-Date).AddHours(4)
$ArtifactsLocationSasToken = ConvertTo-SecureString -String $ArtifactsLocationSasToken -AsPlainText -Force
$hubPublicIp = $null
$hubTemplateFile = $null
$hubJumpServerName = $null
$appVnetAddrRange = "10.20.10.0/26"

# Create automation account. This region should be the same as the log analytics region to ensure support for linking.
$aaaSuffix = "-AAA-01"

#region Generate credentials
$adminUserName = "adm.infra.user"
$adminCred = Get-Credential -UserName $adminUserName -Message "Enter password for user: $adminUserName. Password must be complex, at least 12 characters including 3 of the following: lowercase, uppercase, numbers and special characters."
# TASK-ITEM: Use secure string for password.
# $adminPassword = $adminCred.GetNetworkCredential().password
$adminPassword = $adminCred.password
# index 23: Create parameter hashtable for ARM templates

# https://pscustomobject.github.io/powershell/howto/PowerShell-Create-Credential-Object/

Class CredClass
{
    [string]$userName = $adminUserName
    [string]$password = $adminPassword
} # end class

# $credObj = [CredClass]::new()

#endregion Generate credentials

[hashtable]$parameters = @{}
[hashtable]$hubParameters = @{}
[hashtable]$hubParamsWithoutFW = @{}
[hashtable]$hubParamsWithFW = @{}

# Provision PoC environment based on deployment option selected
$noDeploymentOptionMessage = "Deployment option: $DeploymentOption is invalid. Terminating script..."

If (($DeploymentOption -eq "DeployHubWithoutFW") -or ($DeploymentOption -eq "DeployHubwithFW"))
{
    If ($AzureEnvironment -eq "AzureCloud")
    {
        Write-Output "The list of available regions are :"
        Write-Output $regionCodes
        #TASK-ITEM: Use switch statement to account for $aaaRegionCode exceptions in US
        $hubRegionCode = Get-HubRegionCode -hubRegionCodes $regionCodes
    } # if
    $alaRegionCode = $aaaRegionCode = $hubRegionCode
    $alaRegionFullName = $alaToaaaMap[$alaRegionCode].ala
    $aaaRegionFullName = $alaToaaaMap[$aaaRegionCode].aaa
    $AutomationAccountName = $aaaRegionCode + "-INF-NP-" + $randomInfix + $aaaSuffix
    $azureLogAnalyticsWorkspaceName = $alaRegionCode + "-INF-NP-" + $randomInfix + $alaSuffix
    # Construct resource Group names
    [string]$hubResourceGroupName = $hubRegionCode + "-INF-NP-RGP-01"
    New-AzResourceGroup -Name $hubResourceGroupName -Location $hubRegionFullName -Verbose
    $hubFwName = $hubRegionCode + "-INF-NP-AFW-01"
    $hubJumpServerName = $hubRegionCode + "INFNPJMP01"
    # Get public IP address of script execution host
    # https://gallery.technet.microsoft.com/scriptcenter/Get-ExternalPublic-IP-c1b601bb
    $localMachinePublicIP = Invoke-RestMethod http://ipinfo.io/json | Select-Object -ExpandProperty ip
    $hubJumpServerNic = $hubJumpServerName + "-" + "NIC"
    $hubVnetName = $hubRegionCode + "-INF-NP-VNT-01"
    $hubVnetAddressSpace = "10.10.0.0/22"
    $hubJmpSubnetName = $hubRegionCode + "-JMP-NP-SUB-01"
    $hubJmpSubnetRange = "10.10.1.0/24"
    $hubJmpServerPrvIp = "10.10.1.4"
    # Inherit the same value for the vmSize script parameter
    $hubJumpServerSize = $vmSize
    $hubJumpSubnetNSG = $hubRegionCode + "-JMP-NP-NSG-01"
    #region deployHubStorage
    Do
    {
        $staHubInfix = (New-Guid).Guid.Replace("-","").Substring(0,8)
        $staHubName = $staPrefixHub + $staSuffix + $staHubInfix
    } #end while
    While (-not((Get-AzStorageAccountNameAvailability -Name $staHubName).NameAvailable))
    [hashtable]$staHubParams = @{}
    $staHubParams.Add("staHubName",$staHubName)

    $staHubDeployName = "staHubDeploy-" + $dateSuffix
    New-AzResourceGroupDeployment -ResourceGroupName $hubResourceGroupName -Name $staHubDeployName -TemplateFile $staHubTemplateFile -TemplateParameterObject $staHubParams -Mode Incremental -Verbose -ErrorAction SilentlyContinue
    #endregion deployHubStorage
} # end if

If ($DeploymentOption -eq "DeployHubWithoutFW")
{
    $hubPublicIp = $hubJumpServerName + "-PIP"
    $hubTemplateFile = "azuredeployHubWithoutFw.json"
    $hubTemplateFilePath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $hubTemplateFile))
    # a. Use custom script extension to install modules ?
    $hubParamsWithoutFW = Add-HubParameters -hubParameters $hubParameters -Verbose
    if ($ValidateOnly)
    {
        $ErrorMessages = Test-ARMDeployTemplate (Test-AzResourceGroupDeployment -ResourceGroupName $hubResourceGroupName -TemplateFile $hubTemplateFilePath -TemplateParameterObject $hubParamsWithoutFW)
        if ($ErrorMessages)
        {
            Write-Output '', 'Validation returned the following errors:', @($ErrorMessages), '', 'Template is invalid.'
        } # end if
        else
        {
            Write-Output "", "Template for filepath: $hubTemplateFilePath is valid."
        } # end else
    } # end if
    else
    {
        # Deploy Hub
        $hubRgDeploymentWithoutFW = 'hubAzuredeployWithoutFW-' + ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmm')
        New-AzResourceGroupDeployment -Name $hubRgDeploymentWithoutFW `
        -ResourceGroupName $hubResourceGroupName `
        -TemplateFile $hubTemplateFilePath `
        -TemplateParameterObject $hubParamsWithoutFW `
        -Force `
        -Verbose `
        -ErrorVariable ErrorMessages
        if ($ErrorMessages)
        {
            Write-Output '', 'Template deployment returned the following errors:', @(@($ErrorMessages) | ForEach-Object { $_.Exception.Message.TrimEnd("`r`n") })
        } # end if
        else
        {
            $StopTimerWoFw = Get-Date -Verbose
            Write-Output "Calculating elapsed time..."
            $ExecutionTimeWoFw = New-TimeSpan -Start $BeginTimer -End $StopTimerWoFw
            $FooterWoFw = "TOTAL SCRIPT EXECUTION TIME: $ExecutionTimeWoFW"
            Write-Output ""
            Write-Output $FooterWoFw
        } # end else
    } # end else
} # end if
ElseIf ($DeploymentOption -eq "DeployHubWithFW")
{
    $hubTemplateFile = "azuredeployHubWithFw.json"
    $hubTemplateFilePath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $hubTemplateFile))
    $hubFwSubnetName = "AzureFirewallSubnet"
    $hubFwSubnetRange = "10.10.0.0/24"
    $hubPublicIp = $hubFwName + "-PIP"
    $hubRouteTable = $hubRegionCode + "-INF-NP-UDR-01"
    $hubRouteDisablePropagation = $false
    # ZeroTraffic
    $hubRouteToAfwName = "ZeroTraffic"
    $hubRouteToAfwAddrPrefix = "0.0.0.0/0"
    $hubRouteNextHopType = "VirtualAppliance"
    $hubFwPrvIp = "10.10.0.4"
    $hubRouteToAfwNextHopAddress = $hubFwPrvIp
    # RouteToSpoke
    $hubRTS = "RouteToSpoke"
    $hubRTSAddrPrefix = "10.20.10.0/26"

    $appRouteTableObj = [PSCustomObject]@{
        tableName = $regionCode + "-APP-NP-UDR-01"
        zeroRoute = "ZeroTraffic"
        zeroAddrPrefix = "0.0.0.0/0"
        zeroNextHopType = $hubRouteNextHopType
        zeroNextHopAddr = $hubFwPrvIp
        hubRoute = "RouteToHub"
        hubAddrPrefix = "10.10.0.0/22"
        hubNextHopType = $hubRouteNextHopType
        hubNextHopAddr = $hubFwPrvIp
    } # end PSCustomObject

    [string]$hubFwNatRuleCollName = "NATforRDP"
    [int]$hubFwNatRuleCollPriority = 1100
    [string]$hubFwNatRuleCollAction = "Allow"
    [string]$hubFwNatRule01Name = "RDPToJumpServer"
    [string]$hubFwNatRule01Protocol = "TCP"
    [string]$hubFwNatRule01SourceAddr = $localMachinePublicIP
    [string]$hubFwNatRule01DestPort = "50000"
    [string]$hubFwNatRule01TransAddr = $hubJmpServerPrvIp
    [string]$hubFwNatRule01TransPort = "3389"

    [string]$hubFwNetworkRuleCollName = "AllowInternet"
    [int]$hubFwNetworkRulePriority = 1200
    [string]$hubFwNetworkRuleCollAction = "Allow"
    [string]$hubFwNetworkRule01Name = "JumpAllowInternet"
    [string]$hubFwNetworkRule01Protocol = "TCP"
    [string]$hubFwNetworkRule01SourceAddr = $hubJmpServerPrvIp
    [string]$hubFwNetworkRule01DestAddr = "*"
    [string[]]$hubFwNetworkRule01DestPort = @("80","443")

    [string]$hubFwNetworkRuleCollName02 = "AllowHubandSpoke"
    [int]$hubFwNetworkRulePriority02 = 1250
    [string]$hubFwNetworkRuleCollAction02 = "Allow"

    [string]$hubFwNetworkRule02Name = "HubToSpoke"
    [string]$hubFwNetworkRule02Protocol = "Any"
    [string]$hubFwNetworkRule02SourceAddr = $hubVnetAddressSpace
    [string]$hubFwNetworkRule02DestAddr = $appVnetAddrRange
    [string]$hubFwNetworkRule02DestPort = "*"

    [string]$hubFwNetworkRule03Name = "SpokeToHub"
    [string]$hubFwNetworkRule03Protocol = "Any"
    [string]$hubFwNetworkRule03SourceAddr = $appVnetAddrRange
    [string]$hubFwNetworkRule03DestAddr = $hubVnetAddressSpace
    [string]$hubFwNetworkRule03DestPort = "*"

    [string]$hubFwAppRuleCollName = "AllowAzurePaaS"
    [int]$hubFwAppRulePriority = 1300
    [string]$hubFwAppRuleAction = "Allow"
    [string]$hubFwAppRule01Name = "AllowAzurePaaSServices"
    [string[]]$hubFwAppRule01SourceAddr = @($hubVnetAddressSpace, $appVnetAddrRange)
    [string[]]$hubFwAppRule01fqdnTags = @("MicrosoftActiveProtectionService", "WindowsDiagnostics", "WindowsUpdate", "AzureBackup")
    [string]$hubFwAppRule02Name = "AllowLogAnalytics"
    [string[]]$hubFwAppRule02SourceAddr = @($hubVnetAddressSpace, $appVnetAddrRange)
    [string]$hubFwAppRule02Protocol = "Https"
    [int]$hubFwAppRule02Port = 443
    [string[]]$hubFwAppRule02TargetFqdn = @("*.ods.opsinsights.azure.com", "*.oms.opsinsights.azure.com", "*.blob.core.windows.net", "*.azure-automation.net")

    $hubParamsWithFW = Add-HubParameters -hubParameters $hubParameters -Verbose
    # Routes defintion
    $hubParameters.Add("hubFwSubnetName",$hubFwSubnetName)
    $hubParameters.Add("hubFwSubnetRange",$hubFwSubnetRange)
    $hubParameters.Add("hubRouteTable",$hubRouteTable)
    $hubParameters.Add("hubRouteDisablePropagation",$hubRouteDisablePropagation)
    $hubParameters.Add("hubRouteToAfwName",$hubRouteToAfwName)
    $hubParameters.Add("hubRouteToAfwAddrPrefix",$hubRouteToAfwAddrPrefix)
    $hubParameters.Add("hubRouteNextHopType",$hubRouteNextHopType)
    $hubParameters.Add("hubFwPrvIp",$hubFwPrvIp)
    $hubParameters.Add("hubRouteToAfwNextHopAddress",$hubRouteToAfwNextHopAddress)
    $hubParameters.Add("hubRTS",$hubRTS)
    $hubParameters.Add("hubRTSAddrPrefix",$hubRTSAddrPrefix)

    # NAT definition
    $hubParameters.Add("hubFwNatRuleCollName",$hubFwNatRuleCollName)
    $hubParameters.Add("hubFwNatRuleCollPriority",$hubFwNatRuleCollPriority)
    $hubParameters.Add("hubFwNatRuleCollAction",$hubFwNatRuleCollAction)
    $hubParameters.Add("hubFwNatRule01Name",$hubFwNatRule01Name)
    $hubParameters.Add("hubFwNatRule01Protocol",$hubFwNatRule01Protocol)
    $hubParameters.Add("hubFwNatRule01SourceAddr",$hubFwNatRule01SourceAddr)
    $hubParameters.Add("hubFwNatRule01DestPort",$hubFwNatRule01DestPort)
    $hubParameters.Add("hubFwNatRule01TransAddr",$hubFwNatRule01TransAddr)
    $hubParameters.Add("hubFwNatRule01TransPort",$hubFwNatRule01TransPort)

    # Networks defintion
    $hubParameters.Add("hubFwNetworkRuleCollName",$hubFwNetworkRuleCollName)
    $hubParameters.Add("hubFwNetworkRulePriority",$hubFwNetworkRulePriority)
    $hubParameters.Add("hubFwNetworkRuleCollAction",$hubFwNetworkRuleCollAction)

    $hubParameters.Add("hubFwNetworkRule01Name",$hubFwNetworkRule01Name)
    $hubParameters.Add("hubFwNetworkRule01Protocol",$hubFwNetworkRule01Protocol)
    $hubParameters.Add("hubFwNetworkRule01SourceAddr",$hubFwNetworkRule01SourceAddr)
    $hubParameters.Add("hubFwNetworkRule01DestAddr",$hubFwNetworkRule01DestAddr)
    $hubParameters.Add("hubFwNetworkRule01DestPort",$hubFwNetworkRule01DestPort)

    $hubParameters.Add("hubFwNetworkRuleCollName02",$hubFwNetworkRuleCollName02)
    $hubParameters.Add("hubFwNetworkRulePriority02",$hubFwNetworkRulePriority02)
    $hubParameters.Add("hubFwNetworkRuleCollAction02",$hubFwNetworkRuleCollAction02)

    $hubParameters.Add("hubFwNetworkRule02Name",$hubFwNetworkRule02Name)
    $hubParameters.Add("hubFwNetworkRule02Protocol",$hubFwNetworkRule02Protocol)
    $hubParameters.Add("hubFwNetworkRule02SourceAddr",$hubFwNetworkRule02SourceAddr)
    $hubParameters.Add("hubFwNetworkRule02DestAddr",$hubFwNetworkRule02DestAddr)
    $hubParameters.Add("hubFwNetworkRule02DestPort",$hubFwNetworkRule02DestPort)

    $hubParameters.Add("hubFwNetworkRule03Name",$hubFwNetworkRule03Name)
    $hubParameters.Add("hubFwNetworkRule03Protocol",$hubFwNetworkRule03Protocol)
    $hubParameters.Add("hubFwNetworkRule03SourceAddr",$hubFwNetworkRule03SourceAddr)
    $hubParameters.Add("hubFwNetworkRule03DestAddr",$hubFwNetworkRule03DestAddr)
    $hubParameters.Add("hubFwNetworkRule03DestPort",$hubFwNetworkRule03DestPort)

    # Applications definition
    $hubParameters.Add("hubFwAppRuleCollName",$hubFwAppRuleCollName)
    $hubParameters.Add("hubFwAppRulePriority",$hubFwAppRulePriority)
    $hubParameters.Add("hubFwAppRuleAction",$hubFwAppRuleAction)
    $hubParameters.Add("hubFwAppRule01Name",$hubFwAppRule01Name)
    $hubParameters.Add("hubFwAppRule01SourceAddr",$hubFwAppRule01SourceAddr)
    $hubParameters.Add("hubFwAppRule01fqdnTags",$hubFwAppRule01fqdnTags)
    $hubParameters.Add("hubFwAppRule02Name",$hubFwAppRule02Name)
    $hubParameters.Add("hubFwAppRule02SourceAddr",$hubFwAppRule02SourceAddr)
    $hubParameters.Add("hubFwAppRule02Protocol",$hubFwAppRule02Protocol)
    $hubParameters.Add("hubFwAppRule02Port",$hubFwAppRule02Port )
    $hubParameters.Add("hubFwAppRule02TargetFqdn",$hubFwAppRule02TargetFqdn)

    if ($ValidateOnly)
    {
        $ErrorMessages = Test-ARMDeployTemplate (Test-AzResourceGroupDeployment -ResourceGroupName $hubResourceGroupName -TemplateFile $hubTemplateFilePath -TemplateParameterObject $hubParamsWithFW)
        if ($ErrorMessages)
        {
            Write-Output '', 'Validation returned the following errors:', @($ErrorMessages), '', 'Template is invalid.'
        } # end if
        else
        {
            Write-Output "", "Template for file path: $hubTemplateFilePath is valid."
        } # end else
    } # end if
    else
    {
        # Deploy Hub w/ FW
        $hubRgDeploymentWithFW = 'hubAzuredeployWithFW-' + ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmm')
        New-AzResourceGroupDeployment -Name $hubRgDeploymentWithFW `
        -ResourceGroupName $hubResourceGroupName `
        -TemplateFile $hubTemplateFilePath `
        -TemplateParameterObject $hubParamsWithFW `
        -Force `
        -Verbose `
        -ErrorVariable ErrorMessages
        if ($ErrorMessages)
        {
            Write-Output '', 'Template deployment returned the following errors:', @(@($ErrorMessages) | ForEach-Object { $_.Exception.Message.TrimEnd("`r`n") })
        } # end if
        else
        {
            $StopTimerWithFw = Get-Date -Verbose
            Write-Output "Calculating elapsed time..."
            $ExecutionTimeWithFw = New-TimeSpan -Start $BeginTimer -End $StopTimerWithFw
            $FooterWithFw = "TOTAL SCRIPT EXECUTION TIME: $ExecutionTimeWithFW"
            Write-Output ""
            Write-Output $FooterWithFw
        } # end else
    } # end else
} # end elseif
ElseIf ($DeploymentOption -eq "DeployAppOnly")
{
    $alaRegionCode = $aaaRegionCode = $regionCode
    $aaaRegionFullName = $alaToaaaMap[$aaaRegionCode].aaa
    $alaRegionFullName = $alaToaaaMap[$alaRegionCode].ala
} # end elseif
Else
{
    Write-Verbose $noDeploymentOptionMessage
    Exit
} # end else

#region Deploy Spoke
$serverName = $parameters.devServerName
$userName = $adminUserName + "@dev.contoso.com"

$AutomationAccountName = $aaaRegionCode + "-INF-NP-" + $randomInfix + $aaaSuffix
$azureLogAnalyticsWorkspaceName = $alaRegionCode + "-INF-NP-" + $randomInfix + $alaSuffix

$parameters.Add("_artifactsLocation",$artifactsLocation)
$parameters.Add("_artifactsLocationSasToken",$ArtifactsLocationSasToken)
$parameters.Add("storageDnsSuffix",$storageDnsSuffix)
$parameters.Add("dnsNameLabelSuffix",$dnsNameLabelSuffix)
$parameters.Add("adminUserName",$adminUserName)
$parameters.Add("adminPassword",$adminPassword)
$parameters.Add("location",$regionFullName)
$parameters.Add("randomInfix",$randomInfix)

# TASK-ITEM: Add parameter below to main ARM template
$parameters.Add("AutomationAccountName",$AutomationAccountName)
$parameters.Add("aaaRegionFullName",$aaaRegionFullName)
$parameters.Add("azureLogAnalyticsWorkspaceName",$azureLogAnalyticsWorkspaceName)
$parameters.Add("alaRegionFullName",$alaRegionFullName)

$parameters.Add("recoveryServicesVaultName",$recoveryServicesVaultName)
$parameters.Add("regionCode",$regionCode)
$parameters.Add("devServerName",$devServerName)
$parameters.Add("storageAccountName",$StorageAccountName)
$parameters.Add("storageContainerName",$StorageContainerName)
$parameters.Add("deploymentOption",$DeploymentOption)
$parameters.Add("azureEnvironment",$AzureEnvironment)
$parameters.Add("vmSize",$vmSize)
$parameters.Add("appVnetName",$appVnetName)
$parameters.Add("startupScheduleName",$startupScheduleName)
$parameters.Add("shutdownScheduleName",$shutdownScheduleName)
$parameters.Add("scheduledStopTime",$scheduledStopTime)
$parameters.Add("scheduledStartTime",$scheduledStartTime)
$parameters.Add("scheduledExpiryTime",$scheduledExpiryTime)
$parameters.Add("includeAds",$includeAds)

$TemplateFilePath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $SpokeTemplateFile))

if ($ValidateOnly)
{
    $ErrorMessages = Test-ARMDeployTemplate (Test-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFilePath -TemplateParameterObject $parameters)
    if ($ErrorMessages)
    {
        Write-Output '', 'Validation returned the following errors:', @($ErrorMessages), '', 'Template is invalid.'
    } # end if
    else
    {
        Write-Output "", "Template for file path: $TemplateFilePath is valid."
        Exit
    } # end else
} # end if
else
{
    # Deploy App
    $rgDeployment = 'azuredeploy-' + ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmm')
    New-AzResourceGroupDeployment -Name $rgDeployment `
    -ResourceGroupName $resourceGroupName `
    -TemplateFile $TemplateFilePath `
    -TemplateParameterObject $parameters `
    -Force `
    -Verbose `
    -ErrorVariable ErrorMessages
    if ($ErrorMessages)
    {
        Write-Output '', 'Template deployment returned the following errors:', @(@($ErrorMessages) | ForEach-Object { $_.Exception.Message.TrimEnd("`r`n") })
    } # end if
    else
    {
        # Deployment of App environment is successful
        $StopTimer = Get-Date -Verbose
        Write-Output "Calculating elapsed time..."
        $ExecutionTime = New-TimeSpan -Start $BeginTimer -End $StopTimer
        $Footer = "TOTAL SCRIPT EXECUTION TIME: $ExecutionTime"
        Write-Output ""
        Write-Output $Footer
    } # end else

    # Deploy Automation Account and Log Analytics Workspace if deployment type == DeployAppOnly in same Resource Group as App
    if( $DeploymentOption -eq "DeployAppOnly" )
    {
        # Remove the includeAds parameter since it's not relevant for deploying the automation account and log analytics workspace.
        $parameters.remove("includeAds")
        $TemplateFilePath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $SpokeAAAwithLAWTemplateFile))
        $rgDeployment = 'azureAppDeployAAAwithLAW-' + ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmm')
        New-AzResourceGroupDeployment -Name $rgDeployment `
        -ResourceGroupName $resourceGroupName `
        -TemplateFile $TemplateFilePath `
        -TemplateParameterObject $parameters `
        -Force `
        -Verbose `
        -ErrorVariable ErrorMessages
        if ($ErrorMessages)
        {
            Write-Output '', 'Template deployment returned the following errors:', @(@($ErrorMessages) | ForEach-Object { $_.Exception.Message.TrimEnd("`r`n") })
        } # end if
        else
        {
            # Deployment of App environment is successful
            $StopTimer = Get-Date -Verbose
            Write-Output "Calculating elapsed time..."
            $ExecutionTime = New-TimeSpan -Start $BeginTimer -End $StopTimer
            $Footer = "TOTAL SCRIPT EXECUTION TIME: $ExecutionTime"
            Write-Output ""
            Write-Output $Footer
        } # end else  
    }
} # end else
#endregion deploy spoke

$aaaResourceGroupName = $null

if (($DeploymentOption -eq "DeployHubWithoutFW") -or ($DeploymentOption -eq "DeployHubWithFW"))
{
    $aaaResourceGroupName = $hubResourceGroupName
    $SpokeVnetName = $parameters.regionCode + "-APP-NP-VNT-01"
    $HubVnet = Get-AzVirtualNetwork -Name $hubParameters.hubVnetName -ResourceGroupName $hubResourceGroupName -Verbose
    $SpokeVNet = Get-AzVirtualNetwork -Name $SpokeVnetName -ResourceGroupName $resourceGroupName -Verbose
    $HubtoSpokePeeringName = 'LinkTo' + $SpokeVnetName
    $SpoketoHubPeeringName = 'LinkTo' + $HubVnetName
    # Peer Hub VNet to Spoke VNet
    Add-AzVirtualNetworkPeering -Name $HubtoSpokePeeringName -VirtualNetwork $HubVnet -RemoteVirtualNetworkId $SpokeVnet.Id
    # Peer Spoke Vnet  to Hub VNet.
    Add-AzVirtualNetworkPeering -Name $SpoketoHubPeeringName -VirtualNetwork $SpokeVNet -RemoteVirtualNetworkId $HubVnet.Id
} # end condition

If ($DeploymentOption -eq "DeployHubWithoutFW")
{
    $serverName = $hubParameters.hubJumpServerName
    $userName = $serverName + "\" + $hubParameters.adminUserName
    $fqdnEndPoint = (Get-AzPublicIpAddress -ResourceGroupName $hubResourceGroupName | Where-Object { $_.Name -match $serverName}).DnsSettings.fqdn
} # end if
ElseIf ($DeploymentOption -eq "DeployHubWithFW")
{
    $serverName = $hubParameters.hubFwName
    $userName = $hubParameters.hubJumpServerName + "\" + $hubParameters.adminUserName
    $fqdnEndPoint = (Get-AzPublicIpAddress -ResourceGroupName $hubResourceGroupName | Where-Object { $_.Name -match $serverName}).DnsSettings.fqdn + ":50000"
    # Create route confiugration
    $zeroTrafficConfig = New-AzRouteConfig -Name $appRouteTableObj.zeroRoute -AddressPrefix $appRouteTableObj.zeroAddrPrefix -NextHopType $appRouteTableObj.zeroNextHopType -NextHopIpAddress $appRouteTableObj.zeroNextHopAddr -Verbose
    $hubTrafficConfig = New-AzRouteConfig -Name $appRouteTableObj.hubRoute -AddressPrefix $appRouteTableObj.hubAddrPrefix -NextHopType $appRouteTableObj.hubNextHopType -NextHopIpAddress $appRouteTableObj.hubNextHopAddr -Verbose
    $appRoutes = @($zeroTrafficConfig,$hubTrafficConfig)
    # Create route table
    $appRouteTableResource = New-AzRouteTable -ResourceGroupName $resourceGroupName -Location $regionFullName -Name $appRouteTableObj.tableName -Route $appRoutes -Force -Verbose
    # Get all subnet configurations in app vnet
    $appVnetResource = Get-AzVirtualNetwork -Name $appVnetName -ResourceGroupName $resourceGroupName
    # Assign route table to each subnet in app vnet
    Set-AzVirtualNetworkSubnetConfig -Name $appVnetResource.Subnets[0].Name -VirtualNetwork $appVnetResource -AddressPrefix $appVnetResource.Subnets[0].AddressPrefix -RouteTableId $appRouteTableResource.id -Verbose
    Set-AzVirtualNetworkSubnetConfig -Name $appVnetResource.Subnets[1].Name -VirtualNetwork $appVnetResource -AddressPrefix $appVnetResource.Subnets[1].AddressPrefix -RouteTableId $appRouteTableResource.id -Verbose
    # Apply changes and update configuration for virtual network
    $appVnetResource | Set-AzVirtualNetwork
} # end elseif
ElseIf ($DeploymentOption -eq "DeployAppOnly")
{
    $fqdnEndPoint = (Get-AzPublicIpAddress -ResourceGroupName $resourceGroupName | Where-Object {$_.Name -match $serverName}).DnsSettings.fqdn
    $aaaResourceGroupName = $resourceGroupName
} # end elseif
Else
{
    Write-Verbose $noDeploymentOptionMessage
    Exit
} # end else
#region runbooks

<#
$certPassword = (New-Guid).Guid
$ApplicationDisplayName = "ServicePrincipal-$randomInfix"

New-AutomationAccountRunAsServicePrincipal -rgName $aaaResourceGroupName `
-AutomationAccountName $AutomationAccountName `
-ApplicationDisplayName $ApplicationDisplayName `
-SubscriptionId $subscriptionId `
-SelfSignedCertPlainPassword $CertPassword `
-selfSignedCertNoOfMonthsUntilExpired 12
#>

# Assign the Automation Account Managed Identity Contributor rights over the subscription so it can startup/shutdown VM(s) and the Az Firewall
if ($DeploymentOption -ne "DeployAppOnly")
{
    $aaaResourceGroupName = $hubResourceGroupName
}

$aaaManagedIdentityID = (Get-AzAutomationAccount -ResourceGroupName $aaaResourceGroupName -Name $AutomationAccountName).Identity.PrincipalId
New-AzRoleAssignment -ObjectId $aaaManagedIdentityID -Scope "/subscriptions/$subscriptionId" -RoleDefinitionName "Contributor"
# https://docs.microsoft.com/en-us/azure/automation/learn/powershell-runbook-managed-identity

# Import runbook modules
New-AutomationAccountModules -ResourceGroupName $aaaResourceGroupName -Modules $runbookModules -AutomationAccountName $AutomationAccountName -Verbose
# Allow sufficient time for runbook modules to be imported
# import and publish runbook scripts

# Get current environment
$env = (Get-AzSubscription | Select-Object -ExpandProperty ExtendedProperties).Environment
# VM startup/shutdown runbook parameters
$startRunbookParams = @{"operation"="start";"env"=$env}
$stopRunbookParams = @{"operation"="stop";"env"=$env}

#region Start/Stop FW
<#
if ($DeploymentOption -eq "DeployHubWithFW")
{
    # https://www.jonathanmedd.net/2011/09/powershell-v3-bringing-ordered-to-your-hashtables.html
    # Azure FW startup/shutdown runbook parameters
    $commonAfwParams = [ordered]@{
        "env"=$env;
        "afwResourceGroup"=$hubResourceGroupName;
        "afwVnetName"=$hubVnetName;
        "afwName"=$hubFwName;
        "afwPipName"=$hubPublicIp.ToLower();
    } # end hashtable

    # Azure FW startup runbook parameters
    $startAfwRunbookParams = [ordered]@{
        "operation"="start";
    } # end hashtable
    $startAfwRunbookParams += $commonAfwParams

    # Azure FW shutdown runbook parameters
    $stopAfwRunbookParams = [ordered]@{
        "operation"="stop";
    } # end hashtable
    $stopAfwRunbookParams += $commonAfwParams

    $runbookScripts = (Get-ChildItem -Path $runbooksDir\* -File -Include *.ps1 | Select-Object -Property FullName).FullName

    Write-Output "Azure Firewall Startup Runbook Parameters:"
    $startAfwRunbookParams
    Write-Output ""
    Write-Output "Azure Firewall Shutdown Runbook Parameters"
    $stopAfwRunbookParams
} # end if
#>
#endregion Start/Stop FW

# https://docs.microsoft.com/en-us/powershell/module/az.accounts/connect-azaccount?view=azps-4.7.0
# https://medium.com/faun/using-azure-automation-runbooks-and-schedules-to-automatically-turn-on-off-your-vms-38bfe20a757f
# Publish-RunbookScripts -rbScripts $runbookScripts -ResourceGroupName $ResourceGroupName -Verbose
Publish-AutomationAccountRunbookScripts -rbScripts $runbookScripts -ResourceGroupName $aaaResourceGroupName -AutomationAccountName $AutomationAccountName -Verbose
# Provide instructions for logging into the dev/jump server
# Wait for 100 seconds to allow runbooks to fully publish

# Start-Sleep -Seconds $waitTimeToPublishRunbooks-Verbose
# Link startup runbooks with startup schedule
$startupRunbooks = ((Get-AzAutomationRunbook -ResourceGroupName $aaaResourceGroupName -AutomationAccountName $AutomationAccountName | Where-Object {$_.Name -match 'start'}).name)
foreach ($startupRunbook in $startupRunbooks)
{
    <#
    if ($startupRunbook -match 'AzureFirewallStart')
    {
        Register-AzAutomationScheduledRunbook -RunbookName $startupRunbook -ScheduleName $startupScheduleName -Parameters $startAfwRunbookParams -ResourceGroupName $aaaResourceGroupName -AutomationAccountName $AutomationAccountName -Verbose
    } # end if
    else
    {
    } # end else
    #>
    Register-AzAutomationScheduledRunbook -RunbookName $startupRunbook -ScheduleName $startupScheduleName -Parameters $startRunbookParams -ResourceGroupName $aaaResourceGroupName -AutomationAccountName $AutomationAccountName -Verbose
} # end foreach

# Start-Sleep -Seconds $waitTimeToPublishRunbooks -Verbose
# Link shutdown runbooks with shutdown schedules
$shutdownRunbooks = ((Get-AzAutomationRunbook -ResourceGroupName $aaaResourceGroupName -AutomationAccountName $AutomationAccountName | Where-Object {$_.Name -match 'stop'}).name)
foreach ($shutdownRunbook in $shutdownRunbooks)
{
    <#
    if ($shutdownRunbook -match 'AzureFirewallStop')
    {
        Register-AzAutomationScheduledRunbook -RunbookName $shutdownRunbook -ScheduleName $shutdownScheduleName -Parameters $stopAfwRunbookParams -ResourceGroupName $aaaResourceGroupName -AutomationAccountName $AutomationAccountName -Verbose
    } # end if
    else
    {
    } # end else
    #>
    Register-AzAutomationScheduledRunbook -RunbookName $shutdownRunbook -ScheduleName $shutdownScheduleName -Parameters $stopRunbookParams -ResourceGroupName $aaaResourceGroupName -AutomationAccountName $AutomationAccountName -Verbose
} # end foreach
#endregion runbooks

$connectionMessage = @"
To log into your new jump server: $serverName, you must change your login name to: $userName and specify the corresponding password you entered at the beginning of this script.
Specify this DNS hostname for your RDP session: $fqdnEndPoint.
"@
Write-Output $connectionMessage
# Allow engineer/administrator to pause and read connection message before continuing

# Resource group and log files cleanup messages
Write-Warning "The list of PoC resource groups are:"
Get-AzResourceGroup -Name $pocResourceGroupFilter -Verbose
Write-Output "To remove the resource groups, use the command below:"
Write-Output 'Get-AzResourceGroup -Name "*NP-RGP-01*" | ForEach-Object { Remove-AzResourceGroup -ResourceGroupName $_.ResourceGroupName -Verbose -Force }'

Write-Warning "Transcript logs are hosted in the directory: $LogDirectory to allow access for multiple users on this machine for diagnostic or auditing purposes."
Write-Warning "To examine, archive or remove old log files to recover storage space, run this command to open the log files location: Start-Process -FilePath $LogDirectory"
Write-Warning "You may change the value of the `$modulePath variable in this script, currently at: $modulePath to a common file server hosted share if you prefer, i.e. \\<server.domain.com>\<share>\<log-directory>"

} # end else PROCEED

Stop-Transcript -Verbose

# Create prompt and response objects for continuing script and opening logs.
$openTranscriptPrompt = "Would you like to open the transcript log now ? [YES/NO]"
Do
{
    $openTranscriptResponse = read-host $openTranscriptPrompt
    $openTranscriptResponse = $openTranscriptResponse.ToUpper()
} # end do
Until ($openTranscriptResponse -eq "Y" -OR $openTranscriptResponse -eq "YES" -OR $openTranscriptResponse -eq "N" -OR $openTranscriptResponse -eq "NO")

# Exit if user does not want to continue
If ($openTranscriptResponse -in 'Y', 'YES')
{
    Start-Process -FilePath notepad.exe $Transcript -Verbose
} #end condition
else
{
    # Terminate script
    Write-Output "End of Script!"
    $header.SeparatorDouble
} # end else