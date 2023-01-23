# Create automation account
Import-Module Az.Automation
Write-Output "Creating automation account $($global:hubProperties.aaName) in $($alaToaaaMap[$selectedHubRegionCode].aaa)..."
$global:hubResources.Add("AutomationAccount", $(New-AzAutomationAccount `
            -ResourceGroupName $global:hubResources.ResourceGroup.ResourceGroupName `
            -Location $alaToaaaMap[$selectedHubRegionCode].aaa `
            -Name $global:hubProperties.aaName `
            -Plan $global:hubProperties.aaPlan `
            -AssignSystemIdentity `
            -Tag @{ $global:globalProperties.tagKey = $global:globalProperties.tagValue }
    )
)

# Add modules to automation account
Write-Output "Adding modules to automation account $($global:hubProperties.aaName)..."
foreach ($runbookModule in $runbookModules.GetEnumerator()) {
    if (!(Get-AzAutomationModule -ResourceGroupName $global:hubResources.ResourceGroup.ResourceGroupName -AutomationAccountName $global:hubProperties.aaName -Name $runbookModule.Name -ErrorAction SilentlyContinue)) {
        Write-Output "Adding module $($runbookModule.Name)..."
        Import-AzAutomationModule `
            -ResourceGroupName $global:hubResources.ResourceGroup.ResourceGroupName `
            -AutomationAccountName $global:hubProperties.aaName `
            -Name $runbookModule.Name `
            -ContentLinkUri "https://www.powershellgallery.com/api/v2/package/$($runbookModule.Name)/$($runbookModule.Value)"
    }
}

# Add runbooks to automation account
Write-Output "Adding runbooks to automation account $($global:hubProperties.aaName)..."
[hashtable]$aaStartSchedule = $global:hubProperties.aaStartSchedule
[hashtable]$aaStartImportRunbook = $global:hubProperties.aaStartImportRunbook
[hashtable]$aaStartRegisterRunbook = $global:hubProperties.aaStartRegisterRunbook
New-AzAutomationSchedule @aaStartSchedule `
    -ResourceGroupName $global:hubResources.ResourceGroup.ResourceGroupName `
    -AutomationAccountName $global:hubProperties.aaName

Import-AzAutomationRunbook @aaStartImportRunbook `
    -ResourceGroupName $global:hubResources.ResourceGroup.ResourceGroupName `
    -AutomationAccountName $global:hubProperties.aaName `
    -Tags @{ $global:globalProperties.tagKey = $global:globalProperties.tagValue }

Register-AzAutomationScheduledRunbook @aaStartRegisterRunbook `
    -ResourceGroupName $global:hubResources.ResourceGroup.ResourceGroupName `
    -AutomationAccountName $global:hubProperties.aaName

[hashtable]$aaStopSchedule = $global:hubProperties.aaStopSchedule
[hashtable]$aaStopImportRunbook = $global:hubProperties.aaStopImportRunbook
[hashtable]$aaStopRegisterRunbook = $global:hubProperties.aaStopRegisterRunbook
New-AzAutomationSchedule @aaStopSchedule `
    -ResourceGroupName $global:hubResources.ResourceGroup.ResourceGroupName `
    -AutomationAccountName $global:hubProperties.aaName
    
Import-AzAutomationRunbook @aaStopImportRunbook `
    -ResourceGroupName $global:hubResources.ResourceGroup.ResourceGroupName `
    -AutomationAccountName $global:hubProperties.aaName `
    -Tags @{ $global:globalProperties.tagKey = $global:globalProperties.tagValue }

Register-AzAutomationScheduledRunbook @aaStopRegisterRunbook `
    -ResourceGroupName $global:hubResources.ResourceGroup.ResourceGroupName `
    -AutomationAccountName $global:hubProperties.aaName