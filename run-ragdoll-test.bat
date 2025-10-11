@echo off
echo ================================================
echo  Week 2 Ragdoll Physics Test
echo ================================================
echo.

REM Temporarily rename main.lua and use ragdoll-test.lua
if exist main.lua.backup del main.lua.backup
if exist main.lua ren main.lua main.lua.backup
copy ragdoll-test.lua main.lua >nul

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
echo Ragdoll test closed.
pause
