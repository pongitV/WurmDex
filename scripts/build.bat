@echo off
setlocal enabledelayedexpansion

rem Change directory to project root
cd /d "%~dp0\.."

echo =======================================================
echo          WURMDEX - BUILD AUTOMATIZADO
echo =======================================================
echo.

set TARGET=%1
if "%TARGET%"=="" set TARGET=all

rem Locate Flutter executable. The project-local .fvm SDK is checked first,
rem followed by PATH, FLUTTER_ROOT and common Windows installation paths.
if exist ".fvm\flutter_sdk\bin\flutter.bat" (
    set "FLUTTER_CMD=%CD%\.fvm\flutter_sdk\bin\flutter.bat"
) else if exist "flutter\bin\flutter.bat" (
    set "FLUTTER_CMD=%CD%\flutter\bin\flutter.bat"
) else if exist "C:\SDKs\flutter\bin\flutter.bat" (
    set "FLUTTER_CMD=C:\SDKs\flutter\bin\flutter.bat"
) else if defined FLUTTER_ROOT if exist "%FLUTTER_ROOT%\bin\flutter.bat" (
    set "FLUTTER_CMD=%FLUTTER_ROOT%\bin\flutter.bat"
) else (
    where flutter >nul 2>nul
    if %ERRORLEVEL% equ 0 (
        for /f "delims=" %%F in ('where flutter') do if not defined FLUTTER_CMD set "FLUTTER_CMD=%%F"
    ) else if exist "%USERPROFILE%\develop\flutter\bin\flutter.bat" (
        set "FLUTTER_CMD=%USERPROFILE%\develop\flutter\bin\flutter.bat"
    ) else if exist "%USERPROFILE%\flutter\bin\flutter.bat" (
        set "FLUTTER_CMD=%USERPROFILE%\flutter\bin\flutter.bat"
    ) else if exist "C:\src\flutter\bin\flutter.bat" (
        set "FLUTTER_CMD=C:\src\flutter\bin\flutter.bat"
    ) else if exist "C:\flutter\bin\flutter.bat" (
        set "FLUTTER_CMD=C:\flutter\bin\flutter.bat"
    ) else if exist "D:\flutter\bin\flutter.bat" (
        set "FLUTTER_CMD=D:\flutter\bin\flutter.bat"
    )
)

if defined FLUTTER_CMD goto FLUTTER_FOUND
echo [ERRO] Flutter SDK nao encontrado. Adicione flutter ao PATH, defina FLUTTER_ROOT ou instale-o em um local comum.
exit /b 1

:FLUTTER_FOUND
echo Flutter encontrado em: %FLUTTER_CMD%

rem The old PATH fallback is intentionally not repeated here.
rem Create distribution directories
if not exist "dist\windows" mkdir "dist\windows"
if not exist "dist\android" mkdir "dist\android"

if "%TARGET%"=="windows" goto BUILD_WINDOWS
if "%TARGET%"=="apk" goto BUILD_APK
if "%TARGET%"=="all" goto BUILD_ALL

echo Opcao invalida! Use: build.bat [windows ^| apk ^| all]
exit /b 1

:BUILD_ALL
call :BUILD_WINDOWS
call :BUILD_APK
goto FINISHED

:BUILD_WINDOWS
echo.
echo [1/2] Compilando executavel nativo para Windows Desktop...
call "%FLUTTER_CMD%" build windows --release
if %ERRORLEVEL% equ 0 (
    echo [OK] Sincronizando para dist\windows\...
    xcopy /E /I /Y "build\windows\x64\runner\Release\*" "dist\windows\" >nul 2>nul
    echo [SUCESSO] Executavel gerado em: dist\windows\wurmdex.exe
) else (
    echo [AVISO] Build Windows encontrou pendencias.
)
if "%TARGET%"=="windows" goto FINISHED
exit /b 0

:BUILD_APK
echo.
echo [2/2] Compilando pacote Android (.apk)...
call "%FLUTTER_CMD%" build apk --release
if %ERRORLEVEL% equ 0 (
    echo [OK] Sincronizando para dist\android\...
    copy /Y "build\app\outputs\flutter-apk\app-release.apk" "dist\android\WurmDex-release.apk" >nul 2>nul
    echo [SUCESSO] APK gerado em: dist\android\WurmDex-release.apk
) else (
    echo [AVISO] Build APK encontrou pendencias.
)
if "%TARGET%"=="apk" goto FINISHED
exit /b 0

:FINISHED
echo.
echo =======================================================
echo   BUILDS CONCLUIDOS! ARQUIVOS DISPONIVEIS EM:
echo   - Windows: dist\windows\wurmdex.exe
echo   - Android: dist\android\WurmDex-release.apk
echo =======================================================
echo.
exit /b 0
