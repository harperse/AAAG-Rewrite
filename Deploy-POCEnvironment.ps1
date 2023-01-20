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
    [ValidateSet("PowerShellOnly", "PowerShellWithJSON", "PowerShellWithBicep")][string] $TemplateLanguage = "PowerShellOnly",
    [Parameter(Mandatory = $false)][string]$TenantId = "16b3c013-d300-468d-ac64-7eda0820b6d3",
    [Parameter(Mandatory = $false)][string]$SubscriptionId = "ee9312f3-798c-4110-8c32-2cf6ce086f6f",
    [Parameter(Mandatory = $false)][bool]$SkipModuleInstall = $false
)

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
    $form.Size = New-Object System.Drawing.Size(300, 200)
    $form.StartPosition = 'CenterScreen'

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(75, 120)
    $okButton.Size = New-Object System.Drawing.Size(75, 23)
    $okButton.Text = 'OK'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(150, 120)
    $cancelButton.Size = New-Object System.Drawing.Size(75, 23)
    $cancelButton.Text = 'Cancel'
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10, 20)
    $label.Size = New-Object System.Drawing.Size(280, 20)
    $label.Text = $labelText
    $form.Controls.Add($label)

    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Location = New-Object System.Drawing.Point(10, 40)
    $textBox.Size = New-Object System.Drawing.Size(260, 20)
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
    Clear-AzContext -Force -Verbose
    Connect-AzAccount -Environment $AzureEnvironment -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -OutVariable connectionResult
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

[hashtable]$hubResources = @{}
[hashtable]$spokeResources = @{}

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

# Handling verbose switch
#$VerbosePreference = "Continue"

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
Write-Output "Listing all Azure locations"
Write-Output $global:regionCodes.Keys | Sort-Object

Switch ($AzureEnvironment) {
    "AzureCloud" { 
        switch ($DeploymentOption) {
            { ($_ -eq "DeployHubWithFW") -or ($_ -eq "DeployHubWithoutFW") } {
                #Do { $azHubLocation = Read-Host "Please type or copy/paste the location for the hub of the hub/spoke model" }
                $azHubLocation = New-TextBox -formText "Hub Location" -labelText "Please type or copy/paste the location for the hub of the hub/spoke model"
                if ($azHubLocation -notin $global:regionCodes.Keys) {
                    Write-Output "The location you entered is not valid. Please try again."
                    exit
                }
                $azSpokeLocation = New-TextBox -formText "Spoke Location" -labelText "Please type or copy/paste the location for the spoke of the hub/spoke model"
                if ($azSpokeLocation -notin $global:regionCodes.Keys) {
                    Write-Output "The location you entered is not valid. Please try again."
                    exit
                }
        
                $selectedHubRegionCode = $global:regionCodes[$azHubLocation]
                $selectedSpokeRegionCode = $global:regionCodes[$azSpokeLocation]
            } 
        
            "DeployAppOnly" {
                Do { $azAppLocation = Read-Host "Please type or copy/paste the location for the application deployment" }
                Until ($azAppLocation -in $global:regionCodes.Keys)
        
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

#$vmAdminPassword = Read-Host "Please enter the password for the VMs in the deployment" -AsSecureString
$global:credential = [pscredential]::new($globalProperties.vmAdminUserName, $(Read-Host "Please enter the password for the VMs in the deployment" -AsSecureString))

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
        $installedVersion = $(Get-Package -Name $requiredModule -ProviderName PowerShellGet -ErrorAction SilentlyContinue).Version.ToString() 
        $currentVersion = $(Find-Package -Name $requiredModule -ProviderName PowerShellGet).Version.ToString()
        if (($currentVersion -gt $installedVersion) -or ($null -eq $installedVersion)) {
            Write-Output "Upgrading $requiredModule to version $currentVersion"
            Install-Package -Name $requiredModule -Source "PSGallery" -ProviderName PowerShellGet -Type Module -Scope CurrentUser -AllowClobber -InstallUpdate -Force
        }
    }
    #END Installing/upgrading/checking Az modules

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
}
else {
    ### Validate the required modules are at least installed, EXIT if not
}

# Importing the Az modules
Write-Output "Importing the Az modules..."
Write-Output "Expected runtime: 45 seconds"
Import-Module Az -Force -Verbose:$false

# Determine the latest VM image version
$imageVersion = Get-AzVMImage -Location $selectedHubRegionCode -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2022-datacenter-azure-edition-smalldisk" | Select-Object -ExpandProperty Version | ForEach-Object { $PSItem.Split(".")[1] -as [int] } | Sort-Object -Descending | Select-Object -First 1
$selectedVersion = Get-AzVMImage -Location $selectedHubRegionCode -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2022-datacenter-azure-edition-smalldisk" | Where-Object { $PSItem.Version -like "*$imageVersion*" } | Select-Object -ExpandProperty Version

# Import the configuration data
. .\Deploy-POCEnvironmentData.ps1

switch ($TemplateLanguage) {
    "PowerShellOnly" {
        .\devPowerShell\New-POCAzDeployment.ps1
        # Fetch raw files from Github, copy to \DeploymentFiles and launch deployment script
    }
    "PowerShellWithJSON" {}
    "PowerShellWithBicep" {}
}

#endregion MainProcessing

#region PostExecutionHandling

Stop-Transcript

#endregion PostExecutionHandling