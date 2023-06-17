<#
    .SYNOPSIS
        Optimise icons
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")]
[CmdletBinding()]
param(
    [System.String] $Path
)

#region Functions
function Invoke-Process {
    <#PSScriptInfo
    .VERSION 1.4
    .GUID b787dc5d-8d11-45e9-aeef-5cf3a1f690de
    .AUTHOR Adam Bertram
    .COMPANYNAME Adam the Automator, LLC
    .TAGS Processes
    #>

    <#
    .DESCRIPTION
        Invoke-Process is a simple wrapper function that aims to "PowerShellyify" launching typical external processes. There
        are lots of ways to invoke processes in PowerShell with Start-Process, Invoke-Expression, & and others but none account
        well for the various streams and exit codes that an external process returns. Also, it's hard to write good tests
        when launching external processes.

        This function ensures any errors are sent to the error stream, standard output is sent via the Output stream and any
        time the process returns an exit code other than 0, treat it as an error.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $FilePath,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $ArgumentList
    )

    $ErrorActionPreference = 'Stop'

    try {
        $stdOutTempFile = "$env:TEMP\$((New-Guid).Guid)"
        $stdErrTempFile = "$env:TEMP\$((New-Guid).Guid)"

        $startProcessParams = @{
            FilePath               = $FilePath
            ArgumentList           = $ArgumentList
            RedirectStandardError  = $stdErrTempFile
            RedirectStandardOutput = $stdOutTempFile
            Wait                   = $true;
            PassThru               = $true;
            NoNewWindow            = $true;
        }
        if ($PSCmdlet.ShouldProcess("Process [$($FilePath)]", "Run with args: [$($ArgumentList)]")) {
            $cmd = Start-Process @startProcessParams
            $cmdOutput = Get-Content -Path $stdOutTempFile -Raw
            $cmdError = Get-Content -Path $stdErrTempFile -Raw
            if ($cmd.ExitCode -ne 0) {
                if ($cmdError) {
                    throw $cmdError.Trim()
                }
                if ($cmdOutput) {
                    throw $cmdOutput.Trim()
                }
            }
            else {
                if ([string]::IsNullOrEmpty($cmdOutput) -eq $false) {
                    Write-Output -InputObject $cmdOutput
                }
            }
        }
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
    finally {
        Remove-Item -Path $stdOutTempFile, $stdErrTempFile -Force -ErrorAction Ignore
    }
}
#endregion

#region Optimise images in icons
# Read in the existing hashes file
$ImageHashes = [System.IO.Path]::Combine($Path, "bin", "IconHashes.json")
if (Test-Path -Path $imageHashes) {
    $pngHashes = Get-Content -Path $ImageHashes | ConvertFrom-Json -ErrorAction "Stop"
}

# Get all images in the icons folder
$Images = Get-ChildItem -Path "$Path\icons" -Recurse -Include "*.png"
$cleanUp = @()

# Optimise each file if the hash does not match
foreach ($image in $Images) {
    $hash = Get-FileHash -Path $image.FullName

    if ($pngHashes.($image.Name) -ne $hash.Hash) {
        Write-Host "Optimising: $($image.Name)"

        $params = @{
            FilePath     = $([System.IO.Path]::Combine($Path, "bin", "pngout.exe"))
            ArgumentList = "$($image.FullName) /y /q /force"
        }
        $result = Invoke-Process @params

        if ($result -like "*Out:*") {
            $result
            if ([System.IO.Path]::GetExtension($image.Name) -notmatch ".png" ) {
                $cleanUp += $image.FullName
            }
        }
    }
    else {
        Write-Host "Hash matches. Skip optimisation: $($image.Name)"
    }
}

# Read the hashes from all PNG files and output to file for next run
$PngImages = Get-ChildItem -Path "$Path\icons" -Recurse -Include "*.png"
$PngHashes = @{}
foreach ($png in $PngImages) {
    $hash = Get-FileHash -Path $png.FullName
    $PngHashes.Add((Split-Path -Path $hash.Path -Leaf), $hash.Hash)
}
$PngHashes | ConvertTo-Json | Out-File -FilePath $ImageHashes -Force
#endregion



#region Optimise images in companyportal
# Read in the existing hashes file
$ImageHashes = [System.IO.Path]::Combine($Path, "bin", "CompanyPortalHashes.json")
if (Test-Path -Path $imageHashes) {
    $pngHashes = Get-Content -Path $ImageHashes | ConvertFrom-Json -ErrorAction "Stop"
}

# Get all images in the companyportal folder
$Images = Get-ChildItem -Path "$Path\companyportal" -Recurse -Include "*.png"
$cleanUp = @()

# Optimise each file if the hash does not match
foreach ($image in $Images) {
    $hash = Get-FileHash -Path $image.FullName

    if ($pngHashes.($image.Name) -ne $hash.Hash) {
        Write-Host "Optimising: $($image.Name)"

        $params = @{
            FilePath     = $([System.IO.Path]::Combine($Path, "bin", "pngout.exe"))
            ArgumentList = "$($image.FullName) /y /q /force"
        }
        $result = Invoke-Process @params

        if ($result -like "*Out:*") {
            $result
            if ([System.IO.Path]::GetExtension($image.Name) -notmatch ".png" ) {
                $cleanUp += $image.FullName
            }
        }
    }
    else {
        Write-Host "Hash matches. Skip optimisation: $($image.Name)"
    }
}

# Read the hashes from all PNG files and output to file for next run
$PngImages = Get-ChildItem -Path "$Path\companyportal" -Recurse -Include "*.png"
$PngHashes = @{}
foreach ($png in $PngImages) {
    $hash = Get-FileHash -Path $png.FullName
    $PngHashes.Add((Split-Path -Path $hash.Path -Leaf), $hash.Hash)
}
$PngHashes | ConvertTo-Json | Out-File -FilePath $ImageHashes -Force
#endregion
