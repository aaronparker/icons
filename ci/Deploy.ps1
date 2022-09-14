<#
    .SYNOPSIS
        Update version number and push to GitHub
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
[CmdletBinding()]
param()

# Line break for readability in the console
Write-Host ""

If (Test-Path -Path env:GITHUB_WORKSPACE -ErrorAction "SilentlyContinue") {
    $projectRoot = Resolve-Path -Path $env:GITHUB_WORKSPACE
}
Else {
    # Local Testing
    $projectRoot = Resolve-Path -Path (((Get-Item (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)).Parent).FullName)
}

# Publish the new version back to Main on GitHub
try {
    # Set up a path to the git.exe cmd, import posh-git to give us control over git
    $env:Path += ";$env:ProgramFiles\Git\cmd"
    Import-Module posh-git -ErrorAction "Stop"

    # Dot source Invoke-Process.ps1. Prevent 'RemoteException' error when running specific git commands
    . $projectRoot\ci\Invoke-Process.ps1

    # Configure the git environment
    git config --global credential.helper store
    git remote set-url --push origin "https://$($env:GITHUB_ACTOR):$($env:GITHUB_TOKEN)@github.com/$($env:GITHUB_REPOSITORY).git"
    git config receive.advertisePushOptions true
    git config --global core.autocrlf true
    git config --global core.safecrlf false

    # Push changes to GitHub
    Invoke-Process -FilePath "git" -ArgumentList "checkout main"
    git add --all
    git status
    git commit -s -m "Compress images"
    Invoke-Process -FilePath "git" -ArgumentList "push origin main"
}
catch {
    # Sad panda; it broke
    Write-Warning -Message "Push to GitHub failed."
    Throw $_
}

# Line break for readability in console
Write-Host ""
