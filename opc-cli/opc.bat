@echo off
REM opc-cli Windows 启动脚本
REM 使用系统 Python 运行 opc-cli

set PYTHON_PATH=python
set SCRIPT_DIR=%~dp0
set SCRIPT=%SCRIPT_DIR%scripts\opc.py

REM 设置 PYTHONPATH 以包含 scripts 目录
set PYTHONPATH=%SCRIPT_DIR%

%PYTHON_PATH% "%SCRIPT%" %*
