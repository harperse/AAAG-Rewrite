[Parameter(Mandatory = $true)][ParameterSet("Hub", "Spoke")][string]$HubOrSpoke


if ($HubOrSpoke -eq "Hub") {
    # Create the Jumpbox VM
    $nicIPConfigJMP = New-AzNetworkInterfaceIpConfig `
        -Name $hubProperties.NICIPConfigNameJMP `
        -SubnetId $global:hubResources.SubnetJMP.Id `
        -PrivateIpAddress $global:hubResources.JMPPrivateIPAddress `
        -PublicIpAddressId $global:hubResources.PubIPJMP.Id `
        -PrivateIpAddressVersion IPv4 `
        -Primary `
        -AsJob

    $nicConfigJMP = New-AzNetworkInterface `
        -Name $hubProperties.NICNameJMP `
        -ResourceGroupName $global:hubResources.ResourceGroup.Name `
        -Location $global:hubResources.ResourceGroup.Location `
        -IpConfigurationName $nicIPConfigJMP `
        -Tag @{ $globalResources.TagName = $globalResources.TagValue } `
        -AsJob

    $osDiskConfigJMP = New-AzDiskConfig `
        -SkuName $globalProperties.storageAccountSkuName `
        -Location $global:hubResources.ResourceGroup.Location `
        -CreateOption $hubProperties.JMPOSDiskCreateOption `
        -DiskSizeGB $hubProperties.JMPOSDiskSizeGB `
        -Tag @{ $globalResources.TagName = $globalResources.TagValue } `
        -AsJob

    $dataDiskConfigJMP = New-AzDiskConfig `
        -SkuName $globalProperties.storageAccountSkuName `
        -Location $global:hubResources.ResourceGroup.Location `
        -CreateOption $hubProperties.JMPDataDiskCreateOption `
        -DiskSizeGB $hubProperties.JMPDataDiskSizeGB `
        -Tag @{ $globalResources.TagName = $globalResources.TagValue } `
        -AsJob

    $vmConfigJMP = New-AzVMConfig `
        -VMName $hubProperties.JMPVMName `
        -VMSize $globalProperties.vmSize `
        -Tags @{ $globalResources.TagName = $globalResources.TagValue } `

    $vmConfigJMP = Add-AzNetworkInterface `
        -VM $vmConfigJMP `
        -Id $nicConfigJMP.Id

    $vmConfigJMP = Set-AzVMOSDisk `
        -VM $vmConfigJMP `
        -Name $hubProperties.JMPOSDiskName `
        -Disk $osDiskConfigJMP `
        -Caching ReadWrite `
        -CreateOption $hubProperties.JMPOSDiskCreateOption `
        -Windows

    $vmConfigJMP = Add-AzVMDataDisk `
        -VM $vmConfigJMP `
        -Name $hubProperties.JMPDataDiskName `
        -Disk $dataDiskConfigJMP

    $global:hubResources.Add("VMJMP", $(New-AzVM `
                -ResourceGroupName $global:hubResources.ResourceGroup.Name `
                -Location $global:hubResources.ResourceGroup.Location `
                -Image $globalProperties.vmImage `
                -VirtualNetworkName $global:hubResources.Vnet.Name `
                -Credential $credential `
                -VM $vmConfigJMP `
                -Tag @{ $globalResources.TagName = $globalResources.TagValue } `
                -AsJob
        )
    )
}
else {
    # Create the domain controller
    $global:spokeResources.Add("VMADC", $(New-AzVM `
                -ResourceGroupName $global:spokeResources.ResourceGroup.Name `
                -Location $global:spokeResources.ResourceGroup.Location `
                -Name $spokeProperties.vmNameADC `
                -Size $globalProperties.vmSize `
                -Image $globalProperties.vmImage `
                -VirtualNetworkName $global:spokeResources.Vnet.Name `
                -Credential $global:credential `
                -SubnetName $spokeProperties.SubnetNameADC `
                -AvailabilitySetName $global:spokeResources.AVSetADC.Name `
                -Tag @{ $globalResources.TagName = $globalResources.TagValue } `
                -AsJob
        )
    )

    # Create the web servers
    $global:spokeResources.Add("VMWeb1", $(New-AzVM `
                -ResourceGroupName $global:spokeResources.ResourceGroup.Name `
                -Location $global:spokeResources.ResourceGroup.Location `
                -Name $spokeProperties.vmNameWeb1 `
                -Size $globalProperties.vmSize `
                -Image $globalProperties.vmImage `
                -VirtualNetworkName $global:spokeResources.Vnet.Name `
                -Credential $global:credential `
                -SubnetName $spokeProperties.SubnetNameSRV `
                -AvailabilitySetName $global:spokeResources.AVSetWeb.Name `
                -Tag @{ $globalResources.TagName = $globalResources.TagValue } `
                -AsJob
        )
    )

    $global:spokeResources.Add("VMWeb2", $(New-AzVM `
                -ResourceGroupName $global:spokeResources.ResourceGroup.Name `
                -Location $global:spokeResources.ResourceGroup.Location `
                -Name $spokeProperties.vmNameWeb2 `
                -Size $globalProperties.vmSize `
                -Image $globalProperties.vmImage `
                -VirtualNetworkName $global:spokeResources.Vnet.Name `
                -Credential $global:credential `
                -SubnetName $spokeProperties.SubnetNameSRV `
                -AvailabilitySetName $global:spokeResources.AVSetWeb.Name `
                -Tag @{ $globalResources.TagName = $globalResources.TagValue } `
                -AsJob
        )
    )

    $global:spokeResources.Add("VMSQL1", $(New-AzVM `
                -ResourceGroupName $global:spokeResources.ResourceGroup.Name `
                -Location $global:spokeResources.ResourceGroup.Location `
                -Name $spokeProperties.vmNameSQL1 `
                -Size $globalProperties.vmSize `
                -Image $globalProperties.vmImage `
                -VirtualNetworkName $global:spokeResources.Vnet.Name `
                -Credential $global:credential `
                -SubnetName $spokeProperties.SubnetNameSRV `
                -AvailabilitySetName $global:spokeResources.AVSetSQL.Name `
                -Tag @{ $globalResources.TagName = $globalResources.TagValue } `
                -AsJob
        )
    )

    $global:spokeResources.Add("VMSQL2", $(New-AzVM `
                -ResourceGroupName $global:spokeResources.ResourceGroup.Name `
                -Location $global:spokeResources.ResourceGroup.Location `
                -Name $spokeProperties.vmNameSQL2 `
                -Size $globalProperties.vmSize `
                -Image $globalProperties.vmImage `
                -VirtualNetworkName $global:spokeResources.Vnet.Name `
                -Credential $global:credential `
                -SubnetName $spokeProperties.SubnetNameSRV `
                -AvailabilitySetName $global:spokeResources.AVSetSQL.Name `
                -Tag @{ $globalResources.TagName = $globalResources.TagValue } `
                -AsJob
        )
    )

    $global:spokeResources.Add("VMLNX", $(New-AzVM `
                -ResourceGroupName $global:spokeResources.ResourceGroup.Name `
                -Location $global:spokeResources.ResourceGroup.Location `
                -Name $spokeProperties.vmNameLNX `
                -Size $globalProperties.vmSize `
                -Image $globalProperties.vmImage `
                -VirtualNetworkName $global:spokeResources.Vnet.Name `
                -Credential $global:credential `
                -SubnetName $spokeProperties.SubnetNameSRV `
                -AvailabilitySetName $global:spokeResources.AVSetLNX.Name `
                -Tag @{ $globalResources.TagName = $globalResources.TagValue } `
                -AsJob
        )
    )

    $global:spokeResources.Add("VMDEV", $(New-AzVM `
                -ResourceGroupName $global:spokeResources.ResourceGroup.Name `
                -Location $global:spokeResources.ResourceGroup.Location `
                -Name $spokeProperties.vmNameDEV `
                -Size $globalProperties.vmSize `
                -Image $globalProperties.vmImage `
                -VirtualNetworkName $global:spokeResources.Vnet.Name `
                -Credential $global:credential `
                -SubnetName $spokeProperties.SubnetNameSRV `
                -AvailabilitySetName $global:spokeResources.AVSetDEV.Name `
                -Tag @{ $globalResources.TagName = $globalResources.TagValue } `
                -AsJob
        )
    )
}