[CmdletBinding(DefaultParameterSetName = 'None')]
param
(

    [String] [Parameter(Mandatory = $true)]
    $Package,
    
    [String] [Parameter(Mandatory = $true)]
    $DestinationProvider,
    
    [String] [Parameter(Mandatory = $false)]
    $DestinationComputer,
    
    [String] [Parameter(Mandatory = $false)]
    $AuthType,
    
    [String] [Parameter(Mandatory = $false)]
    $Username,
    
    [String] [Parameter(Mandatory = $false)]
    $Password,

    [String] [Parameter(Mandatory = $false)]
    $SourceProvider,

    [String] [Parameter(Mandatory = $false)]
    $AdditionalArguments
)

import-module "Microsoft.TeamFoundation.DistributedTask.Task.Internal"
import-module "Microsoft.TeamFoundation.DistributedTask.Task.Common"


function Get-SingleFile($files, $pattern)
{
    if ($files -is [system.array])
    {
        throw (Get-LocalizedString -Key "Found more than one file to deploy with search pattern {0}. There can be only one." -ArgumentList $pattern)
    }
    else
    {
        if (!$files)
        {
            throw (Get-LocalizedString -Key "No files were found to deploy with search pattern {0}" -ArgumentList $pattern)
        }
        return $files
    }
}
Write-Host "packageFile= Find-Files -SearchPattern $Package"
$packageFile = Find-Files -SearchPattern $Package
Write-Host "packageFile= $packageFile"

#Ensure that at most a single package (.zip) file is found
$packageFile = Get-SingleFile $packageFile $Package

# adding System.Web explicitly, since we use http utility
Add-Type -AssemblyName System.Web

Write-Verbose "Entering script MSDeployPackageSync.ps1"

Write-Host "Package= $Package"
Write-Host "DestinationProvider= $DestinationProvider"
Write-Host "DestinationComputer= $DestinationComputer"
Write-Host "Username= $Username"
Write-Host "SourceProvider= $SourceProvider"
Write-Host "AdditionalArguments= $AdditionalArguments"


$MSDeployKey = 'HKLM:\SOFTWARE\Microsoft\IIS Extensions\MSDeploy\3' 
 if(!(Test-Path $MSDeployKey)) { 
 throw "Could not find MSDeploy. Use Web Platform Installer to install the 'Web Deployment Tool' and re-run this command" 
 } 

$InstallPath = (Get-ItemProperty $MSDeployKey).InstallPath 
 if(!$InstallPath -or !(Test-Path $InstallPath)) { 
 throw "Could not find MSDeploy. Use Web Platform Installer to install the 'Web Deployment Tool' and re-run this command" 
 } 

$msdeploy = Join-Path $InstallPath "msdeploy.exe" 
 if(!(Test-Path $MSDeploy)) { 
 throw "Could not find MSDeploy. Use Web Platform Installer to install the 'Web Deployment Tool' and re-run this command" 
 } 

# $publishUrl ="https://$Name.scm.azurewebsites.net:443/msdeploy.axd?site-name=$Name"
# $webApp ="$Name\$App"

Write-Host "Deploying $($packageFile.FileName) package to $DestinationComputer"

$remoteArguments = "computerName='$DestinationComputer',userName='$UserName',password='$Password',authType='$AuthType',"

if (-not $DestinationComputer -or -not $AuthType) {
    Write-Host "No destination or authType defined, performing local operation"
    $remoteArguments = ""
}

if (-not $SourceProvider) {
    Write-Host "No source provider specified, using package provider for '$packageFile'"
    $SourceProvider = "package='$packageFile'"
}

[string[]] $arguments = 
 "-verb:sync",
 "-source:$SourceProvider",
 "-dest:$DestinationProvider,$($remoteArguments)includeAcls='False'",
#"-setParam:name='IIS", "Web", "Application", ("Name',value='" + $webApp + "'"),
 "-allowUntrusted"

$fullCommand = """$msdeploy"" $arguments $AdditionalArguments"
Write-Host $fullCommand

# invoke-expression $fullCommand

# $block = $ExecutionContext.InvokeCommand.NewScriptBlock($fullCommand)
# & $block

$result = cmd.exe /c "$fullCommand"

Write-Host $result

If ($LASTEXITCODE -eq -1)
{
    Write-Host "Deployment failed"
    throw "MSDeploy command failed.  See logs for details."
}

Write-Verbose "Leaving script MSDeployPackageSync.ps1"



# PS D:\Github\vso-agent-tasks\Tasks\MSDeployPackageSync> .\MSDeployPackageSync.ps1 -DestinationProvider 'auto' -Package 'C:\temp\rootSitePackage\rootsite.zip'
#  -DestinationComputer 'https://testingvirtualapps.scm.azurewebsites.net:443/msdeploy.axd?site=TestingVirtualApps' -AuthType 'basic' -DoNotDelete 'FALSE' -Use
# rname '$TestingVirtualApps' -Password 'Rvs7kwDcuPxAfq2EKLoqRQgWhxBkcNlGrzLzfomQsvFF74Rdi3tohRMhRPrh' -AdditionalArguments "-setParamFile:C:\temp\rootSitePack
# age\RootSite.SetParameters.xml"
# Package= C:\temp\rootSitePackage\rootsite.zip
