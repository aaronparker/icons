<#
    .SYNOPSIS
        Main Pester function tests.
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")]
[CmdletBinding()]
param()

BeforeDiscovery {
    # Set $VerbosePreference so full details are sent to the log; Make Invoke-WebRequest faster
    $VerbosePreference = "Continue"
    $ProgressPreference = "SilentlyContinue"

    # Get the scripts to test
    # Set variables
    if (Test-Path -Path env:GITHUB_WORKSPACE -ErrorAction "SilentlyContinue") {
        $projectRoot = Resolve-Path -Path $env:GITHUB_WORKSPACE
    }
    else {
        # Local Testing
        $projectRoot = Resolve-Path -Path (((Get-Item (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)).Parent).FullName)
    }
    $Icons = Join-Path $projectRoot "icons"
    $Images = Get-ChildItem -Path $Icons -Recurse -Include *.*
    $testCase = $Images | ForEach-Object { @{file = $_ } }

    # Add assembly so that we can use System.Drawing.Bitmap
    Add-Type -AssemblyName "System.Drawing"
}

#region Tests
Describe "Image format tests" -ForEach $Images {
    BeforeAll {
        # Renaming the automatic $_ variable to $application to make it easier to work with
        $Image = $_
    }

    Context "Validate <script.Name>." {
        It "<Image.Name> should be a .PNG file" {
            [IO.Path]::GetExtension($Image.Name) -match ".png" | Should -Be $True
        }
    }
}

Describe "Image dimension tests" -ForEach $Images {
    BeforeAll {
        # Renaming the automatic $_ variable to $application to make it easier to work with
        $Image = $_

        # Create a bitmap object so that we can determine dimensions
        $png = New-Object -TypeName "System.Drawing.Bitmap" $Image.FullName
    }

    Context "Validate <Image.Name> type" {
        It "<Image.Name> should be a .PNG file" {
            [IO.Path]::GetExtension($Image.Name) -match ".png" | Should -Be $True
        }
    }

    Context "Image dimensions should be valid" {
        It "$($Image.Name) should match height and width" {
            $png.Height -eq $png.Width | Should -Be $True
        }
        It "$($Image.Name) height should be 210 pixels or more" {
            $png.Height -ge 210 | Should -Be $True
        }
        It "$($Image.Name) width should be 210 pixels or more" {
            $png.Width -ge 210 | Should -Be $True
        }
    }
}
#endregion
