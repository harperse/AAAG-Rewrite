#requires -version 7.0
<#
#requires -RunAsAdministrator
#> 

# For IPAddress class
Using Namespace System.Net
# For Azure AD service principals marshal clas
Using Namespace System.Runtime.InteropServices
# For the PSStorageAccount Class: https://docs.microsoft.com/en-us/dotnet/api/microsoft.azure.commands.management.storage.models.psstorageaccount?view=azurerm-ps
Using Namespace Microsoft.Azure.Commands.Management.Storage.Models
Using Namespace Microsoft.Azure.Commands.Network.Models

[CmdletBinding()]
Param (
    #[Parameter(Mandatory = $true)]
    [ValidateSet("AzureCloud", "AzureUSGovernment")][string] $AzureEnvironment = "AzureCloud",
    #[Parameter(Mandatory = $true)]
    [ValidateSet("DeployAppOnly", "DeployHubWithoutFW", "DeployHubWithFW")][string] $DeploymentOption = "DeployHubWithoutFW",
    #[Parameter(Mandatory = $true)]
    [ValidateSet("PowerShellOnly", "PowerShellWithJSON", "PowerShellWithBicep", "AzCLI", "Terraform")][string] $TemplateLanguage = "PowerShellOnly",
    #[Parameter(Mandatory = $false)][string]$TenantId = "16b3c013-d300-468d-ac64-7eda0820b6d3",
    #[Parameter(Mandatory = $false)][string]$SubscriptionId = "ee9312f3-798c-4110-8c32-2cf6ce086f6f",
    [Parameter(Mandatory = $false)][string]$hubLocation = "eastus",
    [Parameter(Mandatory = $false)][string]$spokeLocation = "eastus2",
    [Parameter(Mandatory = $false)][bool]$SkipModuleInstall = $false
)

if ($PSScriptRoot -ne $pwd) {
    Write-Warning "This script must be run from the directory it is located in. Changing directories."
    Push-Location $($MyInvocation.MyCommand.Path | Split-Path -Parent)
}

[string[]]$global:requiredModules = @("Az", "Az.MonitoringSolutions", "AzureAutomation", "xActiveDirectory", "xComputerManagement", "xStorage", "xNetworking", "xSmbShare", "PSDesiredStateConfiguration")

#region Functions

function New-TextBox {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string]$formText,
        [Parameter(Mandatory = $true)][string]$labelText
    )
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $form = New-Object System.Windows.Forms.Form
    $form.Text = $formText
    $form.Size = New-Object System.Drawing.Size(500, 200)
    $form.StartPosition = 'CenterScreen'

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(175, 120)
    $okButton.Size = New-Object System.Drawing.Size(75, 23)
    $okButton.Text = 'OK'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(250, 120)
    $cancelButton.Size = New-Object System.Drawing.Size(75, 23)
    $cancelButton.Text = 'Cancel'
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10, 20)
    $label.Size = New-Object System.Drawing.Size(480, 20)
    $label.Text = $labelText
    $form.Controls.Add($label)

    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Location = New-Object System.Drawing.Point(10, 40)
    $textBox.Size = New-Object System.Drawing.Size(460, 20)
    $form.Controls.Add($textBox)

    $form.Topmost = $true

    $form.Add_Shown({ $textBox.Select() })
    $result = $form.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        return $textBox.Text
    }
    else { exit }
}

function Set-AzDefaultInformation {
    #Clear-AzContext -Force -Verbose
    Connect-AzAccount -Environment $AzureEnvironment -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -OutVariable connectionResult
    ### NEED AN IF STATEMENT HERE
    $selectedTenantId = $connectionResult.Context.Tenant.Id
    Write-Output $(Get-AzSubscription -TenantId $selectedTenantId | Select-Object -Property Name, Id)
    $selectedSubscription = New-TextBox -formText "Subscription Information" -labelText "Please enter the subscription name or ID you want to use for the hub deployment"
    switch ($selectedSubscription) {
        { $_ -match "[\da-zA-Z]{8}-([\da-zA-Z]{4}-){3}[\da-zA-Z]{12}" } {
            Select-AzSubscription -Subscription $(Get-AzSubscription | Where-Object { $_.Id -eq $selectedSubscription }) -Verbose
        }
        { $_ -is [string] } {
            Select-AzSubscription -Subscription $(Get-AzSubscription | Where-Object { $_.Name -eq $selectedSubscription }) -Verbose
        }
    }
    Update-AzConfig -DefaultSubscriptionForLogin $selectedSubscription -Verbose -Scope CurrentUser -DisplayBreakingChangeWarning $true -EnableDataCollection $false
}

#region DefaultHashtables

[hashtable]$global:hubResources = @{}
[hashtable]$global:spokeResources = @{}

[hashtable]$global:regionCodes = @{
    #Africa
    southafricanorth   = "CZNSA"
    southafricawest    = "CZWSA"
    #AsiaPacific
    australiacentral   = "CZAU1"
    australiacentral2  = "CZAU2"
    centralindia       = "CZCIN"
    eastasia           = "CZEAS"
    australiaeast      = "CZEAU"
    japaneast          = "CZEJP"
    jioindiacentral    = "CZJIC"
    jioindiawest       = "CZJIW"
    koreacentral       = "CZKRC"
    koreasouth         = "CZKRS"
    qatarcentral       = "CZQAC"
    australiasoutheast = "CZSAU"
    southeastasia      = "CZSEA"
    southindia         = "CZSIN"
    uaecentral         = "CZUAC"
    uaenorth           = "CZUAN"
    westindia          = "CZWIN"
    japanwest          = "CZWJP"
    #Europe
    francecentral      = "CZFRC"
    francesouth        = "CZFRS"
    germanynorth       = "CZGRN"
    germanywestcentral = "CZGWC"
    northeurope        = "CZNEU"
    norwayeast         = "CZNWE"
    norwaywest         = "CZNWW"
    uksouth            = "CZSUK"
    swedencentral      = "CZSWC"
    switzerlandnorth   = "CZSWN"
    switzerlandwest    = "CZSWW"
    westeurope         = "CZWEU"
    ukwest             = "CZWUK"
    #NorthAmerica
    canadacentral      = "CZCCA"
    centralus          = "CZCUS"
    canadaeast         = "CZECA"
    eastus             = "CZEU1"
    eastus2            = "CZEU2"
    northcentralus     = "CZCUN"
    southcentralus     = "CZSCU"
    westcentralus      = "CZWCU"
    westus             = "CZWU1"
    westus2            = "CZWU2"
    westus3            = "CZWU3"
    #SouthAmerica
    brazilsouth        = "CZSBR"
    brazilsoutheast    = "CZBSE"
    #USGOV
    usgovvirginia      = "USGVA"
    usgovtexas         = "USGTX"
}  #end hashtable; updated 1/17/2023

#endregion DefaultHashtables

#region PreExecutionHandling

# Clearing the screen
Clear-Host

# Handling verbose switch
#$VerbosePreference = "Continue"

# Clearing error record
$Error.Clear()

#BEGIN Creating transcript log directory and transcript files 
$startTimeStamp = Get-Date
$startTimeStampAsString = [string]$startTimeStamp.GetDateTimeFormats([char]"s").Replace(":", "-")
if (!(Test-Path -Path ".\TranscriptLogs")) {
    New-Item -Path .\TranscriptLogs -ItemType Directory | Out-Null
}
Start-Transcript -Path ".\TranscriptLogs\POCEnvironment-$startTimeStampAsString.log"
Write-Output "Started script: $StartTimeStamp"
#END Creating transcript log directory and transcript files
#endregion PreExecutionHandling

#region MainProcessing
Write-Output "Please see the open dialogue box in your browser to authenticate to your Azure subscription..."
Set-AzDefaultInformation

# Pre-loading list of Azure locations
if (!($hubLocation -or $spokeLocation)) {
    Write-Output "Listing all Azure locations"
    Write-Output $global:regionCodes.Keys | Sort-Object
}

Switch ($AzureEnvironment) {
    "AzureCloud" { 
        switch ($DeploymentOption) {
            { ($_ -eq "DeployHubWithFW") -or ($_ -eq "DeployHubWithoutFW") } {
                # Getting hub location
                if (!($hubLocation)) {
                    $azHubLocation = New-TextBox -formText "Hub Location" -labelText "Please type or copy/paste the location for the hub of the hub/spoke model"
                } 
                else {
                    $azHubLocation = $hubLocation
                }

                # Validating hub location
                if ($azHubLocation -notin $global:regionCodes.Keys) {
                    Write-Output "The location you entered is not valid. Please try again."
                    exit
                }

                # Getting spoke location
                if (!($spokeLocation)) {
                    $azSpokeLocation = New-TextBox -formText "Spoke Location" -labelText "Please type or copy/paste the location for the spoke of the hub/spoke model"
                } 
                else {
                    $azSpokeLocation = $spokeLocation
                }

                # Validating spoke location
                if ($azSpokeLocation -notin $global:regionCodes.Keys) {
                    Write-Output "The location you entered is not valid. Please try again."
                    exit
                }

                #Making sure the hub and spoke locations are not the same
                if ($azHubLocation -eq $azSpokeLocation) {
                    Write-Output "The hub and spoke locations cannot be the same. Please try again."
                    exit
                }
        
                $global:selectedHubRegionCode = $global:regionCodes[$azHubLocation]
                $global:selectedSpokeRegionCode = $global:regionCodes[$azSpokeLocation]
            } 
        
            "DeployAppOnly" {
                if (!($spokeLocation)) {
                    $azSpokeLocation = New-TextBox -formText "Spoke Location" -labelText "Please type or copy/paste the location for the spoke of the hub/spoke model"
                } 
                else {
                    $azSpokeLocation = $spokeLocation
                }

                # Validating spoke location
                if ($azSpokeLocation -notin $global:regionCodes.Keys) {
                    Write-Output "The location you entered is not valid. Please try again."
                    exit
                }
        
                $selectedHubRegionCode = $null
                $selectedSpokeRegionCode = $global:regionCodes[$azSpokeLocation]
            }
        }
    }
    "AzureUSGovernment" { 
        If ($DeploymentOption -ne "DeployAppOnly") {
            $selectedHubRegionCode = $global:regionCodes.GetEnumerator() | Where-Object { $_.Value -eq "USGTX" }
            $selectedSpokeRegionCode = $global:regionCodes.GetEnumerator() | Where-Object { $_.Value -eq "USGVA" }
        }
        else {
            $selectedHubRegionCode = $null
            $selectedSpokeRegionCode = $global:regionCodes.GetEnumerator() | Where-Object { $_.Value -eq "USGTX" }
        }
    }
} # end switch

$vmAdminUserName = "adm.infra.user"
$vmAdminPassword = Read-Host "Please enter the password for the VMs in the deployment"
if ($vmAdminPassword -match "^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[a-zA-Z]).{12,}$") {
    $vmAdminPassword = $vmAdminPassword | ConvertTo-SecureString -AsPlainText -Force
}
else {
    Write-Output "The password you entered does not meet the complexity requirements. Please try again."
    exit
}
$global:credential = [pscredential]::new($vmAdminUserName, $vmAdminPassword)

if (!($skipModuleInstall)) {
    Write-Output "Setting the PSGallery as a trusted repository for module download and installation (if needed)"
    Set-PackageSource -Name "PSGallery" -Trusted -Verbose
    Write-Output "Configuring security protocol to use TLS 1.2 for PowerShellGet support when installing modules."
    [ServicePointManager]::SecurityProtocol = [SecurityProtocolType]::Tls12
    Write-Output "Checking for installed and proper versions of required modules"
    #BEGIN Installing/upgrading/checking PowerShellGet package provider
    $installedPSGetVersion = $(Get-PackageProvider -Name PowerShellGet -ErrorAction SilentlyContinue).Version.ToString()
    $currentPSGetVersion = $(Find-PackageProvider -Name PowerShellGet).Version.ToString()
    if (($currentPSGetVersion -gt $installedPSGetVersion) -or ($null -eq $installedPSGetVersion)) {
        Write-Output "Upgrading PowerShellGet Version to $currentPSGetVersion"
        Install-PackageProvider -Name PowerShellGet -ForceBootstrap -Force -Verbose -RequiredVersion $currentPSGetVersion.ToString()
    }
    #END Installing/upgrading PowerShellGet package provider

    #BEGIN Installing/upgrading/checking required Az modules
    foreach ($requiredModule in $requiredModules) {
        $installedVersion = $(Get-Module -Name $requiredModule -ListAvailable -ErrorAction SilentlyContinue).Version.ToString() 
        $currentVersion = $(Find-Package -Name $requiredModule -ProviderName PowerShellGet).Version.ToString()
        if (($currentVersion -gt $installedVersion) -or ($null -eq $installedVersion)) {
            Write-Output "Upgrading $requiredModule to version $currentVersion"
            Install-Package -Name $requiredModule -Source "PSGallery" -ProviderName PowerShellGet -Type Module -Scope CurrentUser -AllowClobber -InstallUpdate -Force
        }
    }
    #END Installing/upgrading/checking Az modules

    <#
    #BEGIN Installing/upgrading required DSC resources
    foreach ($requiredDSCResource in $requiredDSCResources) {
        $installedDSCResourceVersion = $(Get-Package -Name $requiredDSCResource -ErrorAction SilentlyContinue).Version.ToString()
        $currentDSCResourceVersion = $(Find-Package -Name $requiredDSCResource).Version.ToString()
        if (($currentDSCResourceVersion -gt $installedDSCResourceVersion) -or ($null -eq $installedDSCResourceVersion)) {
            Write-Output "Upgrading $requiredDSCResource to version $currentDSCResourceVersion"
            Install-Package -Name $requiredDSCResource -Source "PSGallery" -ProviderName PowerShellGet -Type Module -Scope CurrentUser -AllowClobber -InstallUpdate -Force
            Import-DscResource -ModuleName $requiredDSCResource
        }
    }
    #END Installing/upgrading required DSC resources
    #>
}
else {
    ### Validate the required modules are at least installed, EXIT if not
}

# Importing the Az modules
Write-Output "Importing the Az modules..."
Write-Output "Expected runtime: 45 seconds"
Import-Module Az.Accounts -Force -MinimumVersion 2.11.1 -Verbose:$false
#Import-Module Az -Force -Verbose:$false

# Determine the latest VM image version
[string]$global:imageVersion = Get-AzVMImage -Location $azSpokeLocation -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2022-datacenter-azure-edition-smalldisk" | Select-Object -ExpandProperty Version | ForEach-Object { $PSItem.Split(".")[1] -as [int] } | Sort-Object -Descending | Select-Object -First 1
[string]$global:selectedVersion = Get-AzVMImage -Location $azSpokeLocation -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2022-datacenter-azure-edition-smalldisk" | Where-Object { $PSItem.Version -like "*$imageVersion*" } | Select-Object -ExpandProperty Version

# Import the configuration data
. .\Deploy-POCEnvironmentData.ps1

switch ($TemplateLanguage) {
    "PowerShellOnly" {
        # Fetch raw files from Github, copy to \DeploymentFiles and launch deployment script
        if ($DeploymentOption -eq "DeployAppOnly") {
            Write-Output "Deploying the spoke resources only"
            .\devPowerShell\New-POCAzDeployment.ps1 -HubOrSpoke "Spoke"
        }
        else {
            Write-Output "Deploying the hub and spoke resources"
            .\devPowerShell\New-POCAzDeployment.ps1 -HubOrSpoke "hub"
        }
    }
    "PowerShellWithJSON" {
        .\devJSON\New-POCAzParametersFile.ps1
        # Fetch raw files from Github, copy to \DeploymentFiles and launch deployment script
        Write-Output "Deploying the spoke resources"
        New-AzResourceGroupDeployment -ResourceGroupName $global:spokeResources.ResourceGroup.Name -TemplateFile .\DeploymentFiles\azureDeploy.json -TemplateParameterFile .\DeploymentFiles\azureDeploy.parameters.json -Verbose
        if ($DeploymentOption -eq "DeployHubwithoutFW") {
            Write-Output "Deploying the hub resources"
            New-AzResourceGroupDeployment -ResourceGroupName $global:hubResources.ResourceGroup.Name -TemplateFile .\DeploymentFiles\azureDeployHubWithoutFW.json -TemplateParameterFile .\DeploymentFiles\azureDeployHubWithoutFW.parameters.json -Verbose
        }
        elseif ($DeploymentOption -eq "DeployHubwithFW") {
            Write-Output "Deploying the hub resources"
            New-AzResourceGroupDeployment -ResourceGroupName $global:hubResources.ResourceGroup.Name -TemplateFile .\DeploymentFiles\azureDeployHubWithFW.json -TemplateParameterFile .\DeploymentFiles\azureDeployHubWithFW.parameters.json -Verbose
        }
        else {
            Write-Output "Unable to deploy resources"
            exit
        }
    }
    "PowerShellWithBicep" {
        .\devJSON\New-POCAzParametersFile.ps1
        # Fetch raw files from Github, copy to \DeploymentFiles and launch deployment script
        Write-Output "Deploying the spoke resources"
        New-AzResourceGroupDeployment -ResourceGroupName $global:spokeResources.ResourceGroup.Name -TemplateFile .\DeploymentFiles\azureDeploy.bicep -TemplateParameterFile .\DeploymentFiles\azureDeploy.parameters.json -Verbose
        if ($DeploymentOption -eq "DeployHubwithoutFW") {
            Write-Output "Deploying the hub resources"
            New-AzResourceGroupDeployment -ResourceGroupName $global:hubResources.ResourceGroup.Name -TemplateFile .\DeploymentFiles\azureDeployHubWithoutFW.bicep -TemplateParameterFile .\DeploymentFiles\azureDeployHubWithoutFW.parameters.json -Verbose
        }
        elseif ($DeploymentOption -eq "DeployHubwithFW") {
            Write-Output "Deploying the hub resources"
            New-AzResourceGroupDeployment -ResourceGroupName $global:hubResources.ResourceGroup.Name -TemplateFile .\DeploymentFiles\azureDeployHubWithFW.bicep -TemplateParameterFile .\DeploymentFiles\azureDeployHubWithFW.parameters.json -Verbose
        }
        else {
            Write-Output "Unable to deploy resources"
            exit
        }

    }
}

#endregion MainProcessing

#region PostExecutionHandling

Stop-Transcript

#endregion PostExecutionHandling