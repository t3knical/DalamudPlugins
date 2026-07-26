@echo off
REM ---------------------------------------------------------------------------
REM  Build, package, publish GitHub releases, regenerate repo.json, then push.
REM  A cmd.exe wrapper around tools\Update-Repo.ps1 for those who don't live in
REM  PowerShell.
REM
REM  Usage:
REM    tools\publish.cmd              publish every plugin
REM    tools\publish.cmd HunterV2     publish a single plugin
REM
REM  Remember to bump <AssemblyVersion> in the plugin's .csproj first - Dalamud
REM  only offers an update when the version increases.
REM ---------------------------------------------------------------------------

setlocal
REM Run from the repo root regardless of where this was invoked from
cd /d "%~dp0.."

set "PS=powershell -NoProfile -ExecutionPolicy Bypass -File tools\Update-Repo.ps1"

if "%~1"=="" (
    echo Publishing all plugins...
    %PS% -Publish
) else (
    echo Publishing %~1...
    %PS% -Publish -Plugin "%~1"
)
if errorlevel 1 goto :fail

echo.
echo Committing...
git add -A
git diff --cached --quiet
if not errorlevel 1 (
    echo Nothing to commit - repo.json and manifests are unchanged.
    goto :done
)

git commit -m "Update plugins"
if errorlevel 1 goto :fail

git push
if errorlevel 1 goto :fail

:done
echo.
echo Done. Dalamud will pick up the new version on its next repository refresh.
endlocal
exit /b 0

:fail
echo.
echo FAILED - see the output above. Nothing was pushed.
endlocal
exit /b 1
