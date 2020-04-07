#NOTE: Please remove any commented lines to tidy up prior to releasing the package, including this one

$packageName = 'net-speed-monitor' # arbitrary name for the package, used in messages
$installerType = 'msi' #only one of these: exe, msi, msu
$url = 'http://www.floriangilles.com/download-netspeedmonitor-2-5-4-0-x86' # download url
$url64 = 'http://www.floriangilles.com/download-netspeedmonitor-2-5-4-0-x64' # 64bit URL here or remove - if installer decides, then use $url
$silentArgs = '/quiet' # "/s /S /q /Q /quiet /silent /SILENT /VERYSILENT" # try any of these to get the silent installer #msi is always /quiet
$validExitCodes = @(0) #please insert other valid exit codes here, exit codes for ms http://msdn.microsoft.com/en-us/library/aa368542(VS.85).aspx

# main helpers - these have error handling tucked into them already
# installer, will assert administrative rights

 function Install-ChocolateyPackage() {
    [cmdletbinding(SupportsShouldProcess=$True)]
    Param(
        [Parameter(ValueFromPipeline = $true, Position = 0)]
        [string[]] $Packages,
        [Alias("f")]
        [switch] $Force,
        [Alias("y")]
        [switch] $Accept,
        [switch] $Pre,
        [string] $Version,
        [Alias("s")]
        [string] $Source,
        [Alias("u")]
        [string] $User,
        [Alias("p")]
        [string] $Password,
        [Alias("n")]
        [switch] $NoInstall,
        [Alias("m")]
        [switch] $Multiple,
        [switch] $Upgrade,
        [string[]] $Params,
        [string[]] $InstallerArgs
    )

    Process {
        if(! (Test-Path Env:\ChocolateyInstall)) {
            Write-Warning "Chocolatey is not installed or the ChocolateyInstall environment variable is missing."
            Write-Warning "Verify that chocolatey is installed and that ChocolateyInstall exists in your environment variables."
            return;
        }


        $Updates = @()
        $shouldUpdate = $Upgrade.ToBool();

        if($Packages -eq $Null -or $Packages.Length -eq 0) {
            $package = Read-Host -Prompt "Enter Package Name"
            if([string]::IsNullOrWhiteSpace($package)) {
                Write-Warning "PackageName was empty. Exiting operation. =("
                return;
            }

            $Packages = @($package);
        }
        
        $f = $Force.ToBool();

        if(!$f)
        {
            if($Packages -ne $null -and $Packages.Length -gt 0) {
                $copy = @();
                foreach($packageName in $Packages) {
                    if(Test-ChocolateyPackagePath -PackageName $packageName -Multiple:$Multiple) {
                        if(!$shouldUpdate) {
                           Write-Warning "$packageName is already installed. Use the Update-ChocopateyPackage command or -Force parameter to force the install.";
                        } else {
                            $Updates += $packageName;
                        }                       
                    } else {
                        $copy += $packageName;
                    }
                }
                $Packages = $copy;
            }
        }

        $d = $PSBoundParameters.Debug.IsPresent;
        $v = $PSBoundParameters.Verbose.IsPresent;
        $whatIf = $PSBoundParameters.WhatIf.IsPresent;
        $yes = $Accept.ToBool()
    
        if($yes -eq $false) {
            $yes = Get-ChocolateyAccept;
        }

        $flags = "";
        if($yes -or $f) {
            $flags += "y"
        }

        if($f) {
            $flags += "f";
        }

        if($d) {
            $flags += "d";
        }

        if($v) {
            $flags += "v";
        }

        if($NoInstall.ToBool()) {
            $flags += "n"
        }

        if($Multiple.ToBool()) {
            $flags += "m";
        }

        if($flags.Length -gt 0) {
            $flags = "-$flags";
        }
    
        if($Pre.ToBool()) {
            $flags += " --pre"
        }

        if(![string]::IsNullOrWhiteSpace($Source)) {
            $flags += " -s=`"$Source`""
        }

        if(![string]::IsNullOrWhiteSpace($User)) {
            $flags += " -u=`"$User`""
        }

        if(![string]::IsNullOrWhiteSpace($Password)) {
            $flags += " -p=`"$Password`""
        }

        if($whatIf) {
            $flags += " --whatif"
        }
        
        if($Params -ne $Null -and $Params.Length -gt 0) {
            $parameters = [String]::Join(" ", $Params);
            $flags += " --params=`"$parameters`""
        }

        if($InstallerArgs -ne $null -and $InstallerArgs.Length -gt 0) {
            $parameters = [String]::Join(" ", $InstallerArgs);
            $flags += " --installer-args=`"$parameters`""
        }

        foreach($packageName in $Packages) {
            $cmd = "$Env:ChocolateyInstall\choco.exe install $packageName $flags"

            if($PSCmdlet.ShouldProcess($cmd)) {
                & "$Env:ChocolateyInstall\choco.exe" install $packageName $flags
            }
        }

        foreach($packageName in $Updates) {
            $cmd = "$Env:ChocolateyInstall\choco.exe upgrade $packageName $flags"

            if($PSCmdlet.ShouldProcess($cmd)) {
               & "$Env:ChocolateyInstall\choco.exe" upgrade $packageName $flags
            }
        }
    }
}


# Set compatibility mode to Windows 7 if operating system is Windows 8 or higher.
# $WindowsVersion = (Get-WmiObject -class Win32_OperatingSystem).Version
# if ($WindowsVersion -ge "6.2.9200") {
#     if (-not (Test-Path "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers")) {
#         New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags" -Name Layers
#     }
#     New-ItemProperty -path "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" -propertyType String -Name "$env:temp\chocolatey\$packageName\$packageName`Install.$installerType" -value "~ WIN7RTM"
#     Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$url" "$url64"  -validExitCodes $validExitCodes
    
#     # Delete compatibility mode for ext2fsd installer, because it’s not needed anymore
#     Remove-ItemProperty -path "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" -Name "$env:temp\chocolatey\$packageName\$packageName`Install.$installerType"
# } else {
#     Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$url" "$url64"  -validExitCodes $validExitCodes
# }
