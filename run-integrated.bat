@echo off
echo ================================================
echo  Roguelike ^& Subscribe - INTEGRATED GAME
echo  Complete game with all Week 0-3 systems
echo ================================================
echo.
echo This runs the FULL integrated game with:
echo   - State machine (Menu/Setup/Gameplay/Results/Shop)
echo   - Save/Load system
echo   - Roguelike progression (Subscribe theme)
echo   - All Week 1-3 physics and gameplay
echo.

REM Temporarily rename main.lua and use main_integrated.lua
if exist main.lua.backup del main.lua.backup
if exist main.lua ren main.lua main.lua.backup
copy main_integrated.lua main.lua >nul

REM Try common Love2D installation paths
if exist "C:\Program Files\LOVE\love.exe" (
    echo Using Love2D from: C:\Program Files\LOVE\love.exe
    "C:\Program Files\LOVE\love.exe" . --console
    goto :cleanup
)

if exist "C:\Program Files (x86)\LOVE\love.exe" (
    echo Using Love2D from: C:\Program Files (x86)\LOVE\love.exe
    "C:\Program Files (x86)\LOVE\love.exe" . --console
    goto :cleanup
)

REM Try PATH
love . --console 2>nul
if %errorlevel% == 0 goto :cleanup

REM If nothing works, show error
echo.
echo ERROR: Love2D not found!
echo Please install Love2D from: https://love2d.org/
echo.
pause

:cleanup
REM Restore original main.lua
if exist main.lua del main.lua
if exist main.lua.backup ren main.lua.backup main.lua
echo.
echo Integrated game closed.
pause
