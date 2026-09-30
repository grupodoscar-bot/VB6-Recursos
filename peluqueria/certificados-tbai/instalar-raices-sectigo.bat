@echo off
REM ============================================================
REM  Instala las raices Sectigo (R46 + E46) en el almacen de
REM  Entidades de certificacion raiz de confianza del EQUIPO.
REM  Necesario para el cambio de cadena SSL/TLS de TicketBAI
REM  (Araba/Bizkaia/Gipuzkoa), pre 01-10-2026 / prod nov2026-ene2027.
REM  Solo hace falta en equipos ANTIGUOS que den error SSL al enviar.
REM  Ejecutar como ADMINISTRADOR (clic derecho > Ejecutar como admin).
REM ============================================================
setlocal
cd /d "%~dp0"

net session >nul 2>&1
if %errorlevel% neq 0 (
  echo.
  echo  *** Debes ejecutar este fichero como ADMINISTRADOR ***
  echo  Clic derecho sobre el .bat  ^>  "Ejecutar como administrador".
  echo.
  pause
  exit /b 1
)

echo.
echo  Instalando raices Sectigo en "Entidades de certificacion raiz de confianza"...
echo.

certutil -addstore -f Root "SectigoPublicServerAuthenticationRootR46.cer"
certutil -addstore -f Root "SectigoPublicServerAuthenticationRootE46.cer"

echo.
echo  Verificando que quedaron instaladas...
certutil -store Root "Sectigo Public Server Authentication Root R46" >nul 2>&1
if %errorlevel%==0 (echo    [OK]  Sectigo R46) else (echo    [FALLO] Sectigo R46)
certutil -store Root "Sectigo Public Server Authentication Root E46" >nul 2>&1
if %errorlevel%==0 (echo    [OK]  Sectigo E46) else (echo    [FALLO] Sectigo E46)

echo.
echo  Terminado. Ya puedes cerrar esta ventana.
echo.
pause
endlocal
