.\New-POCAzParametersFile.ps1
$commonParameters.GetEnumerator() | ForEach-Object { Add-Content -Path ".\DeploymentFiles\variables.tf" -Value "variable `"$($_.key)`" {`r`n`tdefault = `"$($_.Value)`"`r`n}" -Force }
$spokeParametersToFile.GetEnumerator() | ForEach-Object { Add-Content -Path ".\DeploymentFiles\variables.tf" -Value "variable `"$($_.key)`" {`r`n`tdefault = `"$($_.Value)`"`r`n}" -Force }
$hubParametersToFile.GetEnumerator() | ForEach-Object { Add-Content -Path ".\DeploymentFiles\variables.tf" -Value "variable `"$($_.key)`" {`r`n`tdefault = `"$($_.Value)`"`r`n}" -Force }
$hubParametersWithFirewallToFile.GetEnumerator() | ForEach-Object { Add-Content -Path ".\DeploymentFiles\variables.tf" -Value "variable `"$($_.key)`" {`r`n`tdefault = `"$($_.Value)`"`r`n}" -Force }