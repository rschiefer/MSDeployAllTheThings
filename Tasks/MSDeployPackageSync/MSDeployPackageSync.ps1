[CmdletBinding(DefaultParameterSetName = 'None')]
param
(

    [String] [Parameter(Mandatory = $true)]
    $Package,
    
    [String] [Parameter(Mandatory = $true)]
    $DestinationProvider,
    
    [String] [Parameter(Mandatory = $true)]
    $DestinationComputer,
    
    [String] [Parameter(Mandatory = $true)]
    $AuthType,
    
    [String] [Parameter(Mandatory = $false)]
    $Username,
    
    [String] [Parameter(Mandatory = $false)]
    $Password,

    [String] [Parameter(Mandatory = $false)]
    $DoNotDelete,

    [String] [Parameter(Mandatory = $false)]
    $AdditionalArguments
)

# Import the Task.Common and Task.Internal dll that has all the cmdlets we need for Build
# import-module "C:\temp\vsoagent\Agent\Worker\Modules\Microsoft.TeamFoundation.DistributedTask.Task.Internal\Microsoft.TeamFoundation.DistributedTask.Task.Internal.dll"
# import-module "C:\temp\vsoagent\Agent\Worker\Modules\Microsoft.TeamFoundation.DistributedTask.Task.Common\Microsoft.TeamFoundation.DistributedTask.Task.Common.dll"
# import-module "Microsoft.TeamFoundation.DistributedTask.Task.Internal"
# import-module "Microsoft.TeamFoundation.DistributedTask.Task.Common"


# adding System.Web explicitly, since we use http utility
Add-Type -AssemblyName System.Web

Write-Verbose "Entering script MSDeployPackageSync.ps1"

Write-Host "Package= $Package"
Write-Host "DestinationProvider= $DestinationProvider"
Write-Host "DestinationComputer= $DestinationComputer"
Write-Host "Username= $Username"
Write-Host "DoNotDelete= $DoNotDelete"
Write-Host "AdditionalArguments= $AdditionalArguments"

[bool]$DoNotDelete = [System.Convert]::ToBoolean($DoNotDelete)
Write-Host "DonotDelete (converted) = $DoNotDelete"


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

$arguments = 
 "-verb:sync",
 "-source:package='$package'",
 "-dest:$DestinationProvider,computerName='$DestinationComputer',userName='$UserName',password='$Password',authType='$AuthType',includeAcls='False'",
#"-setParam:name='IIS", "Web", "Application", ("Name',value='" + $webApp + "'"),
 "-allowUntrusted"

Write-Host "$msdeploy $arguments $AdditionalArguments"

invoke-expression "& '$msdeploy' $arguments $AdditionalArguments"



Write-Verbose "Leaving script MSDeployPackageSync.ps1"



# PS D:\Github\vso-agent-tasks\Tasks\MSDeployPackageSync> .\MSDeployPackageSync.ps1 -DestinationProvider 'auto' -Package 'C:\temp\rootSitePackage\rootsite.zip'
#  -DestinationComputer 'https://testingvirtualapps.scm.azurewebsites.net:443/msdeploy.axd?site=TestingVirtualApps' -AuthType 'basic' -DoNotDelete 'FALSE' -Use
# rname '$TestingVirtualApps' -Password 'Rvs7kwDcuPxAfq2EKLoqRQgWhxBkcNlGrzLzfomQsvFF74Rdi3tohRMhRPrh' -AdditionalArguments "-setParamFile:C:\temp\rootSitePack
# age\RootSite.SetParameters.xml"
# Package= C:\temp\rootSitePackage\rootsite.zip