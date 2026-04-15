@echo off
REM OPC Dashboard Launcher for Windows

echo ================================================
echo OPC Dashboard Launcher
echo ================================================
echo.

REM Check if Node.js is installed
where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Node.js not found!
    echo Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)

echo [OK] Node.js found:
node --version
echo.

REM Change to Dashboard directory
cd /d "%~dp0dashboard\server"

REM Check if node_modules exists
if not exist "node_modules" (
    echo [INFO] Installing dependencies...
    call npm install
    if %ERRORLEVEL% NEQ 0 (
        echo [ERROR] Failed to install dependencies
        pause
        exit /b 1
    )
    echo [OK] Dependencies installed
    echo.
)

REM Check if build is needed
if not exist "dist\index.html" (
    echo [INFO] Building frontend...
    call npm run build
    if %ERRORLEVEL% NEQ 0 (
        echo [ERROR] Build failed
        pause
        exit /b 1
    )
    echo [OK] Frontend built
    echo.
)

REM Start Dashboard
echo [INFO] Starting OPC Dashboard...
echo.
echo Dashboard will be available at:
echo   - http://localhost:12080/
echo   - http://localhost:12080/skill/cut/editor
echo.
echo Press Ctrl+C to stop the server
echo ================================================
echo.

REM Start server
node server-prod.js

pause
