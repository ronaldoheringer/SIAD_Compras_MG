@echo off
setlocal EnableExtensions EnableDelayedExpansion

cd /d "%~dp0"

set "VENV_DIR=.venv"
set "VENV_PY=%VENV_DIR%\Scripts\python.exe"
set "APP_ENTRY=automacao\main.py"
set "APP_NAME=automacao_app"
set "BUILD_DIR=build"
set "DIST_DIR=dist"

if exist "%VENV_PY%" (
  set "PYTHON=%VENV_PY%"
) else (
  where python >nul 2>nul
  if errorlevel 1 (
    echo [ERRO] Python nao encontrado e .venv nao existe.
    pause
    exit /b 1
  )
  set "PYTHON=python"
)

echo [INFO] Garantindo PyInstaller no ambiente...
"%PYTHON%" -m pip install --upgrade pyinstaller
if errorlevel 1 goto :fail

echo [INFO] Limpando saida anterior...
if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"
if exist "%DIST_DIR%" rmdir /s /q "%DIST_DIR%"

echo [INFO] Gerando executavel em modo one-file (um exe standalone)...
"%PYTHON%" -m PyInstaller --noconfirm --clean --onefile --name "%APP_NAME%" "%APP_ENTRY%"
if errorlevel 1 goto :fail

echo [OK] Build concluido. Executavel em: %DIST_DIR%\%APP_NAME%.exe
pause
exit /b 0

:fail
echo [ERRO] Build interrompido.
pause
exit /b 1