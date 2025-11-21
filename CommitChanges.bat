@echo off
chcp 65001
echo ========================================================
echo   COMMIT DOCUMENTATION CHANGES
echo ========================================================
echo.

cd /d "%~dp0"

"C:\Program Files\Git\bin\git.exe" add -A
echo Files staged for commit.
echo.

"C:\Program Files\Git\bin\git.exe" commit -m "Comprehensive runtime systems documentation: Added runtime_systems.md (Quest/Dialogue/Faction/Spawn managers), enhanced tab_npcs.md with detailed Gaze System (3 zones, 4 player modes), enhanced technical_reference.md with Interaction System, Player Character, and Save System. Removed 5 outdated files."

if %errorlevel% equ 0 (
    echo.
    echo ========================================================
    echo   SUCCESS! Changes committed to Git.
    echo   Now you can push to GitHub with: git push
    echo ========================================================
) else (
    echo.
    echo ========================================================
    echo   ERROR! Something went wrong.
    echo ========================================================
)

echo.
pause
