$pocResources = Get-AzResource -Tag $global:globalProperties.globalTags
$pocResourceGroups = Get-AzResourceGroup -Tag $global:globalProperties.globalTags
Write-Output "Removing $($pocResources.Count) resources from $($pocResourceGroups.Count) resource groups"

foreach ($pocResource in $pocResources) {
    Write-Output "Removing $($pocResource.ResourceGroupName)/$($pocResource.ResourceName)"
    Remove-AzResource -ResourceId $pocResource.Id -Force -ErrorAction SilentlyContinue | Out-Null
}

foreach ($pocResourceGroup in $pocResourceGroups) {
    Write-Output "Removing $($pocResourceGroup.ResourceGroupName)"
    Remove-AzResourceGroup -Name $pocResourceGroup.ResourceGroupName -Force -ErrorAction SilentlyContinue | Out-Null
}

$pocResourcesAfter = Get-AzResource -Tag $global:globalProperties.globalTags
$pocResourceGroupsAfter = Get-AzResourceGroup -Tag $global:globalProperties.globalTags
Write-Output "Removed $($pocResourceGroups.Count - $pocResourceGroupsAfter.Count) resource groups and $($pocResources.Count - $pocResourcesAfter.Count) resources"

if ($pocResourceGroupsAfter.Count -gt 0) {
    Write-Output "Failed to remove $($pocResourceGroupsAfter.Count) resource groups"
    Write-Output $pocResourceGroupsAfter
}

if ($pocResourcesAfter.Count -gt 0) {
    Write-Output "Failed to remove $($pocResourcesAfter.Count) resources"
    Write-Output $pocResourcesAfter
}

if ($pocResourceGroupsAfter.Count -gt 0 -or $pocResourcesAfter.Count -gt 0) {
    Write-Output "Resources unable to be removed should be attempted through the Azure Portal (https://portal.azure.com)"
}