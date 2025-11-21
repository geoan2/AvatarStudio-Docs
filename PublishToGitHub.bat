@echo off
setlocal EnableDelayedExpansion
chcp 65001
cls
echo ========================================================
echo   PUBLISH DOCS TO GITHUB
echo ========================================================
echo.
echo This script will help you upload your documentation to GitHub.
echo Make sure you have created a NEW repository on GitHub.com first.
echo.

:: Check if Git is installed
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Git is NOT installed!
    echo.
    echo You need to download and install Git for Windows to use this script.
    echo Please download it here: https://git-scm.com/download/win
    echo.
    echo After installing, restart this script.
    pause
    exit /b
)

:: 1. Initialize Git
if not exist ".git" (
    echo [1/5] Initializing Git repository...
    git init
) else (
    echo [1/5] Git repository already initialized.
)

:: Configure Git Identity if missing
git config user.email >nul 2>nul
if %errorlevel% neq 0 (
    echo.
    echo [SETUP] Git needs to know who you are.
    echo Please enter your email (for GitHub history^):
    set /p gitEmail=Email: 
    git config user.email "!gitEmail!"
    
    echo Please enter your name:
    set /p gitName=Name: 
    git config user.name "!gitName!"
)

:: 2. Add files
echo [2/5] Adding files...
git add .

:: 3. Commit
echo [3/5] Committing files...
git commit -m "Update documentation"

:: 4. Remote URL
echo.
echo [4/5] Setup Remote...
echo Please paste your GitHub Repository URL (e.g. https://github.com/User/Repo.git)
echo and press ENTER:
set /p repoUrl=URL: 

if "%repoUrl%"=="" (
    echo Error: URL cannot be empty.
    pause
    exit /b
)

:: Remove old origin if exists
git remote remove origin 2>nul
git remote add origin %repoUrl%

:: 5. Push
echo.
echo [5/5] Pushing to GitHub...
git branch -M main
git push -u origin main

if !errorlevel! neq 0 (
    echo.
    echo [WARNING] GitHub rejected the push. 
    echo This usually happens if you created the repository with a README or License file.
    echo.
    echo We will now FORCE overwrite the GitHub repository with your local files.
    echo This will make your local documentation the source of truth.
    echo.
    echo Press any key to confirm FORCE PUSH...
    pause
    
    :: Re-ensure remote exists just in case
    git remote add origin !repoUrl! >nul 2>nul
    
    git push -u origin main --force
)

echo.
echo ========================================================
if %errorlevel% equ 0 (
    echo   SUCCESS! Your docs are on GitHub.
    echo   Now go to Settings -> Pages and enable GitHub Pages.
) else (
    echo   ERROR! Something went wrong. Please check the error message above.
)
echo ========================================================
pause
