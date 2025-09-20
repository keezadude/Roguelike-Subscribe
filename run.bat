@echo off
echo Starting Dismount Roguelike...
echo.

REM Try common Love2D installation paths
if exist "C:\Program Files\LOVE\love.exe" (
    echo Using Love2D from: C:\Program Files\LOVE\love.exe
    "C:\Program Files\LOVE\love.exe" . --console
    goto :end
)

if exist "C:\Program Files (x86)\LOVE\love.exe" (
    echo Using Love2D from: C:\Program Files (x86)\LOVE\love.exe
    "C:\Program Files (x86)\LOVE\love.exe" . --console
    goto :end
)

REM Try PATH
love . --console 2>nul
if %errorlevel% == 0 (
    echo Using Love2D from PATH
    goto :end
)

REM If nothing works, show error
echo.
echo ERROR: Love2D not found!
echo.
echo Please install Love2D from: https://love2d.org/
echo Or add it to your PATH
echo.
echo Expected locations:
echo   - C:\Program Files\LOVE\love.exe
echo   - C:\Program Files (x86)\LOVE\love.exe
echo   - love.exe in PATH
echo.
pause

:end
echo.
echo Game closed.
pause