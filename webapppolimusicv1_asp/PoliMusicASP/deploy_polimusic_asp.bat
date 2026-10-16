@echo off
REM =====================================================================
REM  deploy_polimusic_asp.bat
REM  Despliega la aplicacion PoliMusic (ASP Clasico) en IIS
REM  DESTINO: C:\inetpub\wwwroot\PoliMusicASP
REM
REM  IMPORTANTE: ejecutar este archivo como ADMINISTRADOR
REM  (clic derecho -> "Ejecutar como administrador")
REM =====================================================================

setlocal

set ORIGEN=%~dp0
set DESTINO=C:\inetpub\wwwroot\PoliMusicASP

echo =====================================================
echo   Despliegue PoliMusic - ASP Clasico
echo   Origen : %ORIGEN%
echo   Destino: %DESTINO%
echo =====================================================
echo.

REM --- 1. Verificar privilegios de administrador ---
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Este script debe ejecutarse como Administrador.
    echo         Cierre esta ventana, haga clic derecho sobre el archivo
    echo         y elija "Ejecutar como administrador".
    echo.
    pause
    exit /b 1
)

REM --- 2. Crear el directorio destino ---
if not exist "%DESTINO%" (
    echo [1/4] Creando carpeta destino...
    mkdir "%DESTINO%"
) else (
    echo [1/4] La carpeta destino ya existe.
)

REM --- 3. Copiar archivos ---
echo [2/4] Copiando archivos de la aplicacion...
robocopy "%ORIGEN%." "%DESTINO%" /E /NFL /NDL /NJH /NJS /NP /XF deploy_polimusic_asp.bat LEEME_ASP.txt
if %errorlevel% geq 8 (
    echo [ERROR] Fallo la copia de archivos.
    pause
    exit /b 1
)

REM --- 4. Habilitar ASP Clasico en IIS ---
echo [3/4] Habilitando ASP Clasico en IIS...
dism /online /enable-feature /featurename:IIS-ASP /all /norestart >nul 2>&1
if %errorlevel% neq 0 (
    echo     [AVISO] No se pudo habilitar ASP automaticamente.
    echo             Hagalo manualmente en:
    echo             Panel de control - Programas - Caracteristicas de Windows
    echo             - Servicios de Internet Information Server
    echo             - World Wide Web Services - Application Development Features
    echo             - ASP
)

REM --- 5. Crear la aplicacion en IIS y configurar el pool ---
echo [4/4] Registrando la aplicacion en IIS...
%SystemRoot%\System32\inetsrv\appcmd.exe list app "Default Web Site/PoliMusicASP" >nul 2>&1
if %errorlevel% neq 0 (
    %SystemRoot%\System32\inetsrv\appcmd.exe add app /site.name:"Default Web Site" /path:"/PoliMusicASP" /physicalPath:"%DESTINO%"
) else (
    %SystemRoot%\System32\inetsrv\appcmd.exe set vdir "Default Web Site/PoliMusicASP/" /physicalPath:"%DESTINO%"
)

REM El pool debe permitir ASP Clasico (managedRuntimeVersion vacio = No Managed Code)
%SystemRoot%\System32\inetsrv\appcmd.exe set apppool "DefaultAppPool" /managedRuntimeVersion:"" >nul 2>&1

REM --- 6. Permisos de lectura para IIS ---
icacls "%DESTINO%" /grant "IIS_IUSRS:(OI)(CI)R" /T >nul 2>&1

echo.
echo =====================================================
echo   DESPLIEGUE COMPLETADO
echo =====================================================
echo   URL: http://localhost/PoliMusicASP/login.asp
echo.
echo   Usuarios de prueba (contrasena: 12345678):
echo     userAdmin          (administrador)
echo     epn.fis            (usuario normal)
echo     genesis.vasconez   (usuario normal)
echo.
echo   Recuerde ejecutar antes:
echo     BDD_PoliMusic.sql
echo     Setup_GenesisVasconez.sql
echo =====================================================
echo.
pause
endlocal
