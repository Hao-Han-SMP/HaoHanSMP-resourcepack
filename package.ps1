$DirName = Split-Path -Leaf $PWD
$OutputDir = "out"

if (!(Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

$OutputName = Join-Path $OutputDir "$DirName.zip"

if (Test-Path $OutputName) {
    Remove-Item $OutputName -Force
}

$FilesToZip = @()
if (Test-Path "assets") { $FilesToZip += "assets" }
if (Test-Path "pack.mcmeta") { $FilesToZip += "pack.mcmeta" }
if (Test-Path "pack.png") { $FilesToZip += "pack.png" }
if (Test-Path "LICENSE") { $FilesToZip += "LICENSE" }
if (Test-Path "README.md") { $FilesToZip += "README.md" }

if ($FilesToZip.Count -eq 0) {
    Write-Error "Error: No resource pack files found to package!"
    exit 1
}

Write-Host "Packaging resource pack..."
Compress-Archive -Path $FilesToZip -DestinationPath $OutputName -Force
Write-Host "Successfully packaged: $OutputName"
