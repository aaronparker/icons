<#
    .SYNOPSIS
        Tests script.
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
[CmdletBinding()]
param()

If (Test-Path -Path env:GITHUB_WORKSPACE -ErrorAction "SilentlyContinue") {
    $projectRoot = Resolve-Path -Path $env:GITHUB_WORKSPACE
}
Else {
    # Local Testing
    $projectRoot = Resolve-Path -Path (((Get-Item (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)).Parent).FullName)
}
If (Get-Variable -Name "projectRoot" -ErrorAction "SilentlyContinue") {

    # Configure the test environment
    $testsPath = Join-Path -Path $projectRoot -ChildPath "tests"
    $testOutput = Join-Path -Path $projectRoot -ChildPath "TestsResults.xml"
    $testConfig = [PesterConfiguration] @{
        Run        = @{
            Path     = $testsPath
            PassThru = $True
        }
        TestResult = @{
            OutputFormat = "NUnitXml"
            OutputFile   = $testOutput
        }
        Show = "Default"
    }
    Write-Host "Tests path:      $testsPath."
    Write-Host "Output path:     $testOutput."

    # Invoke Pester tests
    Invoke-Pester -Configuration $testConfig
}
Else {
    Write-Warning -Message "Required variable does not exist: projectRoot."
}

# Line break for readability in console
Write-Host ""
