Configuration adsCnfgInstalldc02
{
	Param
	(
		[string]$domainName,
		[string]$dataDiskNumber,
		[string]$dataDiskDriveLetter,
		[System.Management.Automation.PSCredential]$domainAdminCredentials
	) # end param

	Install-PackageProvider -Name NuGet -Force
	Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
	Import-DscResource -ModuleName PSDesiredStateConfiguration, xActiveDirectory, xComputerManagement, xStorage

	[string]$netbiosDomainName = $domainName.Split(".")[0]
	[System.Management.Automation.PSCredential ]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${netbiosDomainName}\$($domainAdminCredentials.UserName)", $domainAdminCredentials.Password)

	$dcFeaturesToAdd = @(
		$rsatDnsServer = @{
			Ensure = "Present";
			Name = "RSAT-DNS-Server"
		} # end hashtable
		$rsatAdCenter = @{
			Ensure = "Present";
			Name = "RSAT-AD-AdminCenter"
		} # end hashtable
		$rsatADDS = @{
			Ensure = "Present";
			Name = "RSAT-ADDS"
		} # end hashatable
		$rsatAdPowerShell = @{
			Ensure = "Present";
			Name = "RSAT-AD-PowerShell"
		} # end hashtable
		$rsatAdTools = @{
			Ensure = "Present";
			Name = "RSAT-AD-Tools"
		} # end hashatale
		$rsatGPMC = @{
			Ensure = "Present";
			Name = "GPMC"
		} # end hashtable
	) # end array

	Node localhost
	{
  		LocalConfigurationManager
		{
			ConfigurationMode = 'ApplyAndAutoCorrect'
			RebootNodeIfNeeded = $true
			ActionAfterReboot = 'ContinueConfiguration'
			AllowModuleOverwrite = $true
		} # end LCM

		ForEach ($dcFeature in $dcFeaturesToAdd)
		{
			WindowsFeature "$($dcFeature.Name)"
				{
					Ensure = "$($dcFeature.Present)"
					Name = "$($dcFeature.Name)"
				} # end resource
		} # end foreach

		WindowsFeature "AD-Domain-Services"
		{
			Ensure = "Present";
			Name = "AD-Domain-Services"
		} # end hashtable

		WindowsFeature "RSAT-Role-Tools"
		{
			Ensure = "Present";
			Name = "RSAT-Role-Tools"
		} # end hashtable

		xWaitForDisk WaitForDataDiskProvisioning
		{
			DiskId = $dataDiskNumber
			RetryCount = $Node.RetryCount
			RetryIntervalSec = $Node.RetryIntervalSec
			DependsOn = "[WindowsFeature]RSAT-Role-Tools"
		} # end resource

		xDisk ConfigureDataDisk
		{
			DiskId = $dataDiskNumber
			DriveLetter = $dataDiskDriveLetter
			FSLabel = "DATA"
			DependsOn = "[xWaitforDisk]WaitForDataDiskProvisioning"
		} # end resource

        xWaitForADDomain ForestWait
        {
            DomainName = $domainName
            DomainUserCredential = [System.Management.Automation.PSCredential]$DomainCreds
            RetryCount = 3
			RetryIntervalSec = 300
			DependsOn = "[xDisk]ConfigureDataDisk"
        } # end resource

        xADDomainController NewReplicaDC
		{
			DomainName = $domainName
			DomainAdministratorCredential = [System.Management.Automation.PSCredential]$DomainCreds
			SafemodeAdministratorPassword = [System.Management.Automation.PSCredential]$DomainCreds
			DatabasePath = $dataDiskDriveLetter + ":\NTDS"
			LogPath = $dataDiskDriveLetter + ":\LOGS"
			SysvolPath = $dataDiskDriveLetter + ":\SYSV"
			DependsOn = "[xWaitForADDomain]ForestWait"
		} # end resource
	} # end node
} # end configuration