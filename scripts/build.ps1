param(
    [ValidateSet("windows", "apk", "all")]
    [string]$Platform = "all"
)

$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host "          WURMDEX - BUILD AUTOMATIZADO" -ForegroundColor Cyan
Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host ""

$flutterCmd = "flutter"
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    if (Test-Path "D:\flutter\bin\flutter.bat") {
        $flutterCmd = "D:\flutter\bin\flutter.bat"
    } else {
        Write-Error "Flutter SDK nao foi encontrado no PATH nem em D:\flutter\bin\flutter.bat"
        exit 1
    }
}

$distDir = Join-Path $projectRoot "dist"
$windowsDist = Join-Path $distDir "windows"
$androidDist = Join-Path $distDir "android"

New-Item -ItemType Directory -Force -Path $windowsDist | Out-Null
New-Item -ItemType Directory -Force -Path $androidDist | Out-Null

function Build-Windows {
    Write-Host "`n[Windows] Compilando executavel nativo Windows Desktop..." -ForegroundColor Yellow
    & $flutterCmd build windows --release
    if ($LASTEXITCODE -eq 0) {
        $sourceDir = Join-Path $projectRoot "build\windows\x64\runner\Release"
        if (Test-Path $sourceDir) {
            Copy-Item -Path "$sourceDir\*" -Destination $windowsDist -Recurse -Force
            Write-Host "[SUCESSO] Executavel disponivel em: dist\windows\wurmdex.exe" -ForegroundColor Green
        }
    } else {
        Write-Warning "Falha na compilacao do Windows Desktop."
    }
}

function Build-Android {
    Write-Host "`n[Android] Compilando pacote Android (.apk)..." -ForegroundColor Yellow
    & $flutterCmd build apk --release
    if ($LASTEXITCODE -eq 0) {
        $apkSource = Join-Path $projectRoot "build\app\outputs\flutter-apk\app-release.apk"
        if (Test-Path $apkSource) {
            Copy-Item -Path $apkSource -Destination (Join-Path $androidDist "WurmDex-release.apk") -Force
            Write-Host "[SUCESSO] APK disponivel em: dist\android\WurmDex-release.apk" -ForegroundColor Green
        }
    } else {
        Write-Warning "Falha na compilacao do APK do Android."
    }
}

switch ($Platform) {
    "windows" { Build-Windows }
    "apk"     { Build-Android }
    "all"     {
        Build-Windows
        Build-Android
    }
}

Write-Host "`n=======================================================" -ForegroundColor Cyan
Write-Host "   Arquivos prontos em:" -ForegroundColor Cyan
Write-Host "   - Windows Desktop: $windowsDist\wurmdex.exe" -ForegroundColor White
Write-Host "   - Android Package: $androidDist\WurmDex-release.apk" -ForegroundColor White
Write-Host "=======================================================`n" -ForegroundColor Cyan
