$runbookModules = @("Az.Accounts", "Az.Resources", "Az.Compute", "Az.Automation", "Az.Network")

New-AzAutomationAccount `
    -ResourceGroupName $hubResources.ResourceGroup.ResourceGroupName `
    -Name $hubProperties.automationAccountName `
    -Location $hubResources.ResourceGroup.Location `
    -Plan $hubProperties.automationAccountPlan `
    -AssignSystemIdentity `
    -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue }

foreach ($runbookModule in $runbookModules) {
    Import-AzAutomationModule `
        -ResourceGroupName $hubResources.ResourceGroup.ResourceGroupName `
        -AutomationAccountName $hubProperties.aaName `
        -Name $runbookModule
}
    
New-AzAutomationSchedule `
    -ResourceGroupName $hubResources.ResourceGroup.ResourceGroupName `
    -AutomationAccountName $hubProperties.aaName `
    -Name $hubProperties.aaStartSchedule.Name `
    -Description $hubProperties.aaStartSchedule.Description `
    -DaysOfWeek $hubProperties.aaStartSchedule.DaysOfWeek `
    -WeekInterval $hubProperties.aaStartSchedule.WeekInterval `
    -StartTime $hubProperties.aaStartSchedule.StartTime `
    -ExpiryTime $hubProperties.aaStartSchedule.ExpiryTime `
    -Timezone $hubProperties.aaStartSchedule.Timezone `
    -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue }

New-AzAutomationSchedule `
    -ResourceGroupName $hubResources.ResourceGroup.ResourceGroupName `
    -AutomationAccountName $hubProperties.aaName `
    -Name $hubProperties.aaStopSchedule.Name `
    -Description $hubProperties.aaStopSchedule.Description `
    -DaysOfWeek $hubProperties.aaStopSchedule.DaysOfWeek `
    -WeekInterval $hubProperties.aaStopSchedule.WeekInterval `
    -StartTime $hubProperties.aaStopSchedule.StartTime `
    -ExpiryTime $hubProperties.aaStopSchedule.ExpiryTime `
    -Timezone $hubProperties.aaStopSchedule.Timezone `
    -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue }

Import-AzAutomationRunbook `
    -ResourceGroupName $hubResources.ResourceGroup.ResourceGroupName `
    -AutomationAccountName $hubProperties.aaName `
    -Name "Start-VMs" `
    -Path "$pwd\runbooks\Start-VMs.ps1" `
    -Description "Starts all VMs in a Resource Group" `
    -LogVerbose `
    -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue }

Import-AzAutomationRunbook `
    -ResourceGroupName $hubResources.ResourceGroup.ResourceGroupName `
    -AutomationAccountName $hubProperties.aaName `
    -Name "Stop-VMs" `
    -Path "$pwd\runbooks\Stop-VMs.ps1" `
    -Description "Stops all VMs in a Resource Group" `
    -LogVerbose `
    -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue }

Register-AzAutomationScheduledRunbook `
    -ResourceGroupName $hubResources.ResourceGroup.ResourceGroupName `
    -AutomationAccountName $hubProperties.aaName `
    -Name "Start-VMs" `
    -ScheduleName $hubProperties.aaStartSchedule.Name `
    -Description "Starts all VMs in a Resource Group" `
    -LogVerbose `
    -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue }

Register-AzAutomationScheduledRunbook `
    -ResourceGroupName $hubResources.ResourceGroup.ResourceGroupName `
    -AutomationAccountName $hubProperties.aaName `
    -Name "Stop-VMs" `
    -ScheduleName $hubProperties.aaStopSchedule.Name `
    -Description "Stops all VMs in a Resource Group" `
    -LogVerbose `
    -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue }

$hubResources.Add("AutomationAccount", $(Get-AzAutomationAccount -ResourceGroupName $hubResources.ResourceGroup.ResourceGroupName -Name $hubProperties.automationAccountName))