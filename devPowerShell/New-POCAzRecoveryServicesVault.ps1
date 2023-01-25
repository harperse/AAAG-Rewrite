# Create recovery services vault
Import-Module Az.RecoveryServices
Write-Output "Creating recovery services vault $($global:spokeProperties.rsvName) in $($global:spokeResources.ResourceGroup.ResourceGroupName)..."
New-AzRecoveryServicesVault `
    -Name $global:spokeProperties.rsvName `
    -ResourceGroupName $global:spokeResources.ResourceGroup.ResourceGroupName `
    -Location $global:spokeResources.ResourceGroup.Location `
    -Tag $global:globalProperties.globalTags
$global:spokeResources.Add("RSV", $(Get-AzRecoveryServicesVault `
            -Name $global:spokeProperties.rsvName `
            -ResourceGroupName $global:spokeResources.ResourceGroup.ResourceGroupName `
    )
)