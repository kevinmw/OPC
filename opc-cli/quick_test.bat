@echo off
REM OPC CLI Quick Test Script

echo ================================================
echo OPC CLI Quick Test
echo ================================================
echo.

REM Check Python
where python >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Python not found!
    pause
    exit /b 1
)

echo [1/4] Checking Python...
python --version
echo.

echo [2/4] Checking PyTorch and CUDA...
python -c "import torch; print('PyTorch:', torch.__version__); print('CUDA:', torch.cuda.is_available()); print('GPU:', torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'N/A')"
echo.

echo [3/4] Checking qwen-tts...
python -c "from qwen_tts import Qwen3TTSModel; print('qwen-tts: OK')"
echo.

echo [4/4] Testing TTS generation...
cd /d "%~dp0"
echo Generating test audio...
python opc.py tts "Hello, this is opc-cli!" -e qwen --speaker Vivian
if %ERRORLEVEL% EQU 0 (
    echo.
    echo ================================================
    echo [SUCCESS] Test completed!
    echo ================================================
    echo.
    echo Output file: C:\Users\%USERNAME%\AppData\Local\Temp\opc_tts_output.mp3
    echo.

    REM Ask to play
    set /p PLAY="Play the audio? (y/n): "
    if /i "%PLAY%"=="y" (
        start "" "C:\Users\%USERNAME%\AppData\Local\Temp\opc_tts_output.mp3"
    )
) else (
    echo.
    echo ================================================
    echo [ERROR] Test failed!
    echo ================================================
)

echo.
pause
