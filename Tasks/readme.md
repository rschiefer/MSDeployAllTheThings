# MSDeploy All the Things

This is a set of build and deployment tasks which utilize or support MSDeploy.

## We LOVE MSDeploy!!!

MSDeploy has proven itself extremely useful for our deployment needs in the past and we believe it has value going forward.  Check out [my blog](https://dotnetcatch.com) for all the ways you can use it.

## Tasks

We include a single task today MSDeployPackageSync:

> This task is used to deploy a MSDeploy package to a configured destination. This task is fairly generic allowing the users to set advanced MSDeploy options/arguments. 

## Release Info

### 0.0.4

Added support for providing an explicit SourceProvider instead of the default Package provider.  Thanks to Arne Petersen for the pull request!

### 0.0.5

Fixed bug from last change which caused a unintended breaking change.  Specifically, the new SourceProvider field was set to the help text but should have been blank.

## Want more?

If you have any suggestions for more tasks please contact me [@chief7](https://twitter.com/chief7) on Twitter or on my blog [dotnetcatch.com](https://dotnetcatch.com).   
