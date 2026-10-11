# PowerShell script to sync generated ModelEngine resource pack into HaoHan-Resourcepack
$Source = "F:\.TestServer\plugins\ModelEngine\resource pack"
$Dest = "F:\.HaoHanProject\HaoHan-Resourcepack"

if (!(Test-Path $Source)) {
    Write-Error "ModelEngine resource pack folder not found: $Source"
    exit 1
}

Write-Host "Syncing ModelEngine assets to HaoHan-Resourcepack..."

# 1. Sync assets/modelengine (models, textures, items)
$meAssetsSrc = Join-Path $Source "assets\modelengine"
$meAssetsDst = Join-Path $Dest "assets\modelengine"
if (Test-Path $meAssetsSrc) {
    Copy-Item -Path "$meAssetsSrc\*" -Destination $meAssetsDst -Recurse -Force
    Write-Host "  [OK] Copied assets/modelengine"
}

# 2. Sync leather_horse_armor models and item definitions
$lhaModelSrc = Join-Path $Source "assets\minecraft\models\item\leather_horse_armor.json"
$lhaModelDst = Join-Path $Dest "assets\minecraft\models\item\leather_horse_armor.json"
if (Test-Path $lhaModelSrc) {
    Copy-Item -Path $lhaModelSrc -Destination $lhaModelDst -Force
    Write-Host "  [OK] Copied models/item/leather_horse_armor.json"
}

$lhaItemSrc = Join-Path $Source "assets\minecraft\items\leather_horse_armor.json"
$lhaItemDst = Join-Path $Dest "assets\minecraft\items\leather_horse_armor.json"
if (Test-Path $lhaItemSrc) {
    Copy-Item -Path $lhaItemSrc -Destination $lhaItemDst -Force
    Write-Host "  [OK] Copied items/leather_horse_armor.json"
}

# 3. Clean up obsolete claymore models if any
$obsoleteMui = Join-Path $Dest "assets\modelengine\models\claymore\mui_kiem.json"
$obsoleteSong = Join-Path $Dest "assets\modelengine\models\claymore\song_kiem.json"
if (Test-Path $obsoleteMui) { Remove-Item $obsoleteMui -Force }
if (Test-Path $obsoleteSong) { Remove-Item $obsoleteSong -Force }

Write-Host "Sync completed successfully!"
