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