# MSDeploy Package Sync

## Overview

This task is used to deploy a MSDeploy package to a configured destination.  This task is fairly generic allowing the users to set advanced MSDeploy options/arguments.  

## Use cases

### Deploying to Azure Website

Download the publish settings for the website from Azure Portal.  Use the username/password values from the settings file, set the AuthType parameter to basic and set the "Destination Computer" parameter to 

"https://[siteName].scm.azurewebsites.net:443/msdeploy.axd?site=[siteName]}"

### Deploying a Virtual App to IIS

Simply set the "IIS Web Application Name" parameter to 

"[siteName]\\[virtualAppName]" 

## Parameters of the task

The parameters for this task correlate directly to MSDeploy.exe arguments:

msdeploy.exe -verb:sync -source:package='[Web Deploy Package]' -dest:[Destination Provider],computerName='[Destination Computer]',userName='[UserName]',password='[Password]',authType='[AuthType]',includeAcls='False' -allowUntrusted

Review the MSDeploy.exe documentation for more details - https://technet.microsoft.com/en-us/library/dd569001(v=ws.10).aspx

### Web Deploy Package

The file path or search pattern for the MSDeploy package file.

### Destination Provider

The Destination Provider will typically be set to "auto" for a package deployment.  In theory, it could also support a manifest but this hasn't been tested.

### Destination Computer

The computer name or MSDeploy web agent endpoint for the target server. 

### AuthType

The authentication type can be either "ntlm" or "basic".

### Additional Arguments

You must use single quotes for arguments, double quotes will cause errors. Common arguments include:

 - **-verbose** - Enables verbose logging to aid in troubleshooting a deployment. 
 - **-setParam:'IIS Web Application Name'=[appName]** - Sets a WebDeploy Parameterization parameter.  In this case, it sets the default IIS site name.