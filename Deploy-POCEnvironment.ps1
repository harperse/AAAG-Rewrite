#requires -version 5.1
#requires -RunAsAdministrator

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
    The script 'Deploy-POCEnvironment.ps1' cannot be run because the following modules that are specified by the "#requires" statements of the script are missing: Az.
    At line:0 char:0
To resolve, please run the following command to import the Az modules into your current session.
Import-Module -Name Az -Verbose

2. Before executing this script, ensure that you change the directory to the directory where the script is located. For example, if the script is in: c:\poc-package-#.#.#\Deploy-POCEnvironment.ps1 
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
.\Deploy-POCEnvironment.ps1 -ValidateOnly -skipModules -Verbose

.EXAMPLE
[Deploy infrastrcture]
From the current directory in which this script is located, execute using the following command or execute from a PowerShell host (VSCode, Visual Studio 2017/2019, PowerShell ISE, etc.)
. .\Deploy-POCEnvironment.ps1 -Verbose

.EXAMPLE
[WITH THE -DeploymentOption parameter]
Please run the script using one of these values for the -DeploymentOption parameter, i.e.
NOTE: If this parameter isn't specified, the default value DeployAppOnly will be used to deploy just the App network.
\Deploy-POCEnvironment.ps1 -DeploymentOption DeployAppOnly (Default)

.EXAMPLE
. .\Deploy-POCEnvironment.ps1 -DeploymentOption DeployHubWithoutFW -Verbose

.EXAMPLE
. .\Deploy-POCEnvironment.ps1 -DeploymentOption DeployHubWithFW -Verbose

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
4. Sean Harper

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
10. https://docs.microsoft.com/en-us/azure/azure-government/documentation-government-get-started-connect-with-ps
11. https://azure.microsoft.com/en-us/updates/global-vnet-peering-available-in-azure-government/
12. https://docs.microsoft.com/en-us/azure/azure-monitor/insights/service-map-configure
13. https://www.clearpeople.com/insights/blog/2017/april/automation-account-schedules-with-time-zones
        # https://azure.microsoft.com/en-us/global-infrastructure/regions/
        # http://map.buildazure.com/
        # https://azurespeedtest.azurewebsites.net/
        # https://devblogs.microsoft.com/scripting/powertip-identify-regions-in-azure/
        # https://stackoverflow.com/questions/66341090/facing-issues-on-deploying-template-for-azure-file-share-storage-account


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

[CmdletBinding()]
Param (
    [ValidateSet("AzureCloud", "AzureUSGovernment")][string] $AzureEnvironment = "AzureCloud",
    [ValidateSet("DeployAppOnly", "DeployHubWithoutFW", "DeployHubWithFW")][string] $DeploymentOption = "DeployAppOnly",
    [ValidateSet("PowerShellOnly", "PowerShellWithJSON", "PowerShellWithBicep")][string] $TemplateLanguage = "PowerShellOnly",
    [switch]$skipModules
    #[switch]$ValidateOnly
)

#region DefaultHashtables

$hubResources = @{}
$spokeResources = @{}

$global:regionCodes = @{
    #Africa
    southafricanorth   = CZNSA
    southafricawest    = CZWSA
    #AsiaPacific
    australiacentral   = CZAU1
    australiacentral2  = CZAU2
    centralindia       = CZCIN
    eastasia           = CZEAS
    australiaeast      = CZEAU
    japaneast          = CZEJP
    jioindiacentral    = CZJIC
    jioindiawest       = CZJIW
    koreacentral       = CZKRC
    koreasouth         = CZKRS
    qatarcentral       = CZQAC
    australiasoutheast = CZSAU
    southeastasia      = CZSEA
    southindia         = CZSIN
    uaecentral         = CZUAC
    uaenorth           = CZUAN
    westindia          = CZWIN
    japanwest          = CZWJP
    #Europe
    francecentral      = CZFRC
    francesouth        = CZFRS
    germanynorth       = CZGRN
    germanywestcentral = CZGWC
    northeurope        = CZNEU
    norwayeast         = CZNWE
    norwaywest         = CZNWW
    uksouth            = CZSUK
    swedencentral      = CZSWC
    switzerlandnorth   = CZSWN
    switzerlandwest    = CZSWW
    westeurope         = CZWEU
    ukwest             = CZWUK
    #NorthAmerica
    canadacentral      = CZCCA
    centralus          = CZCUS
    canadaeast         = CZECA
    eastus             = CZEU1
    eastus2            = CZEU2
    northcentralus     = CZCUN
    southcentralus     = CZSCU
    westcentralus      = CZWCU
    westus             = CZWU1
    westus2            = CZWU2
    westus3            = CZWU3
    #SouthAmerica
    brazilsouth        = CZSBR
    brazilsoutheast    = CZBSE
    #USGOV
    usgovvirginia      = USGVA
    usgovtexas         = USGTX
}  #end hashtable; updated 1/17/2023

#endregion DefaultHashtables

#region PreExecutionHandling

# Handling verbose switch
$VerbosePreference = "Continue"

#BEGIN Creating transcript log directory and transcript files 
$startTimeStamp = Get-Date
$startTimeStampAsString = [string]$startTimeStamp.GetDateTimeFormats([char]"s").Replace(":", "-")
New-Item -Path .\TranscriptLogs -ItemType Directory | Out-Null
Start-Transcript -Path ".\TranscriptLogs\POCEnvironment-$startTimeStampAsString.log"
#END Creating transcript log directory and transcript files

Write-Output "Started script: $StartTimeStamp"
Write-Output "Setting the PSGallery as a trusted repository for module download and installation (if needed)"
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted -Verbose
Write-Output "Configuring security protocol to use TLS 1.2 for Nuget support when installing modules."
[ServicePointManager]::SecurityProtocol = [SecurityProtocolType]::Tls12
#endregion PreExecutionHandling

#region MainProcessing
# Importing the Az modules
Import-Module Az -Verbose -Force

Write-Output "Please see the open dialogue box in your browser to authenticate to your Azure subscription..."
Clear-AzContext -Force -Verbose

Connect-AzAccount -Environment $AzureEnvironment
# Pre-loading list of Azure locations
# Also stripping out "extended", staging, logical, and EUAP locations 
#$azLocations = $(Get-AzLocation | Where-Object { $_.RegionType -eq "Physical" }).Location |  Where-Object { $_ -notlike "*stage" } | Where-Object { $_ -notlike "*euap" } | Where-Object { $_ -notlike "*stg" } | Sort-Object
Write-Output "Listing all Azure locations"
Write-Output $azLocations

Switch ($AzureEnvironment) {
    "AzureCloud" { 
        switch ($DeploymentOption) {
            { $_ -eq ("DeployHubWithFW" -or "DeployHubWithoutFW") } {
                Do { $azHubLocation = Read-Host "Please type or copy/paste the location for the hub of the hub/spoke model" }
                Until ($azHubLocation -in $global:regionCodes.Keys)
        
                Do { $azSpokeLocation = Read-Host "Please type or copy/paste the location for the spoke of the hub/spoke model" }
                Until ($azSpokeLocation -in $global:regionCodes.Keys)
        
                $selectedHubRegionCode = $global:regionCodes.GetEnumerator() | Where-Object { $_.Value -eq $azHubLocation }
                $selectedSpokeRegionCode = $global:regionCodes.GetEnumerator() | Where-Object { $_.Value -eq $azSpokeLocation }

                $subscription = Select-AzSubscriptionFromList
                Select-AzSubscription -Subscription $(Get-AzSubscription | Where-Object { $_.Name -eq $subscription }) -Verbose
            } 
        
            "DeployAppOnly" {
                Do { $azAppLocation = Read-Host "Please type or copy/paste the location for the application deployment" }
                Until ($azAppLocation -in $global:regionCodes.Keys)
        
                $selectedHubRegionCode = $null
                $selectedSpokeRegionCode = $global:regionCodes.GetEnumerator() | Where-Object { $_.Value -eq $azAppLocation }
                $subscription = Select-AzSubscriptionFromList
                Select-AzSubscription -Subscription $(Get-AzSubscription | Where-Object { $_.Name -eq $subscription }) -Verbose
            }
        }
    }
    "AzureUSGovernment" { 
        Connect-AzAccount -Environment AzureUSGovernment 
        If (!($DeploymentOption -eq "DeployAppOnly")) {
            $selectedHubRegionCode = $global:regionCodes.GetEnumerator() | Where-Object { $_.Value -eq "USGTX" }
            $selectedSpokeRegionCode = $global:regionCodes.GetEnumerator() | Where-Object { $_.Value -eq "USGVA" }
        }
        else {
            $selectedHubRegionCode = $null
            $selectedSpokeRegionCode = $global:regionCodes.GetEnumerator() | Where-Object { $_.Value -eq "USGTX" }
        }
        $subscription = Select-AzSubscriptionFromList
        Select-AzSubscription -Subscription $(Get-AzSubscription | Where-Object { $_.Name -eq $subscription }) -Verbose
    }
} # end switch

switch ($TemplateLanguage) {
    "PowerShellOnly" {
        # Fetch raw files from Github, copy to \DeploymentFiles and launch deployment script
    }
    "PowerShellWithJSON" {}
    "PowerShellWithBicep" {}
}

$global:vmAdminPassword = Read-Host "Please enter the password for the VMs in the deployment" -AsSecureString

if (!($skipModules)) {
    Write-Output "Checking for installed and proper versions of required modules"
    #BEGIN Installing/upgrading/checking Nuget package provider
    $installedNugetVersion = $(Get-PackageProvider -Name Nuget -ErrorAction SilentlyContinue).Version.ToString()
    $currentNugetVersion = $(Find-PackageProvider -Name Nuget).Version.ToString()
    if (($currentNugetVersion -gt $installedNugetVersion) -or ($null -eq $installedNugetVersion)) {
        Write-Output "Upgrading Nuget Version to $currentNugetVersion"
        #Install-PackageProvider -Name Nuget -ForceBootstrap -Force -Verbose -RequiredVersion $currentNugetVersion.ToString()
    }
    #END Installing/upgrading Nuget package provider

    #BEGIN Installing/upgrading/checking required modules
    foreach ($requiredModule in $requiredModules) {
        $installedVersion = $(Get-Module -Name $requiredModule -ListAvailable -ErrorAction SilentlyContinue).Version.ToString() 
        $currentVersion = $(Find-Module -Name $requiredModule).Version.ToString()
        if (($currentVersion -gt $installedVersion) -or ($null -eq $installedVersion)) {
            Write-Output "Upgrading $requiredModule to version $currentVersion"
            Install-Module -Name $requiredModule -Repository "PSGallery" -Scope CurrentUser -AllowClobber -Force
        }
    }
    #END Installing/upgrading/checking Az modules
}

# Import the configuration data
. .\Deploy-POCEnvironmentData.ps1

#endregion MainProcessing

#region PostExecutionHandling

Stop-Transcript

#endregion PostExecutionHandling