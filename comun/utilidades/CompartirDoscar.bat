@echo off
setlocal EnableDelayedExpansion

REM ================================================================
REM  CompartirDoscar.bat
REM  Comparte la carpeta del programa Doscar, crea el usuario
REM  generico "doscar" y genera el script del cliente (ConectarDoscar_Z.bat)
REM  que monta la unidad Z: en el otro equipo.
REM
REM  USO:  copie este .bat DENTRO de la carpeta de Doscar y ejecutelo
REM        como administrador (o arrastre la carpeta sobre el .bat).
REM ================================================================

REM ---------- CONFIGURACION (editable) ----------
set "RECURSO=DOSCAR"
set "USUARIO=doscar"
set "CLAVE=doscar"
REM ----------------------------------------------

REM ---- Carpeta a compartir: argumento arrastrado o carpeta del .bat ----
set "CARPETA=%~1"
if "%CARPETA%"=="" set "CARPETA=%~dp0"
if "%CARPETA:~-1%"=="\" set "CARPETA=%CARPETA:~0,-1%"

REM ---- Comprobar permisos de administrador y autoelevar ----
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Solicitando permisos de administrador...
    powershell -Command "Start-Process -FilePath '%~f0' -ArgumentList '\"%CARPETA%\"' -Verb RunAs"
    exit /b
)

echo ================================================
echo   COMPARTIR CARPETA DOSCAR
echo ================================================
echo   Carpeta : %CARPETA%
echo   Recurso : \\%COMPUTERNAME%\%RECURSO%
echo   Usuario : %USUARIO%  (clave: %CLAVE%)
echo ================================================
echo.

REM ---- 1) Crear el usuario generico ----
net user %USUARIO% >nul 2>&1
if %errorlevel%==0 (
    echo [i] El usuario %USUARIO% ya existe.
) else (
    net user %USUARIO% %CLAVE% /add /expires:never /passwordchg:no
    if !errorlevel! neq 0 (
        echo [ERROR] No se pudo crear el usuario. Puede que la politica
        echo         de contrasenas exija una clave mas compleja.
        goto :fin_error
    )
    echo [OK] Usuario %USUARIO% creado.
)

REM ---- Que la contrasena nunca caduque ----
wmic useraccount where "name='%USUARIO%'" set PasswordExpires=false >nul 2>&1

REM ---- 2) Permisos NTFS: control total sobre la carpeta ----
icacls "%CARPETA%" /grant "%USUARIO%:(OI)(CI)F" /T /C >nul
if %errorlevel% neq 0 (
    echo [ERROR] No se pudieron asignar los permisos NTFS.
    goto :fin_error
)
echo [OK] Permisos NTFS (control total) concedidos a %USUARIO%.

REM ---- 3) Compartir la carpeta en red ----
net share %RECURSO% >nul 2>&1
if %errorlevel%==0 (
    echo [i] El recurso %RECURSO% ya existia; se vuelve a crear.
    net share %RECURSO% /delete /y >nul 2>&1
)
net share %RECURSO%="%CARPETA%" /GRANT:%USUARIO%,FULL /REMARK:"Programa Doscar compartido" >nul
if %errorlevel% neq 0 (
    echo [ERROR] No se pudo compartir la carpeta.
    goto :fin_error
)
echo [OK] Carpeta compartida como \\%COMPUTERNAME%\%RECURSO%.

REM ---- 4) Recopilar las IP validas del servidor (sin 127.x ni 169.254.x) ----
set "IPS="
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4"') do (
    set "IP=%%a"
    set "IP=!IP: =!"
    set "SKIP="
    echo !IP!| findstr /b /c:"127." >nul && set "SKIP=1"
    echo !IP!| findstr /b /c:"169.254." >nul && set "SKIP=1"
    if not defined SKIP set "IPS=!IPS! !IP!"
)

REM ---- 4b) Detectar cuales de los 7 ejecutables Doscar hay en la carpeta ----
set "PROGS="
for %%e in (taller.exe gestion.exe peluqueria.exe barrestaurante.exe tpv.exe cristal.exe carpintero.exe) do (
    if exist "%CARPETA%\%%e" set "PROGS=!PROGS! %%e"
)
if defined PROGS (
    echo Programas Doscar detectados:!PROGS!
) else (
    echo [i] No se detecto ninguno de los 7 ejecutables Doscar en esta carpeta.
)
echo.

REM ---- 5) Generar el script del cliente ----
set "CLIENTE=%~dp0ConectarDoscar_%COMPUTERNAME%.bat"
(
  echo @echo off
  echo REM ================================================================
  echo REM  Conecta una unidad de red al Doscar compartido en %COMPUTERNAME%
  echo REM  NO ejecutar como administrador: doble clic normal.
  echo REM ================================================================
  echo.
  echo REM --- Aviso si se ejecuta como administrador ---
  echo net session ^>nul 2^>^&1
  echo if not errorlevel 1 ^(
  echo   echo [AVISO] No ejecute este archivo como administrador.
  echo   echo         Cierrelo y abralo con DOBLE CLIC normal, o la unidad
  echo   echo         no aparecera en "Este equipo".
  echo   pause
  echo   exit /b 1
  echo ^)
  echo.
  echo REM --- IP del servidor a probar si falla el nombre ---
  echo set "IPS=%IPS%"
  echo.
  echo REM --- Primera letra de unidad libre empezando por la Z ---
  echo set "LETRA="
  echo if not exist Z:\ set "LETRA=Z"
  echo if "%%LETRA%%"=="" if not exist Y:\ set "LETRA=Y"
  echo if "%%LETRA%%"=="" if not exist X:\ set "LETRA=X"
  echo if "%%LETRA%%"=="" if not exist W:\ set "LETRA=W"
  echo if "%%LETRA%%"=="" if not exist V:\ set "LETRA=V"
  echo if "%%LETRA%%"=="" if not exist U:\ set "LETRA=U"
  echo if "%%LETRA%%"=="" if not exist T:\ set "LETRA=T"
  echo if "%%LETRA%%"=="" echo No hay letras de unidad libres. ^& pause ^& exit /b 1
  echo net use %%LETRA%%: /delete /y ^>nul 2^>^&1
  echo.
  echo REM --- 1. Intento por NOMBRE del equipo, lo mas facil ---
  echo echo Conectando por nombre: \\%COMPUTERNAME%\%RECURSO% ...
  echo net use %%LETRA%%: \\%COMPUTERNAME%\%RECURSO% %CLAVE% /user:%COMPUTERNAME%\%USUARIO% /persistent:yes
  echo if not errorlevel 1 goto :conectado
  echo.
  echo REM --- 2. Si el nombre falla, probar por IP ---
  echo echo.
  echo echo No se pudo por nombre. Probando por IP:
  echo echo    %%IPS%%
  echo for %%%%i in ^(%%IPS%%^) do ^(
  echo   echo  - Probando \\%%%%i\%RECURSO% ...
  echo   net use %%LETRA%%: \\%%%%i\%RECURSO% %CLAVE% /user:%COMPUTERNAME%\%USUARIO% /persistent:yes
  echo   if not errorlevel 1 goto :conectado
  echo ^)
  echo.
  echo echo.
  echo echo [ERROR] No se pudo conectar ni por nombre ni por IP.
  echo echo         Revise la red, el firewall del servidor y las credenciales.
  echo pause
  echo exit /b 1
  echo.
  echo :conectado
  echo echo.
  echo echo [OK] Unidad %%LETRA%%: conectada al Doscar.
) > "%CLIENTE%"

REM ---- 5b) Anadir accesos directos de escritorio para los programas detectados ----
set "PCT=%%"
for %%p in (%PROGS%) do >> "%CLIENTE%" echo powershell -NoProfile -Command "$w=New-Object -ComObject WScript.Shell; $s=$w.CreateShortcut^($w.SpecialFolders^('Desktop'^)+'\Doscar %%~np.lnk'^); $s.TargetPath='!PCT!LETRA!PCT!:\%%p'; $s.WorkingDirectory='!PCT!LETRA!PCT!:\'; $s.Save^(^)"
if defined PROGS >> "%CLIENTE%" echo echo Accesos directos creados en el escritorio.
>> "%CLIENTE%" echo pause

echo [OK] Script del cliente generado:
echo      %CLIENTE%
echo.
echo ------------------------------------------------
echo   LISTO. Ahora en el OTRO equipo:
echo   1) Copie el archivo  ConectarDoscar_%COMPUTERNAME%.bat
echo   2) Ejecutelo con DOBLE CLIC normal (NO como administrador).
echo      Intentara por nombre y, si falla, por IP automaticamente.
echo      Montara la primera letra de unidad libre (Z o siguiente).
echo ------------------------------------------------
echo.
echo IP del servidor incluidas en el script cliente: %IPS%
echo.
pause
exit /b 0

:fin_error
echo.
echo Proceso interrumpido por un error. Revise el mensaje anterior.
pause
exit /b 1
