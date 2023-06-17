
Get-ChildItem -Path ".\icons" -Include "*.png" -Recurse | ForEach-Object { 
    $ImgPath = $_.FullName
    $Img = [System.Drawing.Image]::FromFile($_.FullName)
    $ImgHeight = $Img.Height
    $ImgWidth = $Img.Width
    $Img.Dispose()

    [PSCustomObject]@{
        Name = $ImgPath
        Height = $ImgHeight
        Width = $ImgWidth
    } | Export-Csv -Path ".\icondimensions.csv" -Append -NoTypeInformation
}


using namespace System.Drawing
[Reflection.Assembly]::LoadFile("$Env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\System.Drawing.dll")
[Reflection.Assembly]::LoadFile("/Users/aaron/.local/share/PackageManagement/NuGet/Packages/runtime.osx.10.10-x64.CoreCompat.System.Drawing.6.0.5.128/lib/netstandard2.0/runtime.osx.10.10-x64.CoreCompat.System.Drawing.dll")

convert Microsoft-Edge.png -resize 50% Microsoft-Edge.png
convert Microsoft-Edge.png -gravity center -background transparent -extent 1024x1024 Microsoft-Edge.png
convert Microsoft-Edge.png -resize 50% Microsoft-Edge.png

$BinPath = Get-ItemProperty -Path "HKLM:\SOFTWARE\ImageMagick\Current" | Select-Object -ExpandProperty "BinPath"

# Install-Package runtime.osx.10.10-x64.CoreCompat.System.Drawing -scope CurrentUser
Get-ChildItem -Path $PWD -Include "*.png" -Recurse | ForEach-Object { 
    $ImgPath = $_.FullName
    $Img = [System.Drawing.Image]::FromFile($_.FullName)
    $ImgHeight = $Img.Height
    #$ImgWidth = $Img.Width
    $Img.Dispose()

    switch ($ImgHeight) {
        { $_ -gt 1024 } {
            & "$BinPath\magick.exe" $ImgPath -resize 384x384 $ImgPath
            & "$BinPath\magick.exe" $ImgPath -gravity center -background transparent -extent 768x768 $ImgPath
            & "$BinPath\magick.exe" $ImgPath -resize 512x512 $ImgPath
        }
        1024 {
            & "$BinPath\magick.exe" $ImgPath -resize 384x384 $ImgPath
            & "$BinPath\magick.exe" $ImgPath -gravity center -background transparent -extent 768x768 $ImgPath
            & "$BinPath\magick.exe" $ImgPath -resize 512x512 $ImgPath
        }
        768 {
            & "$BinPath\magick.exe" $ImgPath -resize 384x384 $ImgPath
            & "$BinPath\magick.exe" $ImgPath -gravity center -background transparent -extent 768x768 $ImgPath
            & "$BinPath\magick.exe" $ImgPath -resize 512x512 $ImgPath
        }
        512 {
            & "$BinPath\magick.exe" $ImgPath -resize 384x384 $ImgPath
            & "$BinPath\magick.exe" $ImgPath -gravity center -background transparent -extent 768x768 $ImgPath
            & "$BinPath\magick.exe" $ImgPath -resize 512x512 $ImgPath
        }
        384 {
            & "$BinPath\magick.exe" $ImgPath -gravity center -background transparent -extent 768x768 $ImgPath
            & "$BinPath\magick.exe" $ImgPath -resize 512x512 $ImgPath
        }
        256 {
            & "$BinPath\magick.exe" $ImgPath -gravity center -background transparent -extent 512x512 $ImgPath
        }
        { $_ -lt 256 } {
            "Skip image resize < 256, $ImgPath"
        }
        default {
            "What, $ImgPath"
        }
    }
}
