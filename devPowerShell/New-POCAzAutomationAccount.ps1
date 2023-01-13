$runbookModules = @("Az.Accounts", "Az.Resources", "Az.Compute", "Az.Automation", "Az.Network")

New-AzAutomationAccount `
    -ResourceGroupName $hubResources.ResourceGroup.ResourceGroupName `
    -Name $hubProperties.automationAccountName `
    -Location $hubResources.ResourceGroup.Location `
    -Plan $hubProperties.automationAccountPlan `
    -AssignSystemIdentity `
    -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue }

$hubResources.Add("AutomationAccount", $(Get-AzAutomationAccount -ResourceGroupName $hubResources.ResourceGroup.ResourceGroupName -Name $hubProperties.automationAccountName))

foreach ($runbookModule in $runbookModules) {
    Import-AzAutomationModule `
        -ResourceGroupName $hubResources.ResourceGroup.ResourceGroupName `
        -AutomationAccountName $hubProperties.automationAccountName `
        -Name $runbookModule
}
    
New-AzAutomationSchedule `
    -ResourceGroupName $hubResources.ResourceGroup.ResourceGroupName `
    -AutomationAccountName $hubProperties.automationAccountName `
    -Name $hubProperties.automationAccountScheduleNameStart `
    -Description $hubProperties.automationAccountScheduleDescriptionStart `
    -Frequency $hubProperties.automationAccountScheduleFrequencyStart `
    -Interval $hubProperties.automationAccountScheduleIntervalStart `
    -StartTime $hubProperties.automationAccountScheduleStartTimeStart `
    -ExpiryTime $hubProperties.automationAccountScheduleExpiryTimeStart `
    -Timezone $hubProperties.automationAccountScheduleTimezoneStart `
    -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue }

New-AzAutomationSchedule `
    -ResourceGroupName $hubResources.ResourceGroup.ResourceGroupName `
    -AutomationAccountName $hubProperties.automationAccountName `
    -Name $hubProperties.automationAccountScheduleNameStop `
    -Description $hubProperties.automationAccountScheduleDescriptionStop `
    -Frequency $hubProperties.automationAccountScheduleFrequencyStop `
    -Interval $hubProperties.automationAccountScheduleIntervalStop `
    -StartTime $hubProperties.automationAccountScheduleStartTimeStop `
    -ExpiryTime $hubProperties.automationAccountScheduleExpiryTimeStop `
    -Timezone $hubProperties.automationAccountScheduleTimezoneStop `
    -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue }

Import-AzAutomationRunbook `
    -ResourceGroupName $hubResources.ResourceGroup.ResourceGroupName `
    -AutomationAccountName $hubProperties.automationAccountName `
    -Name "Start-VMs" `
    -Path "$pwd\runbooks\Start-VMs.ps1" `
    -Description "Starts all VMs in a Resource Group" `
    -LogVerbose `
    -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue }

Import-AzAutomationRunbook `
    -ResourceGroupName $hubResources.ResourceGroup.ResourceGroupName `
    -AutomationAccountName $hubProperties.automationAccountName `
    -Name "Stop-VMs" `
    -Path "$pwd\runbooks\Stop-VMs.ps1" `
    -Description "Stops all VMs in a Resource Group" `
    -LogVerbose `
    -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue }

Register-AzAutomationScheduledRunbook `
    -ResourceGroupName $hubResources.ResourceGroup.ResourceGroupName `
    -AutomationAccountName $hubProperties.automationAccountName `
    -Name "Start-VMs" `
    -ScheduleName $hubProperties.automationAccountScheduleNameStart `
    -Description "Starts all VMs in a Resource Group" `
    -LogVerbose `
    -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue }

Register-AzAutomationScheduledRunbook `
    -ResourceGroupName $hubResources.ResourceGroup.ResourceGroupName `
    -AutomationAccountName $hubProperties.automationAccountName `
    -Name "Stop-VMs" `
    -ScheduleName $hubProperties.automationAccountScheduleNameStop `
    -Description "Stops all VMs in a Resource Group" `
    -LogVerbose `
    -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue }