@echo off
echo ================================================
echo  Dismount Roguelike - Debug Mode
echo ================================================
echo.

REM Try common Love2D installation paths
if exist "C:\Program Files\LOVE\love.exe" (
    echo [DEBUG] Found Love2D at: C:\Program Files\LOVE\love.exe
    echo [DEBUG] Starting with console output...
    echo.
    "C:\Program Files\LOVE\love.exe" . --console
    goto :end
)

if exist "C:\Program Files (x86)\LOVE\love.exe" (
    echo [DEBUG] Found Love2D at: C:\Program Files (x86)\LOVE\love.exe
    echo [DEBUG] Starting with console output...
    echo.
    "C:\Program Files (x86)\LOVE\love.exe" . --console
    goto :end
)

REM Try PATH
love . --console 2>nul
if %errorlevel% == 0 (
    echo [DEBUG] Using Love2D from PATH
    goto :end
)

REM If nothing works, show detailed error info
echo.
echo [ERROR] Love2D installation not found!
echo.
echo [DEBUG] Checking current directory...
dir /b *.lua
echo.
echo [DEBUG] Checking lib directory...
if exist lib\ (
    echo Found lib directory:
    dir lib\ /b
) else (
    echo lib directory not found!
)
echo.
echo [SOLUTION] Install Love2D from: https://love2d.org/
echo [SOLUTION] Or add love.exe to your system PATH
echo.
echo Expected Love2D locations:
echo   - C:\Program Files\LOVE\love.exe
echo   - C:\Program Files (x86)\LOVE\love.exe
echo   - love.exe accessible via PATH
echo.
echo Press any key to exit...
pause > nul

:end
echo.
echo ================================================
echo  Debug session ended
echo ================================================
echo.
echo Press any key to close...
pause > nul