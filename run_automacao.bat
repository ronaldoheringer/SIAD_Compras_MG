@echo off
setlocal EnableExtensions EnableDelayedExpansion

cd /d "%~dp0"

set "VENV_DIR=.venv"
set "VENV_PY=%VENV_DIR%\Scripts\python.exe"
set "REQ_FILE=requirements.txt"
set "APP_FILE=automacao\main.py"
set "APP_MODULE=automacao.main"
set "INSTALL_LOG=%TEMP%\automacao_install.log"

call :check_file "%APP_FILE%" "Script principal"
call :check_file "%REQ_FILE%" "Arquivo de dependencias"

if exist "%VENV_PY%" (
  echo [INFO] Ambiente virtual ja existe.
) else (
  echo [INFO] Criando ambiente virtual %VENV_DIR%...

  where py >nul 2>nul
  if %errorlevel%==0 (
    py -3 -m venv "%VENV_DIR%"
    if errorlevel 1 goto :fail
  ) else (
    where python >nul 2>nul
    if %errorlevel%==0 (
      python -m venv "%VENV_DIR%"
      if errorlevel 1 goto :fail
    ) else (
      echo [ERRO] Python nao encontrado no sistema.
      echo [ERRO] Instale Python 3 e tente novamente.
      goto :fail
    )
  )
)

if not exist "%VENV_PY%" (
  echo [ERRO] Falha ao criar/acessar o Python do venv: %VENV_PY%
  goto :fail
)

echo [INFO] Instalando/atualizando dependencias...
"%VENV_PY%" -m pip install --upgrade pip > "%INSTALL_LOG%" 2>&1
if errorlevel 1 goto :install_fail

"%VENV_PY%" -m pip install -r "%REQ_FILE%" > "%INSTALL_LOG%" 2>&1
if errorlevel 1 goto :install_fail

echo [INFO] Executando automacao Prodemge via TN3270...
"%VENV_PY%" -m %APP_MODULE%
if errorlevel 1 goto :fail

echo [OK] Execucao finalizada com sucesso.
pause
exit /b 0

:install_fail
echo [ERRO] Falha durante instalacao.
echo [ERRO] Detalhes:
type "%INSTALL_LOG%"
goto :fail

:check_file
if not exist "%~1" (
  echo [ERRO] %~2 nao encontrado: %~1
  goto :fail
)
exit /b 0

:fail
echo [ERRO] Processo interrompido.
pause
exit /b 1
