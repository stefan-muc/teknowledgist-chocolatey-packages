﻿$ErrorActionPreference = 'Stop'  # stop on all errors

$InstallArgs = @{
   packageName = 'fusion-ldv'
   installerType = 'exe'
   url = 'http://forsys.cfr.washington.edu/fusion/FUSION_Install.exe'
   silentArgs = '/S /D=c:\Program Files (x86)\Fusion-LDV'
   validExitCodes = @(0)
}

# Allow users to override the install location in a "standard" way.
if ($env:chocolateyInstallArguments -match '/D=' ) {
   $InstallArgs.silentArgs = '/S'
}
Install-ChocolateyPackage @InstallArgs

# To support compressed LiDAR data, the LASzip.dll file from 
#   the lastools package needs to be copied.

# First, find where Fusion-LDV ended up
$StartMenu = Join-Path $env:ProgramData "\Microsoft\Windows\Start Menu"
$SMlink = Get-ChildItem $StartMenu -Filter 'Fusion.lnk' -Recurse
$lnk = (new-object -com wscript.shell).createShortcut($SMlink.FullName)
$InstallPath = Split-Path $lnk.targetPath


# Next, find it the dll
$TargetPackage = 'lastools'
$TargetLib = "$env:ChocolateyInstall\lib\$TargetPackage"
$TargetUnzipLog = Get-ChildItem $TargetLib -Filter '*.zip.txt'
If ($TargetUnzipLog) {
   $TargetInstallLocation = Split-Path (Get-Content $TargetUnzipLog.FullName | Select-Object -First 1)
   $dll = Get-ChildItem $TargetInstallLocation -Filter 'laszip.dll' -Recurse | 
      Where-Object {$_.FullName -match '\\laszip\\'}
   Copy-Item $dll.fullname $InstallPath
} else {
   throw "Chocolatey package $TargetPackage install location not found!"
}


