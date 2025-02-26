@echo off
echo Iniciando Cartelera Digital...

:: Iniciar el servidor Node.js en segundo plano
start "Servidor Cartelera Digital" cmd /c "cd server && node server.js"

:: Esperar 2 segundos para que el servidor inicie
timeout /t 2 /nobreak

:: Iniciar la aplicación Flutter
cd cartelera_digital
flutter run -d windows

:: Si la aplicación se cierra, cerrar también el servidor
taskkill /FI "WINDOWTITLE eq Servidor Cartelera Digital*" /T /F >nul 2>&1
