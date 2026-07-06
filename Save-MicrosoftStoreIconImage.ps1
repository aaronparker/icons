<#
    Download an icon in PNG format for an application from the Microsoft Store
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [ValidateScript({ if ((Test-Path -Path $_ -PathType "Leaf")) { $true } else { throw "Path not found: '$_'" } })]
    [System.String] $InputFile = "$PSScriptRoot\StoreApps.txt",

    [Parameter(Mandatory = $false)]
    [ValidateScript({ if ((Test-Path -Path $_ -PathType "Container")) { $true } else { throw "Path not found: '$_'" } })]
    [System.String] $OutputPath = "$PSScriptRoot\icons",

    [Parameter(Mandatory = $false)]
    [System.String] $StoreSearchUrl = "https://apps.microsoft.com/api/products/search?query="
)

# Configure the environment
$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
$InformationPreference = [System.Management.Automation.ActionPreference]::Continue
$ProgressPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

# Read the list of Store apps in the input file
# The file must include a list of Store apps as they appear in the store, one line per application
$AppsList = Get-Content -Path $InputFile

# Loop through the list of Store apps and download the icon if it's not already in the repo
foreach ($App in $AppsList) {
    $IconFile = [System.IO.Path]::Combine($OutputPath, "MicrosoftStore-$($App -replace '\s', '').png")
    if (Test-Path -Path $IconFile -PathType "Leaf") {
        # If the icon is already in the repo, skip download
        Write-Verbose -Message "Icon exists: '$IconFile'"
        continue
    }
    else {
        Write-Verbose -Message "Icon does not exist: '$IconFile'"
        Write-Verbose -Message "Search for icon for app: '$App'"

        # Search for the application
        $SearchUrl = "$StoreSearchUrl$($App -replace '\s', '+')&mediaType=apps&age=all&price=all&category=all&subscription=all&gl=US&hl=en-US"
        $params = @{
            Uri             = $SearchUrl
            UseBasicParsing = $true
        }
        $Search = Invoke-RestMethod @params
        
        # Find the icon URL for the application
        if ([System.String]::IsNullOrEmpty($Search.highlightedList.iconUrl)) {
            $Product = $Search.productsList | Where-Object { $_.title -eq $App }
            $IconUrl = $Product.iconUrl
        }
        else {
            $IconUrl = $Search.highlightedList.iconUrl
        }

        if ([System.String]::IsNullOrEmpty($IconUrl)) {
            Write-Warning -Message "Icon URL is empty for app: '$App'"
        }
        else {
            # If we get a result, download the icon for the app
            $params = @{
                Uri             = $IconUrl
                OutFile         = $IconFile
                UseBasicParsing = $true
            }
            Invoke-WebRequest @params
        }
    }
}
