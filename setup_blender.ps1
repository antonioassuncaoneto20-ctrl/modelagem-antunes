$ErrorActionPreference = "Stop"

$installRoot = Join-Path $env:LOCALAPPDATA "modelagem-antunes\blender-5.2.2"
$executablePath = Join-Path $installRoot "blender.exe"
if (Test-Path $executablePath) {
    Write-Output "Blender portátil já está disponível em $executablePath"
    exit 0
}

$archivePath = Join-Path $env:TEMP "blender-5.2.2-$PID.zip"
$stagingRoot = Join-Path $env:TEMP "b52-$PID"
$downloadUrl = "https://download.blender.org/release/Blender5.2/blender-5.2.2-windows-x64.zip"
$expectedHash = "3849d17a682cba006075aaa3f3597ecb5c9c30ec31035b2e092c53e40679b535"

try {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $archivePath -UseBasicParsing
    $actualHash = (Get-FileHash -LiteralPath $archivePath -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actualHash -ne $expectedHash) {
        throw "O SHA-256 do pacote Blender não corresponde ao publicado oficialmente."
    }

    Expand-Archive -LiteralPath $archivePath -DestinationPath $stagingRoot
    $blenderExecutable = Get-ChildItem -LiteralPath $stagingRoot -Filter "blender.exe" -File -Recurse |
        Select-Object -First 1
    if (-not $blenderExecutable) {
        throw "O pacote baixado não contém blender.exe."
    }

    New-Item -ItemType Directory -Path $installRoot -Force | Out-Null
    Get-ChildItem -LiteralPath $blenderExecutable.DirectoryName -Force |
        ForEach-Object { Move-Item -LiteralPath $_.FullName -Destination $installRoot -Force }
    if (-not (Test-Path $executablePath)) {
        throw "Não foi possível instalar o Blender portátil."
    }
    Write-Output "Blender 5.2.2 portátil configurado em $executablePath"
}
finally {
    if (Test-Path $archivePath) {
        Remove-Item -LiteralPath $archivePath -Force
    }
    if (Test-Path $stagingRoot) {
        Remove-Item -LiteralPath $stagingRoot -Recurse -Force
    }
}
