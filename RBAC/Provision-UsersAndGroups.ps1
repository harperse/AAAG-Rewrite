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
Provisions Azure AD user accounts and groups, as well as create subscription RBAC role assignments.

.DESCRIPTION
This script creates a set of users and groups that are defined in the users-and-groups.csv file, and also creates RBAC role assignments for those users and groups, except for the directory level (Azure AD directory)
role assignments for Global Administrator and User Administrator; These role assignments must be created manually. This script also automates the creation and role assignment of a custom Role: Contoso Azure VM Operator.


PRE-REQUISITES:

1. If you already have the Az modules installed, you may still encounter the following error:
    The script 'Provision-UsersAndGroups' cannot be run because the following modules that are specified by the "#requires" statements of the script are missing: Az.
    At line:0 char:0
To resolve, please run the following command to import the Az modules into your current session.
Import-Module -Name Az -Verbose

2. Before executing this script, ensure that you change the directory to the directory where the script is located. For example, if the script is in: c:\PoCPackage\SampleIaaS\RBAC\Provision-UsersAndGroups.ps1 then
    change to this directory using the following command:
    Set-Location -Path c:\PoCPackage\SampleIaaS\RBAC

.PARAMETER AzureEnvironment
Select the azure environment for this solution from the following options: AzureCloud, AzureUSGovernment
AzureCloud: [Default] The solution will be deployed to the Azure Commercial cloud environment
AzureUSGovernment: The solution will be deployed to the Azure US Government cloud environment

.PARAMETER PSModuleRepository
Online module repository for downloading required PowerShell modules.

.PARAMETER label
Header title for script.

.PARAMETER headerCharCount
Horizontal character length of header separators

.PARAMETER pathToAzureAdUsersFile
This is the relative path (relative to this script), to the file where the consolidated users and groups information is stored.

.PARAMETER azUsers
This is the array of user objects imported from the user information file located at $pathToAzureAdUsersFile.

.EXAMPLE
. .\Provision-UsersAndGroups.ps1 -AzureEnvironment AzureUSGovernment -Verbose
Provisions users and groups into the AzureUSGovernment cloud

.EXAMPLE
. .\Provision-UsersAndGroups.ps1 -Verbose
Provisions users and groups into the [default] AzureCloud (commercial public cloud)

.EXAMPLE
. .\Provision-UsersAndGroups.ps1 -reset -Verbose
Removes all previously provisioned users, groups, and custom role assignments to reset the tenant to it's original state. This switch can also be used when testing.

.INPUTS
See .PARAMETER pathToAzureAdUsersFile

.OUTPUTS
The outputs generated from this script includes:
1. A transcript log file to provide the full details of script execution. It will use the name format: <ScriptName>-TRANSCRIPT-<Date-Time>.log

.NOTES

CONTRIBUTORS
1. Preston K. Parsard

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
1. https://docs.microsoft.com/en-us/powershell/module/az.resources/remove-azroleassignment?view=azps-6.2.1#syntax

.COMPONENT
Azure Infrastructure, PowerShell, AzureAD

.ROLE
Automation Engineer
DevOps Engineer
Azure Engineer
Azure Administrator
Azure Architect

.FUNCTIONALITY
Provisions Azure AD Users, Groups and creates role assignments.

#>

[CmdletBinding()]
Param
(
    # index 0.0: Select Azure cloud environment
    [ValidateSet("AzureCloud","AzureUSGovernment")]
    [string] $AzureEnvironment = "AzureCloud",
    [string] $PSModuleRepository = "PSGallery",
    # Title for transcipt header
    [string]$label = "PROVISION AZURE AD USERS AND GROUPS PLUS ROLE ASSIGNMENTS FOR THE ACTIVATE AZURE WITH ADMINISTRATION AND GOVERNANCE OFFERING",
    # Separator width in number of characters for transcript header/footer
    [int]$headerCharCount = 200,
    [string]$pathToAzureAdUsersFile = ".\users-and-groups.csv",
    [array]$azUsers = (Import-Csv -path $pathToAzureAdUsersFile),
    [string]$defaultSubId = "11111111-1111-1111-1111-111111111111",
    [string]$subIdPattern = '\w{8}-\w{4}-\w{4}-\w{4}-\w{12}',
    [switch]$reset
) # end param

$ErrorActionPreference = 'Continue'
# Set-StrictMode -Version Latest

$BeginTimer = Get-Date -Verbose

#region Environment setup
# Use TLS 1.2 to support Nuget provider
Write-Output "Configuring security protocol to use TLS 1.2 for Nuget support when installing modules." -Verbose
[ServicePointManager]::SecurityProtocol = [SecurityProtocolType]::Tls12
#endregion

#region FUNCTIONS
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
    $TranscriptFile = "$LogPrefix-TRANSCRIPT" + "-" + $TimeStamp + ".log"
    $script:Transcript = Join-Path -Path $LogDirectory -ChildPath $TranscriptFile

    # Create log and transcript files
    New-Item -Path $Transcript -ItemType File -ErrorAction SilentlyContinue
} # end function

# Validate template function
function Install-AzModulesWithCustomException
{
    [CmdletBinding()]
    param
    (
        [string]$excludeModule,
        [string]$requiredVersion
    ) # end param

    # Cleanup Az.Storage module directory to prepare for exclusive installation of version 2.1.0
    $checkCurrentAzStorageModulePath = (Get-InstalledModule -Name $excludeModule -ErrorAction SilentlyContinue).InstalledLocation | Split-Path -Parent -ErrorAction SilentlyContinue
    # $checkForVersion = (Get-InstalledModule -Name Az.Storage -RequiredVersion $requiredVersion).Version
    if (Test-Path -Path $checkCurrentAzStorageModulePath)
    {
        # Remove all versions since the required version is not present
        Get-ChildItem -Path $checkCurrentAzStorageModulePath -Exclude $requiredVersion | Remove-Item -Recurse -Force -Verbose
    } # end if
    # Exclusive installation of version Az.Storage 2.1.0
    # Find and install all Az modules except Az.Storage
    Write-Output "Finding required Az modules to install. Please wait..."
    $targetParentAzModule = "Az"
    $azModules = (Find-Module -Name $targetParentAzModule -IncludeDependencies -ErrorAction SilentlyContinue).Name
    $checkForVersion210 = (Get-InstalledModule -Name $excludeModule -RequiredVersion $requiredVersion).Version
    foreach ($azModule in $azModules)
    {
        If ($azModule -ne $excludeModule)
        {
            Install-Module -Name $azModule -Repository PSGallery -Verbose
        } # end if
        elseif ($checkForVersion210 -ne $requiredVersion)
        {
            # If required version is not present then install it
            Write-Output "Module $excludeModule and version $requiredVersion is not installed. Installing now..."
            Install-Module -Name $excludeModule -Repository -RequiredVersion $requiredVersion -AllowClobber -Force -Verbose
        } # end else
        else
        {
            Write-Output "The required module $excludeModule and version $requriedVersion is already installed."
        } # end else
    } # end foreach
} # end function
function Add-AzAdUsersAndGroups
{
    [CmdletBinding()]
    param
    (
        [array]$azUsers,
        [System.Management.Automation.PSCredential]$adminCred,
        [string]$subscriptionId,
        [string]$tenantId,
        [switch]$reset
    ) # end param

    # https://docs.microsoft.com/en-us/azure/role-based-access-control/role-assignments-powershell
    $subscriptionScope = "/subscriptions/$subscriptionId"

    # http://get-cmd.com/?p=4949
    Write-Output "Connecting to AzureAD tennant $tenantId"
    Write-Warning "The web based prompt may open in a separate window, so you may have to minimize this window first to see it."
    Connect-AzureAD -TenantId $tenantId -Verbose
    $plainTextPw = $adminCred.GetNetworkCredential().Password
    $securePassword = ConvertTo-SecureString -String $plainTextPw -AsPlainText -Force
    $tenantDomain = ((Get-AzureADTenantDetail).VerifiedDomains | Where-Object { $_._Default -eq 'True'}).Name 
    $customRole = "Contoso Azure VM Operator"
    $rbacTypeCustom = "Custom (Azure)"
    $rbacTypeBuiltIn = "Built-in (Azure)"
    $waitTimeSeconds = 20

    if (-not($reset))
    {
        foreach ($azUser in $azUsers)
        {
            # https://docs.microsoft.com/en-us/powershell/module/az.resources/new-azadgroup?view=azps-4.6.1
            do {
                New-AzADGroup -DisplayName $azUser.aadSecurityGroup -MailNickName (($azUser.aadSecurityGroup).replace(" ","")) -Description $azUser.rbacRole -ErrorAction SilentlyContinue              
            } until ((Get-AzAdGroup -DisplayName $azUser.aadSecurityGroup).DisplayName -eq $azUser.aadSecurityGroup)
            $groupObjectId = (Get-AzAdGroup -SearchString $azUser.aadSecurityGroup).Id
            $azAdTenantSuffix = "@" + $tenantDomain
            $pocUpn = $azUser.pocUserName + $azAdTenantSuffix
            $cusUpn = $azUser.customerUserName + $azAdTenantSuffix
            # https://docs.microsoft.com/en-us/powershell/module/az.resources/new-azaduser?view=azps-4.6.1
            $pocUserCreated = $false 
            do {
                $pocCurrentUser = New-AzADUser -DisplayName $azUser.pocDisplayName -UserPrincipalName $pocUpn -Password $securePassword -MailNickName $azUser.pocUserName -ErrorAction SilentlyContinue
                if ($pocCurrentUser.UserPrincipalName) 
                {  
                    $pocUserCreated = $true
                } 
            }
            Until ($pocUserCreated)
            
            [array]$pocMembers = (Get-AzADUser -UserPrincipalName $pocUpn).id 
            Add-AzADGroupMember -TargetGroupObjectId $groupObjectId -MemberObjectId $pocMembers -Verbose
            $cusUserCreated = $false 
            do {
                $cusCurrentUser = New-AzADUser -DisplayName $azUser.customerDisplayName -UserPrincipalName $cusUpn -Password $securePassword -MailNickName $azUser.customerUserName -ErrorAction SilentlyContinue
                if ($cusCurrentUser.UserPrincipalName)
                {
                    $cusUserCreated = $true
                }
            }
            Until ($cusUserCreated)

            [array]$cusMembers = (Get-AzADUser -UserPrincipalName $cusUpn).id
            Add-AzADGroupMember -TargetGroupObjectId $groupObjectId -MemberObjectId $cusMembers -Verbose -ErrorAction SilentlyContinue           
            $scope = $azUser.scope
            $method = $azUser.method 
            $findCommas = $null
            if ($method -eq 'scripted')
            {
                $findCommas = ($azUser.rbacRole | Select-String -Pattern ',' -SimpleMatch)
                if ($azUser.rbacRole -eq $customRole)
                {
                    $roleDescription = $azUser.rbacRole + " Assignment"
                    $result = $null
                    while ($null -eq $result) 
                    {
                        $result = New-AzRoleAssignment -ObjectId $groupObjectId -RoleDefinitionName $($azUser.rbacRole) -Scope $subscriptionScope -Description $roleDescription -Verbose -ErrorAction SilentlyContinue
                        # wait 5 seconds
                        Write-Host "Waiting $waitTimeSeconds seconds for Role Assignment - $($azUser.rbacRole) at $subscriptionScope..."
                        Start-Sleep -Seconds $waitTimeSeconds
                    }
                } # end if
                else
                {
                    $roleList = ($azUser.rbacRole).Split(',')
                    foreach ($role in $roleList)
                    {
                        $roleDescr = $role + " Assignment"
                        $result = $null
                        while ($null -eq $result) 
                        {
                            $result = New-AzRoleAssignment -ObjectId $groupObjectId -RoleDefinitionName $role -Scope $subscriptionScope -Description $roleDescr -Verbose -ErrorAction SilentlyContinue
                            # wait 5 seconds
                            Write-Host "Waiting $waitTimeSeconds seconds for Role Assignment - $role at $subscriptionScope..."
                            Start-Sleep -Seconds $waitTimeSeconds
                        }
                    } # end foreach
                } # end else
            } # end if
            else
            {
                # https://stackoverflow.com/questions/41960561/how-to-find-out-who-the-global-administrator-is-for-a-directory-to-which-i-belon
                Write-Output "The users $pocUpn and $cusUpn as members of the $($azUser.aadSecurityGroup) will have to be added to the Azure AD tenant role of $($azUser.rbacRole) manually in the Azure portal https://portal.azure.com "
            } # end else
            # Add role assignments
        } # end foreach
    } # end if
    else
    {
        foreach ($azUserReset in $azUsers)
        {
            $pocUpn = $azUserReset.pocUserName + "@" + $tenantDomain
            $cusUpn = $azUserReset.customerUserName + "@" + $tenantDomain
            $groupObjectId = (Get-AzADGroup -DisplayName $azUserReset.aadSecurityGroup).id
            # Removes the custom role definition from the subscription as part of cleanup.
            if ($azUserReset.rbacType -eq "Custom (Azure)")
            {
                $customRoleId = (Get-AzRoleDefinition -Name $azUserReset.rbacRole).id
                do {
                    Remove-AzRoleAssignment -ObjectId $groupObjectId -RoleDefinitionName $azUserReset.rbacRole -PassThru -Confirm:$false -Verbose
                    Remove-AzRoleDefinition -Id $customRoleId -Force -Confirm:$false -PassThru -Verbose -ErrorAction SilentlyContinue
                    Write-Output "Waiting to completely remove custom role definition $($azUserReset.rbacRole)..."
                    Start-Sleep -Seconds 10 
                    $currentCustomRoleDefId = (Get-AzRoleDefinition -Name $azUserReset.rbacRole).id 
                } until ($null -eq $currentCustomRoleDefId)
            }
            # https://docs.microsoft.com/en-us/powershell/module/az.resources/remove-azadgroup?view=azps-4.6.1
            Remove-AzADGroup -DisplayName $azUserReset.aadSecurityGroup -Verbose
            # https://docs.microsoft.com/en-us/powershell/module/az.resources/remove-azaduser?view=azps-4.6.1
            Remove-AzADUser -UserPrincipalName $pocUpn -PassThru -Verbose
            Remove-AzADUser -UserPrincipalName $cusUpn -PassThru -Verbose
        } # end foreach
    } # end else
} # end function

#endregion FUNCTIONS

### This PowerShell Script creates PoC Environment based on JSON Templates

#region INITIALIZE VALUES
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

# Install supporting modules
Install-Module -Name ARMDeploy -Force -Verbose
# Update AzureAD module
Install-Module -Name AzureAD -AllowClobber -Force

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

#region Az modules
$excludeModule = "Az.Storage"
$requiredVersion = "2.1.0"

# Remove all Az.Storage modules that are not version 2.1.0
# This is to prevent installation of updated but breaking-change impact of Az.Storage 2.5.0 (Az.Storage 2.1.0 is preferred)
# Install-AzModulesWithCustomException -excludeModule $excludeModule -requiredVersion $requiredVersion -Verbose

<#>
Install-Module -Name Az.Storage -AllowClobber -Force -Verbose
Install-Module -Name Az.Storage -RequiredVersion 2.1.0 -AllowClobber -Force -Verbose
#>

#region authenticate to subscription
Write-Output "Please see the open dialogue box in your browser to authenticate to your Azure subscription..."

# Clear any possible cached credentials for other subscriptions
Clear-AzContext

# Authenticate to Azure
Switch ($AzureEnvironment)
{
    "AzureCloud" { Connect-AzAccount -Environment AzureCloud }
    "AzureUSGovernment" { Connect-AzAccount -Environment AzureUSGovernment }
} # end switch

# https://docs.microsoft.com/en-us/azure/azure-government/documentation-government-get-started-connect-with-ps
# To connect to AzureUSGovernment interactively, use:
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
$tenantId = (Get-AzSubscription -SubscriptionName $Subscription).TenantId

#endregion

if ($reset)
{
    Add-AzAdUsersAndGroups -azUsers $azUsers -adminCred $adminCred -tenantId $tenantId -subscriptionId $subscriptionId -reset -Verbose
} 
else 
{
    $adminUserName = "templateUserName"
    #region Credentials: This will use a single automatically generated, but unknown password for all users that will be provisioned, but can be changed from the portal afterwards if necessary. 
    $clrStringPw = (New-Guid).guid
    $secStringPw = ConvertTo-SecureString -String $clrStringPw -AsPlainText -Force
    # Reset clear-text password to null for confidentiality
    $clrStringPw = $null 

    [System.Management.Automation.PSCredential]$adminCred = New-Object System.Management.Automation.PSCredential ($adminUserName,$secStringPw)
    # index 23: Create parameter hashtable for ARM templates

    #region Add custom role
    # https://docs.microsoft.com/en-us/azure/role-based-access-control/custom-roles-powershell

    $customRolePath = ".\customrole.json"
    $customRoleContent = Get-Content -Path $customRolePath
    ($customRoleContent -match $subIdPattern)[0] -match $subIdPattern
    $currentSubId = $matches[0]
    $initializedRoleContent = $customRoleContent.Replace($currentSubId,$defaultSubId)

    $targetSubId = $subscriptionId
    Write-Output "The custom role definition that will be added to the subscription is shown below"
    $initializedRoleContent
    Write-Output "Now we will update the default place-holder subscription id of $defaultSubId with your current subscription id of: $targetSubId"

    # Replace the default subscription id with the current subscription id
    $updatedRoleContent = $initializedRoleContent.Replace($defaultSubId,$targetSubId)

    # Write the updated role definition back out to the file system
    $updatedRoleContent | Out-File -FilePath $customRolePath -Force

    # Import the updated role definition to the current subscription
    New-AzRoleDefinition -InputFile $customRolePath -Verbose
    # Write the initialized role definition back out to the file system
    $initializedRoleContent | Out-File -FilePath $customRolePath -Force
    # Wait for 100 seconds to allow sufficient time for role to provision in Azure AD
    $s = 0
    $waitTime = 5
    $message = "Waiting for $waitTime seconds until custom role is provision in Azure AD."
    $psCustomRole = Get-Content -Raw -Path $customRolePath | ConvertFrom-Json
    do {
        $today = Get-Date
        "{0}`t{1}" -f @($today, $message)
        Start-Sleep -Seconds $waitTime
        $s++
    } until ((Get-AzRoleDefinition -Name $psCustomRole.name).Name -eq $psCustomRole.name)

    #endregion

    # Create AD Groups
    # https://docs.microsoft.com/en-us/powershell/module/azuread/new-azureadgroup?view=azureadps-2.0
    # https://docs.microsoft.com/en-us/powershell/module/azuread/new-azureaduser?view=azureadps-2.0

    Add-AzAdUsersAndGroups -azUsers $azUsers -adminCred $adminCred -subscriptionId $subscriptionId -tenantId $tenantId -Verbose
}

$StopTimerWoFw = Get-Date -Verbose
Write-Output "Calculating elapsed time..."
$ExecutionTimeWoFw = New-TimeSpan -Start $BeginTimer -End $StopTimerWoFw
$FooterWoFw = "TOTAL SCRIPT EXECUTION TIME: $ExecutionTimeWoFW"
Write-Output ""
Write-Output $FooterWoFw

Write-Warning "Transcript logs are hosted in the directory: $LogDirectory to allow access for multiple users on this machine for diagnostic or auditing purposes."
Write-Warning "To examine, archive or remove old log files to recover storage space, run this command to open the log files location: Start-Process -FilePath $LogDirectory"
Write-Warning "You may change the value of the `$modulePath variable in this script, currently at: $modulePath to a common file server hosted share if you prefer, i.e. \\<server.domain.com>\<share>\<log-directory>"
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
#endregion