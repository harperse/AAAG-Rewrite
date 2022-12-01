### Activate Azure with Administration and Governance PoC
### Requires -Version 3.0
### This PowerShell Script assigns Tags to Azure Resource Group and its Resources 

$RG = Read-Host 'Enter Resource Group Name to assign Tags'
$TagCount = Read-Host 'How many Tags are you going to assign?'

### Adding Tags to Resource Group
for ($i=1
$i -le $TagCount
 $i++){
$TagName = Read-Host 'Enter Tag Name'
$TagValue = Read-Host 'Enter Tag Value'

$tags = (Get-AzResourceGroup -Name $RG).Tags
    if ($tags -eq $null) {

        Set-AzResourceGroup -Name $rg -Tag @{$TagName = $TagValue }
    }
    else { $tags.Add($TagName, $TagValue)
        Set-AzResourceGroup -Tag $tags -Name $RG
    }
  }


### Adding Tags to Resources

$group = Get-AzResourceGroup $RG
if ($group.Tags -ne $null) {
   $resources = Get-AzResource | Where {$_.ResourceGroupName –eq $RG}
    foreach ($r in $resources)
    {
        $resourcetags = (Get-AzResource -ResourceId $r.ResourceId).Tags
        if ($resourcetags)
        {
            foreach ($key in $group.Tags.Keys)
            {
                if (-not($resourcetags.ContainsKey($key)))
                {
                    $resourcetags.Add($key, $group.Tags[$key])
                }
            }
            Set-AzResource -Tag $resourcetags -ResourceId $r.ResourceId -Force
        }
        else
        {
            Set-AzResource -Tag $group.Tags -ResourceId $r.ResourceId -Force
        }
    }
}