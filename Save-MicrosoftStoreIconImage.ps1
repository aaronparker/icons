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
    [System.String] $StoreSearchUrl = "https://apps.microsoft.com/store/api/Products/GetFilteredSearch?hl=en-gb&gl=AU&FilteredCategories=AllProducts&Query="
)

# Don't show a progress bar for Invoke-WebRequest and Invoke-RestMethod
$ProgressPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

# Read the list of Store apps in the input file
# The file must include a list of Store apps as they appear in the store, one line per application
$AppsList = Get-Content -Path $InputFile -ErrorAction "Stop"

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
        $SearchUrl = "$StoreSearchUrl$($App -replace '\s', '%20')"
        $params = @{
            Uri             = $SearchUrl
            UseBasicParsing = $true
            ErrorAction     = "Stop"
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
                ErrorAction     = "Stop"
            }
            Invoke-WebRequest @params
        }
    }
}
