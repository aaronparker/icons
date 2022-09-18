<#
    .SYNOPSIS
        Tests script.
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
[CmdletBinding()]
param()

if (Test-Path -Path env:GITHUB_WORKSPACE -ErrorAction "SilentlyContinue") {
    $projectRoot = Resolve-Path -Path $env:GITHUB_WORKSPACE
}
else {
    # Local Testing
    $projectRoot = Resolve-Path -Path (((Get-Item (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)).Parent).FullName)
}
if (Get-Variable -Name "projectRoot" -ErrorAction "SilentlyContinue") {

    # Configure the test environment
    $Config = [PesterConfiguration]::Default
    $Config.Run.Path = "$projectRoot\tests"
    $Config.Run.PassThru = $True
    $Config.TestResult.Enabled = $True
    $Config.TestResult.OutputFormat = "NUnitXml"
    $Config.TestResult.OutputPath = "$projectRoot\TestsResults.xml"
    Invoke-Pester -Configuration $testConfig
}
else {
    Write-Warning -Message "Required variable does not exist: projectRoot."
}

# Line break for readability in console
Write-Host ""
