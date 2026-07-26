@echo off
REM ===========================================================================
REM  DalamudPlugins - build, publish and push in one step.
REM
REM  Double-click to publish every plugin, or run from a terminal:
REM      publish.bat                 publish all plugins
REM      publish.bat HunterV2        publish a single plugin
REM
REM  Remember to bump <AssemblyVersion> in the plugin's .csproj first - Dalamud
REM  only offers an update when the version number increases.
REM ===========================================================================

setlocal EnableDelayedExpansion
cd /d "%~dp0"

REM Keep the window open at the end so a double-click doesn't flash and vanish.
REM Set PUBLISH_NOPAUSE=1 when calling this from another script or CI, otherwise
REM it will sit waiting on a keypress forever.
set "PAUSE_AT_END=1"
if defined PUBLISH_NOPAUSE set "PAUSE_AT_END="

echo ============================================
echo   DalamudPlugins publisher
echo ============================================
echo.

REM --- 1. Sync first -------------------------------------------------------
REM The download-count workflow commits repo.json on a schedule, so the remote
REM is often ahead. Rebasing BEFORE regenerating means the script reads the
REM current counts (instead of overwriting them with stale local zeroes) and
REM the push at the end will not be rejected.
echo [1/4] Syncing with GitHub...
git rev-parse --git-dir >nul 2>&1
if errorlevel 1 (
    echo   ERROR: not a git repository.
    goto :fail
)
REM --autostash: the script rewrites repo.json (LastUpdate) on every run, so the
REM working tree is almost always dirty by the time this runs again. Without it
REM the rebase aborts with "cannot pull with rebase: You have unstaged changes".
git pull --rebase --autostash origin main
if errorlevel 1 (
    echo.
    echo   ERROR: pull/rebase failed. Resolve conflicts, then run again.
    goto :fail
)
echo.

REM --- 2. Build and publish ------------------------------------------------
if "%~1"=="" (
    echo [2/4] Building and publishing ALL plugins...
    set "ARGS=-Publish"
) else (
    echo [2/4] Building and publishing %~1...
    set "ARGS=-Publish -Plugin %~1"
)
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "tools\Update-Repo.ps1" !ARGS!
if errorlevel 1 (
    echo.
    echo   ERROR: publish step failed. Nothing was committed.
    goto :fail
)
echo.

REM --- 3. Commit -----------------------------------------------------------
echo [3/4] Committing...
git add -A
git diff --cached --quiet
if not errorlevel 1 (
    echo   Nothing changed - repo.json and manifests are already up to date.
    goto :done
)

if "%~1"=="" (
    git commit -m "Update plugins"
) else (
    git commit -m "Update %~1"
)
if errorlevel 1 (
    echo   ERROR: commit failed.
    goto :fail
)
echo.

REM --- 4. Push -------------------------------------------------------------
echo [4/4] Pushing...
git push origin main
if errorlevel 1 (
    echo.
    echo   ERROR: push failed. Try running this script again.
    goto :fail
)

:done
echo.
echo ============================================
echo   Done.
echo   Dalamud picks up changes on its next
echo   repository refresh (/xlplugins, then the
echo   refresh button).
echo ============================================
if defined PAUSE_AT_END pause
endlocal
exit /b 0

:fail
echo.
echo ============================================
echo   FAILED - see the output above.
echo ============================================
if defined PAUSE_AT_END pause
endlocal
exit /b 1
