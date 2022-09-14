<#
    .SYNOPSIS
        Install script.
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
[CmdletBinding()]
param()

# Set variables
If (Test-Path -Path env:GITHUB_WORKSPACE -ErrorAction "SilentlyContinue") {
    $projectRoot = Resolve-Path -Path $env:GITHUB_WORKSPACE
}
Else {
    # Local Testing
    $projectRoot = Resolve-Path -Path (((Get-Item (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)).Parent).FullName)
}
$tests = Join-Path $projectRoot "tests"
$output = Join-Path $projectRoot "TestsResults.xml"

# Echo variables
Write-Host ""
Write-Host "OS version:      $((Get-CimInstance -ClassName "CIM_OperatingSystem").Caption)"
Write-Host ""
Write-Host "ProjectRoot:     $projectRoot."
Write-Host "Tests path:      $tests."
Write-Host "Output path:     $output."

# Line break for readability in console
Write-Host ""
Write-Host "PowerShell Version:" $PSVersionTable.PSVersion.ToString()

# Install packages
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-PackageProvider -Name "NuGet" -MinimumVersion "2.8.5.208" -Force -ErrorAction "SilentlyContinue"
If (Get-PSRepository -Name "PSGallery" | Where-Object { $_.InstallationPolicy -ne "Trusted" }) {
    Set-PSRepository -Name "PSGallery" -InstallationPolicy "Trusted"
}

# Install modules
$Modules = "Pester", "posh-git"
ForEach ($Module in $Modules ) {
    If ([System.Version]((Find-Module -Name $Module).Version) -gt (Get-Module -Name $Module).Version) {
        Install-Module -Name $Module -SkipPublisherCheck -Force #-MaximumVersion "4.10.1"
    }
    Import-Module -Name $Module -Force
}
