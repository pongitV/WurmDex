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

$flutterCandidates = @(
    (Join-Path $projectRoot ".fvm\flutter_sdk\bin\flutter.bat"),
    (Join-Path $projectRoot "flutter\bin\flutter.bat"),
    "C:\SDKs\flutter\bin\flutter.bat"
)
if ($env:FLUTTER_ROOT) {
    $flutterCandidates += Join-Path $env:FLUTTER_ROOT "bin\flutter.bat"
}
if ($env:USERPROFILE) {
    $flutterCandidates += Join-Path $env:USERPROFILE "develop\flutter\bin\flutter.bat"
    $flutterCandidates += Join-Path $env:USERPROFILE "flutter\bin\flutter.bat"
}
$flutterCandidates += @(
    "C:\src\flutter\bin\flutter.bat",
    "C:\flutter\bin\flutter.bat",
    "D:\flutter\bin\flutter.bat"
)

$flutterCommand = Get-Command flutter -ErrorAction SilentlyContinue
if ($flutterCommand) {
    $flutterCmd = $flutterCommand.Source
} else {
    $flutterCmd = $flutterCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
}

if (-not $flutterCmd) {
    Write-Error "Flutter SDK nao foi encontrado. Adicione flutter ao PATH, defina FLUTTER_ROOT ou instale-o em um local comum."
    exit 1
}

Write-Host "Flutter encontrado em: $flutterCmd" -ForegroundColor DarkGray

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
