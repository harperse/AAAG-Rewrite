#requires -Module Az.Accounts, Az.Resources, Az.Compute, Az.Automation

<#
.SYNOPSIS
To preserve compute costs, start or stop VMs in a set of resource groups that match a certain pattern

.DESCRIPTION
This runbook will be used in the Activate Azure with Administration and Governance PoC script Deploy-AzureResourceGroup.ps1, to import,
publish and schedule a runbook that can stop or start Virtual Machines hosted in a set of resource groups. It will stop the VMs at 18:00 local and start them in the morning again at 08:00.
The local time is obtained from current machine that the script executes on, and the time zone is calculated based on the time zone setting on the host system.

.PARAMETER Operation
This parameter is used to indicate whether the VM should be started or stopped.

.PARAMETER ResourceGroupName
Specify the resource groups to target to start or stop VMs. The default value uses a filter to resolve the two resource groups associated with the Activate Azure with Administration and Governance PoC environment.

.EXAMPLE
Manage-CostForPoCVirtualMachines -Operation Start -ResourceGroupName <ResourceGroupName>

.EXAMPLE
Manage-CostForPoCVirtualMachines -Operation Stop -ResourceGroupName <ResourceGroupName>

.NOTES

CONTRIBUTORS
1. Anderson Patricio
2. Preston K. Parsard

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
1. https://docs.microsoft.com/en-us/azure/automation/learn/powershell-runbook-managed-identity

.COMPONENT
Azure Infrastructure, PowerShell, Runbooks

.ROLE
Automation Engineer
DevOps Engineer
Azure Engineer
Azure Administrator
Azure Architect

.FUNCTIONALITY
Manages cost for compute resources in the Activate Azure with Administration and Governance PoC Infrastructure

#>
param (
    [string]$operation = "stop",
    [string]$env = "AzureCloud" # For US Gov cloud, use value "AzureUSGovernment" before publishing and scheduling this runbook.
) # end param

# Authenticate to subscription with automation system assigned managed identity
function Connect-ToSubscriptionWithRunAsAccount
{
    # Ensures you do not inherit an AzContext in your runbook
    Disable-AzContextAutosave -Scope Process | Out-Null
    try
    {
        $AzureContext = (Connect-AzAccount -Identity).context
    }
    catch 
    {
        if (!$AzureContext)
        {
            $ErrorMessage = "Context $AzureContext not found."
        }
        else
        {
            Write-Error -Message $_.Exception
            throw $_.Exception
        }
    }
    # set and store context
    $AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext
} # end function

function Get-ResourceGroupNames
{
    [CmdletBinding()]
    [OutputType([string[]])]
    param
    (
        [string[]]$ResourceGroups
    ) # end param

    $rgSpoke = (Get-AzResourceGroup -Name "*-APP-NP-RGP-01*").ResourceGroupName
    $rgHub = (Get-AzResourceGroup -Name "*-INF-NP-RGP-01*" -ErrorAction SilentlyContinue).ResourceGroupName
    if ($rgHub -and $rgSpoke)
    {
        $ResourceGroups += $rgSpoke
        $ResourceGroups += $rgHub
    } # end if
    else
    {
        $ResourceGroups += $rgSpoke
    } # end else
    return $ResourceGroups
} # end function

Connect-ToSubscriptionWithRunAsAccount
# Script body
# Construct an consisting of both hub and spoke resource groups

$ResourceGroups = @()
[string[]]$ResourceGroups = Get-ResourceGroupNames -ResourceGroups $ResourceGroups
$separatorDouble = ("="*$numberOfChars)
$i = 0
Write-Output $separatorDouble
Write-Output "ACTIVATE AZURE WITH ADMINISTRATION AND GOVERNANCE POC COMPUTE STARTUP/SHUTDOWN RUNBOOK"
Write-Output $separatorDouble
$separatorSingle = ("-"*$numberOfChars)
ForEach ($ResourceGroup in $ResourceGroups)
{
    $vmInfo = Get-AzVm -ResourceGroupName $ResourceGroup
    If ($null -eq $vmInfo)
    {
        Write-Output "The Runbook could not find VMs on the $ResourceGroup specified."
        Exit
    } # end if
    else
    {
        ForEach ($vm in $vmInfo)
        {
            if (($operation -eq "start") -and ($vm.PowerState -ne "VM running"))
            {
                Write-Output $separatorSingle
                "VM NAME: `t $($vm.Name)"
                "VM STATE: `t $($vm.PowerState)"
                "VM OPERATION: STARTING..."
                Start-AzVM -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -Verbose -ErrorAction SilentlyContinue
                $i++
            } # end if
            ElseIf (($Operation -eq "Stop") -and ($vm.PowerState -ne "VM deallocated"))
            {
                Write-Output $separatorSingle
                "VM NAME: `t $($vm.Name)"
                "VM STATE: `t $($vm.PowerState)"
                "VM OPERATION: STOPPING (DEALLOCATING)..."
                Stop-AzVM -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -Force -Verbose -ErrorAction SilentlyContinue
                $i++
            } # end else if
            Else
            {
                "VM NAME: `t $($vm.Name)"
                Write-Output ("-"*50)
                "VM STATE: `t $($vm.PowerState)"
                "VM OPERATION: EITHER STARTING OR STOPPING"
            } # end else
            "VM STATE: `t $($vm.PowerState)"
            Write-Output $separatorDouble
            Write-Output "SUMMARY: $i `t VMs have been processed"
            Write-Output $separatorDouble
        } # end foreach
    } # end else
} # end foreach