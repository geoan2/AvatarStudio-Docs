@echo off
setlocal EnableDelayedExpansion
chcp 65001
cls
echo ========================================================
echo   FORCE PUBLISH TO GITHUB (Hardcoded)
echo ========================================================
echo.

:: YOUR REPO URL
set "REPO_URL=https://github.com/geoan2/AvatarStudio-Docs.git"

echo Target Repository: !REPO_URL!
echo.

:: 1. Initialize
if not exist ".git" (
    git init
)

:: 2. Add & Commit
git add .
git commit -m "Force update documentation"

:: 3. Setup Remote
echo Setting up remote...
git remote remove origin 2>nul
git remote add origin "!REPO_URL!"

:: Verify remote
echo Verifying remote...
git remote -v

:: 4. Force Push
echo.
echo Pushing to GitHub (Force)...
git push -u origin main --force

echo.
if %errorlevel% equ 0 (
    echo SUCCESS! Documentation published.
) else (
    echo ERROR! Push failed.
)
echo.
pause
